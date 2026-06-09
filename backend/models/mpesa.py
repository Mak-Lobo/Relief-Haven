from datetime import datetime
from typing import Any
from pydantic import BaseModel


class MpesaStkInitiateRequest(BaseModel):
    phone: int
    amount: float
    account_reference: str
    transaction_desc: str = "Relief Haven Donation"


class MpesaCallbackMetadataItem(BaseModel):
    Name: str
    Value: Any | None = None


class MpesaCallbackBody(BaseModel):
    MerchantRequestID: str
    CheckoutRequestID: str
    ResultCode: int
    ResultDesc: str
    CallbackMetadata: dict[str, list[MpesaCallbackMetadataItem]] | None = None


class MpesaCallbackPayload(BaseModel):
    Body: dict[str, MpesaCallbackBody]
