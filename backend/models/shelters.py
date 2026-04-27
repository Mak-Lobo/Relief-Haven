from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, field_validator


class ShelterIn(BaseModel):
    name: str
    subcounty: str
    county: str
    location: str
    capacity: int

    @field_validator("location")
    @classmethod
    def location_must_be_wkt_point(cls, v):
        if not v.startswith("POINT("):
            raise ValueError("location must be a WKT Point e.g. 'POINT(36.8219 -1.2921)'")
        return v


class ShelterOut(BaseModel):
    shelter_id: UUID
    name: str
    subcounty: str
    county: str
    location: str       # ST_AsText() returns 'POINT(lng lat)'
    capacity: int
    occupancy: int
    is_active: bool
    updated_at: datetime
    added_at: datetime


class ShelterUpdate(BaseModel):
    name: str
    subcounty: str
    county: str
    capacity: int


class ShelterOccupancyUpdate(BaseModel):
    occupancy: int


class ShelterCapacityStatus(BaseModel):
    shelter_id: UUID
    is_full: bool
