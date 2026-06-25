import asyncpg
import os
from dotenv import load_dotenv
from loguru import logger

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

pool: asyncpg.Pool | None = None


async def connect_db():
    global pool
    pool = await asyncpg.create_pool(DATABASE_URL, max_size=15)  # max_size=15 is the default for Supabase
    if pool:
        logger.info("Database connection established")
    else:
        logger.error("Failed to establish database connection")


async def disconnect_db():
    if pool:
        await pool.close()


def get_pool() -> asyncpg.Pool:
    return pool
