from contextlib import asynccontextmanager

import asyncpg
from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from services.database import connect_db, disconnect_db, get_pool

from routes.user_routes import router as user_router
from routes.shelter_routes import router as shelter_router
from routes.donation_routes import router as donation_router
from routes.donation_routes import mpesa_router
from routes.chat_routes import router as chat_router
from routes.resource_routes import router as resource_router
from routes.nav_routes import router as nav_router

origins = [
    'http://localhost:8000',
    'http://10.0.2.2:8000',
    'http://localhost:5173',
    '*'
]


@asynccontextmanager
async def lifespan(app: FastAPI):
    await connect_db()  # runs on startup
    yield
    await disconnect_db()  # runs on shutdown


app = FastAPI(title="Relief Haven API", lifespan=lifespan)

app.include_router(user_router)
app.include_router(shelter_router)
app.include_router(donation_router)
app.include_router(mpesa_router)
app.include_router(chat_router)
app.include_router(resource_router)
app.include_router(nav_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root(pool: asyncpg.Pool = Depends(get_pool)):
    async with pool.acquire() as conn:
        rows = await conn.fetch("""
                                SELECT table_name
                                FROM information_schema.tables
                                WHERE table_schema = 'public'
                                ORDER BY table_name
                                """)
    return [row["table_name"] for row in rows]


@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}
