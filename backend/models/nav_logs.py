from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

class NavLogs(BaseModel):
    nav_log_id: UUID
    user_id: str
    shelter_id: str
    location: tuple
    distance: float
    navigation_date: datetime
