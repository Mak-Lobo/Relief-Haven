from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, logger

from models.users import UserIn, UserOut, UserRoleUpdate
from database import get_pool

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/", response_model=List[UserOut])
async def get_all_users(pool=Depends(get_pool)):
    """Get all users."""
    query = "SELECT * FROM haven_get_all_users()"
    async with pool.acquire() as conn:
        result = await conn.fetch(query)
    return [dict(row) for row in result]


@router.get("/{user_id}", response_model=UserOut)
async def get_user_by_id(user_id: UUID, pool=Depends(get_pool)):
    """Get a single user by ID."""
    query = "SELECT * FROM haven_get_user_by_id($1)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(query, user_id)
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return dict(result)


@router.post("/sync", response_model=UserOut)
async def sync_user(user: UserIn, pool=Depends(get_pool)):
    """Register/update user from Supabase."""
    try:
        query = "SELECT * FROM haven_upsert_user($1, $2, $3, $4, $5, $6, $7)"
        async with pool.acquire() as conn:
            result = await conn.fetchrow(
                query,
                user.user_id,
                user.first_name,
                user.last_name,
                user.email_address,
                user.phone_number,
                user.role,
                user.county_work
            )
        return {
            "user_id": result["user_id"],
            "first_name": result["first_name"],
            "last_name": result["last_name"],
            "email_address": result["email"],  # map
            "phone_number": result["phone"],  # map
            "role": result["role_user"],  # map
            "county_work": result["county_work"],
            "created_at": result["created_at"],
            "updated_at": result["updated_at"],
        }
    except Exception as e:
        logger.logger.error(f"Failed to sync user: {e}")
        raise HTTPException(status_code=500, detail="Failed to sync user")


@router.put("/{user_id}/role", response_model=UserOut)
async def update_user_role(user_id: UUID, role_update: UserRoleUpdate, pool=Depends(get_pool)):
    """Update user role and county_work."""
    query = "SELECT * FROM haven_update_user_role($1, $2, $3)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(query, user_id, role_update.role, role_update.county_work)
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return dict(result)


@router.delete("/{user_id}")
async def delete_user(user_id: UUID, pool=Depends(get_pool)):
    """Delete user and all related data (cascade)."""
    query = "CALL haven_delete_user_cascade($1)"
    async with pool.acquire() as conn:
        await conn.execute(query, user_id)
    return {"message": "User deleted successfully"}
