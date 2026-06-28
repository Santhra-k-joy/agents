import os
from typing import Dict

import requests
from openai import AsyncOpenAI
from dotenv import load_dotenv
load_dotenv()
from agents import Agent, function_tool, OpenAIChatCompletionsModel

AZURE_GIT_BASE_URL = "https://models.inference.ai.azure.com"
azure_git_client = AsyncOpenAI(base_url=AZURE_GIT_BASE_URL, api_key=os.environ.get("GITHUB_TOKEN"), timeout=60.0)
azure_git_model = OpenAIChatCompletionsModel(model="gpt-4.1-mini", openai_client=azure_git_client)

INSTRUCTIONS = """You are a travel notifier. You will be given a full trip itinerary in markdown.
Write a short, catchy headline (the 'subject') and a trimmed-down Telegram-friendly summary of the
itinerary (the 'body'). Keep the total message under ~3500 characters so it fits Telegram limits.
Use simple formatting (line breaks, emojis where appropriate) — no HTML tags.
Then call the send_telegram tool exactly once with the subject and body."""


@function_tool
def send_telegram(subject: str, body: str) -> Dict[str, str]:
    """Send a Telegram message with the given subject and body."""
    url = f"https://api.telegram.org/bot{os.getenv('TELEGRAM_BOT_TOKEN')}/sendMessage"
    text = f"{subject}\n\n{body}"
    payload = {"chat_id": os.getenv("TELEGRAM_CHAT_ID"), "text": text[:4000]}
    with requests.Session() as session:
        session.post(url, data=payload)
    return {"status": "success"}


notifier_agent = Agent(
    name="Notifier agent",
    instructions=INSTRUCTIONS,
    tools=[send_telegram],
    model=azure_git_model,
)
