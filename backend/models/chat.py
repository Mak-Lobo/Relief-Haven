from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

class ChatLog(BaseModel):
    id: UUID
    user_id: str
    prompt: str
    response: str
    created_at: datetime

