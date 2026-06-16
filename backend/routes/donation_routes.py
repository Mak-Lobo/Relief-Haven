from fastapi import APIRouter, HTTPException, Request
from loguru import logger

from models.donations import DonationOut, DonationRequest
from models.mpesa import MpesaCallbackPayload
from services.database import get_pool
# from services.payments.airtel import airtel_push
from services.payments.mpesa import MpesaSTKError, MpesaTimeoutError, stk_push

router = APIRouter(prefix="/donations", tags=["donations"])
mpesa_router = APIRouter(prefix="/mpesa", tags=["mpesa"])


def _normalize_phone(phone: int | str) -> str:
    value = str(phone).strip()
    return value if value.startswith("254") else f"254{value.lstrip('0')}"


async def _ensure_pending_table(conn):
    await conn.execute(
        """
        CREATE TABLE IF NOT EXISTS pending_mpesa_payments
        (
            checkout_request_id
            varchar
        (
            50
        ) PRIMARY KEY,
            user_id UUID NOT NULL,
            amount_kes NUMERIC
        (
            10,
            2
        ) NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW
        (
        )
            )
        """
    )


@router.post("/initiate")
async def initiate_donation(payload: DonationRequest):
    if payload.payment_service == "mpesa":
        phone = _normalize_phone(payload.phone)
        pool = get_pool()
        async with pool.acquire() as conn:
            async with conn.transaction():
                try:
                    response = await stk_push(
                        phone=phone,
                        amount=int(payload.amount_kes),
                        account_reference=str(payload.user_id),
                        transaction_desc="Relief Haven Donation",
                    )
                except (MpesaSTKError, MpesaTimeoutError) as exc:
                    raise HTTPException(status_code=502, detail=str(exc)) from exc

                await _ensure_pending_table(conn)
                await conn.execute(
                    """
                    INSERT INTO pending_mpesa_payments (checkout_request_id, user_id, amount_kes)
                    VALUES ($1, $2, $3)
                    """,
                    response["CheckoutRequestID"],
                    payload.user_id,
                    payload.amount_kes,
                )

        return {
            "message": "M-Pesa prompt sent. Awaiting approval.",
            "checkout_request_id": response["CheckoutRequestID"],
            "payment_service": "mpesa",
        }

    if payload.payment_service == "airtel-money":
        return {
            "message": "Airtel Money is not yet available. Please use M-Pesa.",
            "payment_service": "airtel",
        }

        # try:
        #     resp = await airtel_push(phone=payload.phone, amount=payload.amount_kes)
        #     checkout_id = resp["transaction"]["id"]
        # except NotImplementedError:
        #     raise HTTPException(
        #         status_code=503,
        #         detail="Airtel Money is not yet available. Please use M-Pesa.",
        #     )
        # except Exception as e:
        #     raise HTTPException(status_code=502, detail=f"Airtel error: {str(e)}")
        #
        # return {
        #     "message": "Airtel prompt sent. Awaiting approval.",
        #     "checkout_request_id": checkout_id,
        #     "payment_service": "airtel",
        # }

    raise HTTPException(status_code=400, detail="Unsupported payment service.")


@mpesa_router.post("/stk/callback/")
async def mpesa_stk_callback(request: Request):
    try:
        body = await request.json()
        payload = MpesaCallbackPayload.model_validate(body)
    except Exception as exc:
        raise HTTPException(status_code=400, detail="Invalid callback payload") from exc

    stk = payload.Body["stkCallback"]
    checkout_id = stk.CheckoutRequestID
    if stk.ResultCode != 0:
        logger.warning(f"M-Pesa callback failed: {stk.ResultDesc}")
        return {"ResultCode": 0, "ResultDesc": "Accepted"}

    metadata = stk.CallbackMetadata or {}
    items = metadata.get("Item", [])
    data = {item.Name: item.Value for item in items}
    receipt = data.get("MpesaReceiptNumber")
    amount = data.get("Amount")
    phone = data.get("PhoneNumber")

    if not receipt or not amount or not phone:
        logger.warning(f"Incomplete M-Pesa callback ignored: {body}")
        return {"ResultCode": 0, "ResultDesc": "Accepted"}

    pool = get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            await _ensure_pending_table(conn)
            pending = await conn.fetchrow(
                """
                DELETE
                FROM pending_mpesa_payments
                WHERE checkout_request_id = $1 RETURNING user_id, amount_kes
                """,
                stk.CheckoutRequestID,
            )

            if not pending:
                logger.warning(
                    f"M-Pesa callback did not match a pending payment: {checkout_id}"
                )
                return {"ResultCode": 0, "ResultDesc": "Accepted"}

            donation = await conn.fetchrow(
                """
                INSERT INTO donations (user_id, amount_kes, transaction_id, payment_service)
                SELECT $1,
                       $2,
                       $3::varchar, $4 WHERE NOT EXISTS (
                    SELECT 1 FROM donations WHERE transaction_id = $3:: varchar
                    )
                    RETURNING donation_id
                """,
                pending["user_id"],
                pending["amount_kes"],
                receipt,
                "mpesa",
            )

            if not donation:
                logger.warning(f"Duplicate donation ignored — receipt: {receipt}")
                return {"ResultCode": 0, "ResultDesc": "Accepted"}

    logger.info(f"Donation recorded — receipt: {receipt}, amount: {amount}, phone: {phone}")
    return {"ResultCode": 0, "ResultDesc": "Accepted"}


@router.get("/", response_model=list[DonationOut])
async def get_all_donations():
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch("SELECT * FROM haven_get_all_donations()")
    return [dict(r) for r in rows]


@router.get("/user/{user_id}", response_model=list[DonationOut])
async def get_donations_by_user(user_id: str):
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch("SELECT * FROM haven_get_donations_by_user($1)", user_id)
    return [dict(r) for r in rows]


@router.get("/{donation_id}", response_model=DonationOut)
async def get_donation_by_id(donation_id: str):
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow("SELECT * FROM haven_get_donation_by_id($1)", donation_id)
    if not row:
        raise HTTPException(status_code=404, detail="Donation not found")
    return dict(row)


@router.delete("/{donation_id}")
async def delete_donation(donation_id: str):
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute("SELECT haven_delete_donation($1)", donation_id)
    return {"message": "Donation deleted"}
