from datetime import datetime
from uuid import UUID
from typing import Optional
from pydantic import BaseModel


class ResourceIn(BaseModel):
    shelter_id: UUID
    food: bool
    water: bool
    medical: bool
    add_notes: Optional[str] = None


class ResourceOut(BaseModel):
    resource_id: UUID
    shelter_id: UUID
    food: bool
    water: bool
    medical: bool
    add_notes: Optional[str] = None
    updated_at: datetime


class ResourceUpdate(BaseModel):
    food: bool
    water: bool
    medical: bool
    add_notes: Optional[str] = None
