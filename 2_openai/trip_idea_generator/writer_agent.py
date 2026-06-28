from pydantic import BaseModel, Field
from agents import Agent

import os
from openai import AsyncOpenAI
from dotenv import load_dotenv
load_dotenv()
from agents import OpenAIChatCompletionsModel

AZURE_GIT_BASE_URL = "https://models.inference.ai.azure.com"
azure_git_client = AsyncOpenAI(base_url=AZURE_GIT_BASE_URL, api_key=os.environ.get("GITHUB_TOKEN"), timeout=60.0)
azure_git_model = OpenAIChatCompletionsModel(model="gpt-4.1-mini", openai_client=azure_git_client)

INSTRUCTIONS = (
    "You are a senior travel writer tasked with crafting a fun, exciting, and practical trip itinerary "
    "for the user. You will be given the original trip request and a set of research summaries from a "
    "travel assistant.\n\n"
    "First, sketch a short outline. Then write the final itinerary in markdown with these sections:\n"
    "1. **Trip Overview** — destination(s), vibe, best time to visit, rough budget per person.\n"
    "2. **Day-by-Day Itinerary** — for each day: morning / afternoon / evening with specific places, "
    "activities, and food recommendations.\n"
    "3. **Where to Stay** — 2-3 neighborhood or hotel suggestions across price ranges.\n"
    "4. **Food & Drink Highlights** — must-try dishes and standout restaurants/cafés/bars.\n"
    "5. **Getting Around** — flights, trains, transit, taxi/rideshare tips.\n"
    "6. **Pro Tips & Hidden Gems** — practical advice, scams to avoid, lesser-known spots.\n"
    "7. **Packing Checklist** — concise bullet list tailored to the destination and season.\n\n"
    "Keep the tone upbeat and fun, like a friend sending trip ideas. Aim for ~800-1500 words of "
    "rich, specific content (real place names, not generic filler)."
)


class TripPlan(BaseModel):
    short_summary: str = Field(description="A short 2-3 sentence teaser of the trip.")
    markdown_report: str = Field(description="The full markdown trip itinerary.")
    follow_up_questions: list[str] = Field(description="Suggested follow-up questions to refine the trip.")


writer_agent = Agent(
    name="TripWriterAgent",
    instructions=INSTRUCTIONS,
    model=azure_git_model,
    output_type=TripPlan,
)
