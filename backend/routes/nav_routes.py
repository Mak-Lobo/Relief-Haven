# routers/navigate.py
from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from loguru import logger

from services.database import get_pool
from models.nav_logs import NavLogIn, NavLogOut, NearestShelterOut, RouteOut, NavLogHistoryOut
from services.routing import calculate_route_matrix, calculate_route_directions
from utils.geometry import parse_wkt_point, to_wkt_point

router = APIRouter(prefix="/navigate", tags=["navigate"])


async def fetch_available_shelters(
        pool,
        lon: float,
        lat: float,
        limit: int = 50
) -> list[dict]:
    # Fetching active shelters within a given proximity
    query = """
            SELECT shelter_id,
                   name,
                   subcounty,
                   county,
                   ST_AsText(location) AS location,
                   capacity,
                   occupancy,
                   is_active,
                   updated_at,
                   added_at
            FROM shelters
            WHERE is_active = TRUE
              AND occupancy < capacity
            ORDER BY ST_DistanceSphere(
                             location,
                             ST_SetSRID(ST_MakePoint($1, $2), 4326)
                     )
                LIMIT $3
            """
    async with pool.acquire() as conn:
        rows = await conn.fetch(query, lon, lat, limit)

    shelters = []
    for row in rows:
        shelter = dict(row)
        try:
            shelter["coordinates"] = parse_wkt_point(shelter["location"])
            shelters.append(shelter)
        except ValueError:
            continue
    return shelters


async def fetch_shelter_by_id(pool, shelter_id: UUID) -> dict:
    """Retrieve single shelter by ID."""
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT * FROM haven_get_shelter_by_id($1)",
            shelter_id
        )
    if not row:
        raise HTTPException(status_code=404, detail="Shelter not found")

    shelter = dict(row)
    if not shelter["is_active"]:
        raise HTTPException(status_code=400, detail="Shelter is inactive")
    if shelter["occupancy"] >= shelter["capacity"]:
        raise HTTPException(status_code=400, detail="Shelter is full")

    return shelter


@router.get("/nearest", response_model=List[NearestShelterOut])
async def get_nearest_shelters(
        latitude: float = Query(..., ge=-90, le=90),
        longitude: float = Query(..., ge=-180, le=180),
        limit: int = Query(5, ge=1, le=25),
        candidate_limit: int = Query(50, ge=1, le=100),
        profile: str = Query("driving"),
        pool=Depends(get_pool),
):
    """Return shelters ranked by actual route distance (OSRM)."""
    logger.info(f"Fetching nearest shelters for lat={latitude}, lon={longitude}")
    shelters = await fetch_available_shelters(pool, longitude, latitude, candidate_limit)
    if not shelters:
        return []

    # Build location matrix: user + all shelter coordinates
    origin = [longitude, latitude]
    destinations = [[s["coordinates"][0], s["coordinates"][1]] for s in shelters]

    logger.debug(f"Calculating route matrix for {len(destinations)} candidates")
    matrix = await calculate_route_matrix(origin, destinations, profile)

    # Attach distance/duration to each shelter
    distances = matrix.distances[0] if matrix.distances else []
    durations = matrix.durations[0] if matrix.durations else []

    ranked = []
    for i, shelter in enumerate(shelters):
        if i >= len(distances) or distances[i] is None:
            continue

        ranked.append({
            **shelter,
            "distance_meters": float(distances[i]),
            "distance_km": round(float(distances[i]) / 1000, 2),
            "duration_seconds": float(durations[i]) if i < len(durations) and durations[i] else None
        })

    ranked.sort(key=lambda s: s["distance_meters"])
    return ranked[:limit]


@router.get("/route/{shelter_id}", response_model=RouteOut)
async def get_route_to_shelter(
        shelter_id: UUID,
        latitude: float = Query(..., ge=-90, le=90),
        longitude: float = Query(..., ge=-180, le=180),
        profile: str = Query("driving"),
        pool=Depends(get_pool),
):
    """Get full route geometry from user location to specific shelter."""
    logger.info(f"Route request: shelter={shelter_id}, origin=({latitude}, {longitude})")
    try:
        shelter = await fetch_shelter_by_id(pool, shelter_id)
        logger.debug(f"Found shelter: {shelter['name']}")

        dest_lon, dest_lat = parse_wkt_point(shelter["location"])

        logger.debug(f"Requesting OSRM directions to {dest_lon}, {dest_lat}")
        route = await calculate_route_directions(
            [longitude, latitude],
            [dest_lon, dest_lat],
            profile
        )
        logger.info(f"Route calculated: {route.distance}m, {len(route.geometry)} points")

        return {
            "shelter_id": shelter["shelter_id"],
            "name": shelter["name"],
            "location": shelter["location"],
            "distance_meters": float(route.distance),
            "distance_km": round(float(route.distance) / 1000, 2),
            "duration_seconds": float(route.duration) if route.duration else None,
            "geometry": route.geometry or []
        }
    except Exception as e:
        logger.exception(f"Critical error in get_route_to_shelter: {e}")
        raise


@router.post("/logs", response_model=NavLogOut)
async def create_nav_log(nav_log: NavLogIn, pool=Depends(get_pool)):
    """Create navigation log entry."""
    async with pool.acquire() as conn:
        # Explicitly select columns to avoid AmbiguousColumnError
        row = await conn.fetchrow(
            "SELECT * FROM haven_create_nav_log($1, $2, $3, $4)",
            nav_log.user_id,
            nav_log.shelter_id,
            nav_log.location,
            nav_log.distance
        )
    return dict(row)


@router.post("/logs/auto", response_model=NavLogOut)
async def create_nav_log_auto(
        user_id: UUID,
        shelter_id: UUID,
        latitude: float = Query(..., ge=-90, le=90),
        longitude: float = Query(..., ge=-180, le=180),
        profile: str = Query("driving"),
        pool=Depends(get_pool),
):
    """Create nav log by auto-calculating route distance."""
    route = await get_route_to_shelter(shelter_id, latitude, longitude, profile, pool)

    nav_log = NavLogIn(
        user_id=user_id,
        shelter_id=shelter_id,
        location=to_wkt_point(longitude, latitude),
        distance=route["distance_km"]
    )
    return await create_nav_log(nav_log, pool)


@router.get("/logs/user/{user_id}", response_model=List[NavLogHistoryOut])
async def get_user_nav_logs(user_id: UUID, pool=Depends(get_pool)):
    """Retrieve all navigation logs for a user."""
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT * FROM haven_get_nav_logs_by_user($1)",
            user_id
        )
    return [dict(row) for row in rows]


@router.get("/logs/{navigation_id}", response_model=NavLogOut)
async def get_nav_log(navigation_id: UUID, pool=Depends(get_pool)):
    """Retrieve single navigation log by ID."""
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT * FROM haven_get_nav_log_by_id($1)",
            navigation_id
        )
    if not row:
        raise HTTPException(status_code=404, detail="Navigation log not found")
    return dict(row)


@router.delete("/logs/{navigation_id}")
async def delete_nav_log(navigation_id: UUID, pool=Depends(get_pool)):
    """Delete navigation log entry."""
    async with pool.acquire() as conn:
        existing = await conn.fetchrow(
            "SELECT 1 FROM haven_get_nav_log_by_id($1)",
            navigation_id
        )
        if not existing:
            raise HTTPException(status_code=404, detail="Navigation log not found")

        await conn.execute("SELECT haven_delete_nav_log($1)", navigation_id)

    return {"message": "Navigation log deleted"}
