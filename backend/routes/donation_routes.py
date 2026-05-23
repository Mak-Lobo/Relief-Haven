from fastapi import APIRouter, HTTPException
from daraja_sdk import fastapi as daraja, MpesaClient
from daraja_sdk import MpesaSTKError, MpesaTimeoutError
from loguru import logger

from models.donations import DonationOut, DonationRequest
from services.database import get_pool
from services.payments.airtel import airtel_push
from services.payments.mpesa import MPESA_CONFIG

router = APIRouter(prefix="/donations", tags=["donations"])


@daraja.on_payment_received
async def handle_mpesa_payment(data: dict) -> None:
    user_id = data["account_reference"]
    amount = data["amount"]
    receipt = data["receipt"]

    pool = get_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            donation = await conn.fetchrow(
                """
                INSERT INTO donations (user_id, amount_kes, transaction_id, payment_service)
                SELECT $1, $2, $3, $4
                WHERE NOT EXISTS (
                    SELECT 1 FROM donations WHERE transaction_id = $3
                )
                RETURNING donation_id
                """,
                user_id,
                float(amount),
                receipt,
                "mpesa",
            )
            if not donation:
                logger.warning(f"Duplicate donation ignored — receipt: {receipt}")
                return

    log_info = f'Donation recorded — receipt: {receipt}, amount: {amount}. User: {user_id}'
    logger.info(log_info)


@router.post("/initiate")
async def initiate_donation(payload: DonationRequest):
    if payload.payment_service == "mpesa":
        try:
            async with MpesaClient(**MPESA_CONFIG) as client:
                resp = await client.stk_push(
                    phone=str(f'254{payload.phone}'),
                    amount=int(payload.amount_kes),
                    account_reference=str(payload.user_id),
                    transaction_desc="Relief Haven Donation",
                )

        except MpesaTimeoutError:
            raise HTTPException(status_code=504, detail="M-Pesa request timed out.")
        except MpesaSTKError as e:
            raise HTTPException(status_code=502, detail=str(e))

        return {
            "message": "M-Pesa prompt sent. Awaiting approval.",
            "checkout_request_id": resp["CheckoutRequestID"],
            "payment_service": "mpesa",
        }

    elif payload.payment_service == "airtel-mpesa":
        try:
            resp = await airtel_push(phone=payload.phone, amount=payload.amount_kes)
            checkout_id = resp["transaction"]["id"]
        except NotImplementedError:
            raise HTTPException(
                status_code=503,
                detail="Airtel Money is not yet available. Please use M-Pesa.",
            )
        except Exception as e:
            raise HTTPException(status_code=502, detail=f"Airtel error: {str(e)}")

        return {
            "message": "Airtel prompt sent. Awaiting approval.",
            "checkout_request_id": checkout_id,
            "payment_service": "airtel",
        }


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
        rows = await conn.fetch(
            "SELECT * FROM haven_get_donations_by_user($1)", user_id
        )
    return [dict(r) for r in rows]


@router.get("/{donation_id}", response_model=DonationOut)
async def get_donation_by_id(donation_id: str):
    pool = get_pool()
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT * FROM haven_get_donation_by_id($1)", donation_id
        )
    if not row:
        raise HTTPException(status_code=404, detail="Donation not found")
    return dict(row)


@router.delete("/{donation_id}")
async def delete_donation(donation_id: str):
    pool = get_pool()
    async with pool.acquire() as conn:
        await conn.execute("SELECT haven_delete_donation($1)", donation_id)
    return {"message": "Donation deleted"}
