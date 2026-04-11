from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

class Donation(BaseModel):
    id: UUID
    user_id: str
    transaction_id: str
    amount: int
    pay_service: str
    created_at: datetime
