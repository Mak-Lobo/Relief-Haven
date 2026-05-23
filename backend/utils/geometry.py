# utils/geometry.py
import re
from typing import Tuple

POINT_RE = re.compile(r"^POINT\s*\(\s*([-+]?\d+(?:\.\d+)?)\s+([-+]?\d+(?:\.\d+)?)\s*\)$")


def parse_wkt_point(wkt: str) -> Tuple[float, float]:
    match = POINT_RE.match(wkt)
    if not match:
        raise ValueError(f"Invalid WKT point: {wkt}")
    lon, lat = match.groups()
    return float(lon), float(lat)


def to_wkt_point(lon: float, lat: float) -> str:
    return f"POINT({lon} {lat})"


def validate_wkt_point(v: str) -> str:
    if not v.startswith("POINT("):
        raise ValueError("location must be WKT Point e.g. 'POINT(36.8219 -1.2921)'")
    return v
