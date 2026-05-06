from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException

from models.shelters import (
    ShelterCapacityStatus,
    ShelterIn,
    ShelterOccupancyUpdate,
    ShelterOut,
    ShelterUpdate,
)
from database import get_pool

router = APIRouter(prefix="/shelters", tags=["shelters"])


@router.get("/", response_model=List[ShelterOut])
async def get_all_shelters(pool=Depends(get_pool)):
    """Get all shelters."""
    query = "SELECT * FROM haven_get_all_shelters()"
    async with pool.acquire() as conn:
        result = await conn.fetch(query)
    return [dict(row) for row in result]


@router.get("/active", response_model=List[ShelterOut])
async def get_active_shelters(pool=Depends(get_pool)):
    """Get only active shelters."""
    query = "SELECT * FROM haven_get_active_shelters()"
    async with pool.acquire() as conn:
        result = await conn.fetch(query)
    return [dict(row) for row in result]


@router.get("/{county}", response_model=List[ShelterOut])
async def get_shelters_by_county(county: str, pool=Depends(get_pool)):
    """Get shelters by county."""
    query = "SELECT * FROM haven_get_shelters_by_county($1)"
    async with pool.acquire() as conn:
        result = await conn.fetch(query, county)
    return [dict(row) for row in result]


@router.get("/{shelter_id}", response_model=ShelterOut)
async def get_shelter_by_id(shelter_id: UUID, pool=Depends(get_pool)):
    """Get a single shelter by ID."""
    query = "SELECT * FROM haven_get_shelter_by_id($1)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(query, shelter_id)
    if not result:
        raise HTTPException(status_code=404, detail="Shelter not found")
    return dict(result)


@router.get("/{shelter_id}/full", response_model=ShelterCapacityStatus)
async def is_shelter_full(shelter_id: UUID, pool=Depends(get_pool)):
    """Check if shelter is at capacity."""
    query = "SELECT * FROM haven_is_shelter_full($1)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(query, shelter_id)
    if not result:
        raise HTTPException(status_code=404, detail="Shelter not found")
    return dict(result)


@router.post("/add", response_model=ShelterOut)
async def create_shelter(shelter: ShelterIn, pool=Depends(get_pool)):
    """Add a new shelter."""
    query = "SELECT * FROM haven_create_shelter($1, $2, $3, $4, $5)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(
            query,
            shelter.name,
            shelter.subcounty,
            shelter.county,
            shelter.location,
            shelter.capacity
        )
    return dict(result)


@router.put("/{shelter_id}", response_model=ShelterOut)
async def update_shelter(shelter_id: UUID, shelter_update: ShelterUpdate, pool=Depends(get_pool)):
    """Update shelter details."""
    query = "SELECT * FROM haven_update_shelter($1, $2, $3, $4, $5)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(
            query,
            shelter_id,
            shelter_update.name,
            shelter_update.subcounty,
            shelter_update.county,
            shelter_update.capacity
        )
    if not result:
        raise HTTPException(status_code=404, detail="Shelter not found")
    return dict(result)


@router.patch("/{shelter_id}/occupancy", response_model=ShelterOut)
async def update_shelter_occupancy(shelter_id: UUID, occupancy_update: ShelterOccupancyUpdate, pool=Depends(get_pool)):
    """Update shelter occupancy."""
    query = "SELECT * FROM haven_update_shelter_occupancy($1, $2)"
    async with pool.acquire() as conn:
        result = await conn.fetchrow(query, shelter_id, occupancy_update.occupancy)
    if not result:
        raise HTTPException(status_code=404, detail="Shelter not found")
    return dict(result)


@router.delete("/{shelter_id}")
async def delete_shelter(shelter_id: UUID, pool=Depends(get_pool)):
    """Deactivate shelter and delete its resources."""
    query = "CALL haven_deactivate_shelter($1)"
    async with pool.acquire() as conn:
        await conn.execute(query, shelter_id)
    return {"message": "Shelter deactivated successfully"}
