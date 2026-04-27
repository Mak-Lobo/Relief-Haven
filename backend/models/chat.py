from datetime import datetime
from uuid import UUID
from pydantic import BaseModel


class ChatLogIn(BaseModel):
    user_id: UUID
    prompt: str
    response: str


class ChatLogOut(BaseModel):
    chat_id: UUID
    user_id: UUID
    prompt: str
    response: str
    created_at: datetime

