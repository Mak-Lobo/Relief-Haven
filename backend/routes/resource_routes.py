from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException

from database import get_pool
from models.resource import ResourceIn, ResourceOut, ResourceUpdate

router = APIRouter(prefix="/resources", tags=["resources"])


def _resource_row_to_dict(row) -> dict:
    resource = dict(row)
    resource["food"] = int(resource["food"])
    resource["water"] = int(resource["water"])
    resource["medical"] = int(resource["medical"])
    return resource


@router.get("/shelter/{shelter_id}", response_model=List[ResourceOut])
async def get_shelter_resources(shelter_id: UUID, pool=Depends(get_pool)):
    query = "SELECT * FROM haven_get_shelter_resources($1)"
    async with pool.acquire() as conn:
        rows = await conn.fetch(query, shelter_id)
    return [_resource_row_to_dict(row) for row in rows]


@router.get("/{resource_id}", response_model=ResourceOut)
async def get_resource_by_id(resource_id: UUID, pool=Depends(get_pool)):
    """Get a single resource record by ID."""
    query = "SELECT * FROM haven_get_resource_by_id($1)"
    async with pool.acquire() as conn:
        row = await conn.fetchrow(query, resource_id)
    if not row:
        raise HTTPException(status_code=404, detail="Resource not found")
    return _resource_row_to_dict(row)


@router.post("/add", response_model=ResourceOut)
async def create_resource(resource: ResourceIn, pool=Depends(get_pool)):
    """Add a resource record for a shelter."""
    query = "SELECT * FROM haven_create_resource($1::uuid, $2::integer, $3::integer, $4::integer, $5::text)"
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            query,
            resource.shelter_id,
            resource.food,
            resource.water,
            resource.medical,
            resource.add_notes,
        )
    return _resource_row_to_dict(row)


@router.put("/{resource_id}", response_model=ResourceOut)
async def update_resource(
        resource_id: UUID,
        resource_update: ResourceUpdate,
        pool=Depends(get_pool),
):
    """Update resource availability."""
    query = "SELECT * FROM haven_update_resource($1::uuid, $2::integer, $3::integer, $4::integer, $5::text)"
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            query,
            resource_id,
            resource_update.food,
            resource_update.water,
            resource_update.medical,
            resource_update.add_notes,
        )
    if not row:
        raise HTTPException(status_code=404, detail="Resource not found")
    return _resource_row_to_dict(row)


@router.delete("/{resource_id}")
async def delete_resource(resource_id: UUID, pool=Depends(get_pool)):
    """Delete a resource record."""
    async with pool.acquire() as conn:
        existing = await conn.fetchrow(
            "SELECT * FROM haven_get_resource_by_id($1)",
            resource_id,
        )
        if not existing:
            raise HTTPException(status_code=404, detail="Resource not found")
        await conn.execute("SELECT haven_delete_resource($1)", resource_id)
    return {"message": "Resource deleted successfully"}
