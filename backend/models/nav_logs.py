from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field, field_validator

from utils.geometry import validate_wkt_point


class NavLogIn(BaseModel):
    user_id: UUID
    shelter_id: UUID
    location: str
    distance: float

    _validate_location = field_validator("location")(validate_wkt_point)


class NavLogOut(BaseModel):
    navigation_id: UUID
    user_id: UUID
    shelter_id: UUID
    location: str
    distance: float
    navigation_date: datetime


class NavigateRequest(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)


class NearestShelterOut(BaseModel):
    shelter_id: UUID
    name: str
    subcounty: str
    county: str
    location: str
    capacity: int
    occupancy: int
    is_active: bool
    distance_meters: float
    distance_km: float
    duration_seconds: float | None = None


class RouteOut(BaseModel):
    shelter_id: UUID
    name: str
    location: str
    distance_meters: float
    distance_km: float
    duration_seconds: float | None = None
    geometry: list[list[float]]
