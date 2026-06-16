from datetime import datetime
from uuid import UUID
from typing import Optional
from pydantic import BaseModel, field_validator, model_validator


class UserIn(BaseModel):
    user_id: UUID
    first_name: str
    last_name: str
    email: str
    phone: int
    role: str
    county_work: Optional[str] = None

    @model_validator(mode="after")
    def validate_role_and_county(self):
        # Rule 1: managers MUST have a county
        if self.role == "manager" and not self.county_work:
            raise ValueError("Managers must have a county_work")

        # Rule 2: non-managers MUST NOT have a county
        if self.role != "manager" and self.county_work is not None:
            raise ValueError("Only managers can have county_work")

        return self


class UserOut(BaseModel):
    user_id: UUID
    first_name: str
    last_name: str
    email: str
    phone: int
    role_user: str
    county_work: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class UserRoleUpdate(BaseModel):
    role_user: str
    county_work: Optional[str] = None

    @field_validator("role_user")
    @classmethod
    def role_must_be_valid(cls, v):
        allowed = {"manager", "command", "civilian"}
        if v not in allowed:
            raise ValueError(f"role must be one of {allowed}")
        return v

    @field_validator("county_work")
    @classmethod
    def county_work_only_for_manager(cls, v, info):
        role = info.data.get("role_user")
        if role != "manager" and v is not None:
            raise ValueError("county_work can only be set when role is 'manager'")
        return v


class UserProfileUpdate(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone: int
