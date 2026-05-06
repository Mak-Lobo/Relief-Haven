import os

from dotenv import load_dotenv

load_dotenv()

CONSUMER_KEY = os.getenv('MPESA_CONSUMER_KEY')
CONSUMER_SECRET = os.getenv('MPESA_CONSUMER_SECRET')
SHORTCODE = os.getenv('MPESA_SHORTCODE')
PASSKEY = os.getenv('MPESA_PASSKEY')
CALLBACK_URL = os.getenv('MPESA_CALLBACK_URL')

MPESA_CONFIG = dict(
    consumer_key=os.getenv("MPESA_CONSUMER_KEY"),
    consumer_secret=os.getenv("MPESA_CONSUMER_SECRET"),
    shortcode=os.getenv("MPESA_SHORTCODE", "174379"),
    passkey=os.getenv("MPESA_PASSKEY"),
    callback_url=os.getenv("MPESA_CALLBACK_URL"),
    environment="sandbox",
)
