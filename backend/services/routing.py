# services/routing.py
from functools import lru_cache
from routingpy.routers import OSRM
from fastapi import HTTPException


@lru_cache(maxsize=1)
def get_osrm_client() -> OSRM:
    """Singleton OSRM client with connection pooling."""
    try:
        return OSRM(timeout=20)
    except ModuleNotFoundError:
        raise HTTPException(
            status_code=503,
            detail="routingpy not installed. Install via: pip install routingpy"
        )


async def calculate_route_matrix(
        origin: list[float],
        destinations: list[list[float]],
        profile: str = "driving"
):
    """Calculate distance/duration matrix from origin to multiple destinations."""
    import asyncio
    client = get_osrm_client()
    locations = [origin] + destinations

    try:
        matrix = await asyncio.to_thread(
            client.matrix,
            locations=locations,
            profile=profile,
            sources=[0],
            destinations=list(range(1, len(locations))),
            annotations=["duration", "distance"]
        )
        return matrix
    except Exception as exc:
        raise HTTPException(
            status_code=502,
            detail=f"OSRM matrix failed: {exc}"
        ) from exc


async def calculate_route_directions(
        origin: list[float],
        destination: list[float],
        profile: str = "driving"
):
    """Get full route geometry and metadata."""
    import asyncio
    client = get_osrm_client()

    try:
        route = await asyncio.to_thread(
            client.directions,
            locations=[origin, destination],
            profile=profile,
            geometries="geojson",
            overview="full"
        )
        return route
    except Exception as exc:
        raise HTTPException(
            status_code=502,
            detail=f"OSRM directions failed: {exc}"
        ) from exc
