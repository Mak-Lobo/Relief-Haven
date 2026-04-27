import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

pool= asyncpg.Pool

async def connect_db():
    global pool
    pool = await asyncpg.create_pool(DATABASE_URL, max_size=50)
    if pool:
        print("Database connection established")
    else:
        print("Failed to establish database connection")

async def disconnect_db():
    await pool.close()

def get_pool() -> asyncpg.Pool:
    return pool