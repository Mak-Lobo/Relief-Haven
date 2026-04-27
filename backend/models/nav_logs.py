from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, field_validator


class NavLogIn(BaseModel):
    user_id: UUID
    shelter_id: UUID
    location: str
    distance: float

    @field_validator("location")
    @classmethod
    def location_must_be_wkt_point(cls, v):
        if not v.startswith("POINT("):
            raise ValueError("location must be a WKT Point e.g. 'POINT(36.8219 -1.2921)'")
        return v


class NavLogOut(BaseModel):
    navigation_id: UUID
    user_id: UUID
    shelter_id: UUID
    location: str
    distance: float
    navigation_date: datetime
