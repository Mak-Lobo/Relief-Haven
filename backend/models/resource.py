from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

class Resources(BaseModel):
    resource_id: UUID
    shelter_id: str
    food: bool
    water: bool
    medical: bool
    add_notes: str | None
    updated_at: datetime
