from __future__ import annotations

import base64
import os
from dataclasses import dataclass
from datetime import datetime

import httpx
from dotenv import load_dotenv

load_dotenv()

MPESA_ENV = os.getenv("MPESA_ENV", "sandbox").lower()
MPESA_BASE_URL = (
    "https://sandbox.safaricom.co.ke" if MPESA_ENV == "sandbox" else "https://api.safaricom.co.ke"
)

MPESA_CONSUMER_KEY = os.getenv("MPESA_CONSUMER_KEY")
MPESA_CONSUMER_SECRET = os.getenv("MPESA_CONSUMER_SECRET")
MPESA_SHORTCODE = os.getenv("MPESA_SHORTCODE", "174379")
MPESA_PASSKEY = os.getenv("MPESA_PASSKEY")
MPESA_CALLBACK_URL = os.getenv("MPESA_CALLBACK_URL")


@dataclass(slots=True)
class MpesaClientConfig:
    consumer_key: str
    consumer_secret: str
    shortcode: str
    passkey: str
    callback_url: str
    base_url: str = MPESA_BASE_URL


class MpesaClientError(RuntimeError):
    pass


class MpesaSTKError(MpesaClientError):
    pass


class MpesaTimeoutError(MpesaClientError):
    pass


MPESA_CONFIG = MpesaClientConfig(
    consumer_key=MPESA_CONSUMER_KEY,
    consumer_secret=MPESA_CONSUMER_SECRET,
    shortcode=MPESA_SHORTCODE,
    passkey=MPESA_PASSKEY,
    callback_url=MPESA_CALLBACK_URL,
)


def _timestamp() -> str:
    return datetime.now().strftime("%Y%m%d%H%M%S")


def _password(shortcode: str, passkey: str, timestamp: str) -> str:
    raw = f"{shortcode}{passkey}{timestamp}".encode()
    return base64.b64encode(raw).decode()


async def _get_access_token(client: httpx.AsyncClient, config: MpesaClientConfig) -> str:
    if not config.consumer_key or not config.consumer_secret:
        raise MpesaSTKError("Missing M-Pesa consumer credentials")

    response = await client.get(
        f"{config.base_url}/oauth/v1/generate?grant_type=client_credentials",
        auth=(config.consumer_key, config.consumer_secret),
        timeout=30,
    )
    response.raise_for_status()
    return response.json()["access_token"]


async def stk_push(
    *,
    phone: str,
    amount: int,
    account_reference: str,
    transaction_desc: str,
    config: MpesaClientConfig = MPESA_CONFIG,
) -> dict:
    if not config.shortcode or not config.passkey or not config.callback_url:
        raise MpesaSTKError("Missing M-Pesa STK configuration")

    timestamp = _timestamp()
    payload = {
        "BusinessShortCode": config.shortcode,
        "Password": _password(config.shortcode, config.passkey, timestamp),
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": int(amount),
        "PartyA": phone,
        "PartyB": config.shortcode,
        "PhoneNumber": phone,
        "CallBackURL": config.callback_url,
        "AccountReference": account_reference,
        "TransactionDesc": transaction_desc,
    }

    async with httpx.AsyncClient() as client:
        token = await _get_access_token(client, config)
        response = await client.post(
            f"{config.base_url}/mpesa/stkpush/v1/processrequest",
            json=payload,
            headers={"Authorization": f"Bearer {token}"},
            timeout=60,
        )

    if response.status_code >= 400:
        raise MpesaSTKError(response.text)

    data = response.json()
    response_code = str(data.get("ResponseCode", "1"))
    if response_code != "0":
        raise MpesaSTKError(data.get("ResponseDescription", "M-Pesa STK push failed"))

    return data
