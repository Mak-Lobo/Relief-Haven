from uuid import UUID

from fastapi import APIRouter, HTTPException, Depends
import logging

from ai_connect import generate_content
from database import get_pool
from models.chat import ChatLogIn, ChatLogOut

router = APIRouter(prefix="/chat", tags=["chat"])

logger = logging.getLogger("uvicorn.error")

pool = get_pool()


@router.post("/new", response_model=ChatLogOut)
async def gen_new_chat(chat: ChatLogIn, pool=Depends(get_pool)):
    try:
        response = await generate_content(chat.prompt)

        if response is None:
            raise HTTPException(status_code=404, detail="Failed to generate response")

        query = "SELECT * FROM haven_create_chat_log($1, $2, $3)"
        async with pool.acquire() as conn:
            result = await conn.fetchrow(query, chat.user_id, chat.prompt, response)

            logger.info(f'Prompt: {chat.prompt}. \n\tResponse: {response}')
            return dict(result)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{user_id}", response_model=list[ChatLogOut])
async def chats_by_user_id(user_id: UUID, pool=Depends(get_pool)):
    try:
        query = "Select * from haven_get_chat_history($1)"
        async with pool.acquire() as conn:
            result = await conn.fetch(query, user_id)

            if not result:
                logger.error(f'Data is empty')
                return []
            logger.info(f'User ID: {user_id}')
            return [dict(row) for row in result]

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{chat_id}")
async def delete_chat(chat_id: UUID, pool=Depends(get_pool)):
    try:
        query = "Select * from haven_delete_chat_log($1)"

        async with pool.acquire() as conn:
            await conn.execute(query, chat_id)

        logger.info(f'Chat ID: {chat_id}')
        return {"message": "Chat deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
