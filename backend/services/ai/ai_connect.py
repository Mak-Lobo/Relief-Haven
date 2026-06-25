import os

from google.genai import Client
from dotenv import load_dotenv
from google.genai.types import GenerateContentConfig

from services.ai.instructions import instructions

load_dotenv()

ai_client = Client(api_key=os.getenv("GEMINI_API_KEY"))


# # response from Gemini
# resp = ai_client.models.generate_content(
#     model='gemini-3.1-flash-lite',
#     contents='Describe the Technnical University of Kenya',
# )


async def generate_content(message):
    resp = ai_client.models.generate_content(
        model='gemini-3.1-flash-lite',
        contents=message,
        config=GenerateContentConfig(
            system_instruction=instructions,
            temperature=0.4,
            max_output_tokens=270,
        )
    )

    return resp.text
