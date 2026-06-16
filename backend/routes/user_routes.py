from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, logger

from models.users import UserIn, UserOut, UserRoleUpdate, UserProfileUpdate
from services.database import get_pool

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
                user.email,
                user.phone,
                user.role,
                user.county_work
            )
        logger.logger.info(f"Synced user: name: {user.first_name} {user.last_name}")
        return dict(result)
    except Exception as e:
        logger.logger.error(f"Failed to sync user: {e}")
        raise HTTPException(status_code=500, detail="Failed to sync user")


@router.put("/{user_id}", response_model=UserOut)
async def update_user_profile(
    user_id: UUID, profile_update: UserProfileUpdate, pool=Depends(get_pool)
):
    """Update the editable profile fields for a user."""
    query = """
        SELECT * FROM haven_upsert_user($1, $2, $3, $4, $5, $6, $7)
    """
    async with pool.acquire() as conn:
        current = await conn.fetchrow("SELECT * FROM haven_get_user_by_id($1)", user_id)
        if not current:
            raise HTTPException(status_code=404, detail="User not found")
        result = await conn.fetchrow(
            query,
            user_id,
            profile_update.first_name,
            profile_update.last_name,
            profile_update.email,
            profile_update.phone,
            current["role_user"],
            current["county_work"],
        )
    return dict(result)


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
