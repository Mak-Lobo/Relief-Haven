from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

class Shelters(BaseModel):
    id: UUID
    name: str
    subcounty: str
    county: str
    location: tuple
    capacity: int
    occupancy: int
    is_active: bool
    updated_at: datetime