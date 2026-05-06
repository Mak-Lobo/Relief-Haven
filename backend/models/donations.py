from datetime import datetime
from typing import Literal
from uuid import UUID
from pydantic import BaseModel


class DonationIn(BaseModel):
    user_id: UUID
    amount_kes: float
    transaction_id: str
    payment_service: str


class DonationOut(BaseModel):
    donation_id: UUID
    user_id: UUID
    amount_kes: float
    transaction_id: str
    payment_service: str
    created_at: datetime


class DonationRequest(BaseModel):
    user_id: UUID
    amount_kes: float
    phone: int
    payment_service: Literal["mpesa", "airtel-money"]
