from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

class UsersIn:
    id: UUID
    first_name: str
    last_name: str
    email: str
    phone: int
    role: str
    created_at: datetime
    updated_at: datetime

class UsersOut(UsersIn):
    pass