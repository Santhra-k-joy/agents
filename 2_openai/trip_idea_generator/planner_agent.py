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

HOW_MANY_SEARCHES = 5

INSTRUCTIONS = f"""You are a travel research planner. Given a user's trip request \
(which may include destination ideas, budget, duration, vibe, season, group size, or interests), \
come up with a set of {HOW_MANY_SEARCHES} targeted web searches that will help build a great \
trip itinerary.

Cover a useful mix of: destination highlights, top attractions / things to do, best food spots, \
where to stay, transportation tips, hidden gems, seasonal events, and rough costs. Tailor the \
searches to the user's stated vibe (adventure, chill, foodie, cultural, family, etc.) and budget.

Output exactly {HOW_MANY_SEARCHES} search terms."""


class WebSearchItem(BaseModel):
    reason: str = Field(description="Why this search matters for planning the trip.")
    query: str = Field(description="The search term to use for the web search.")


class WebSearchPlan(BaseModel):
    searches: list[WebSearchItem] = Field(description="A list of web searches to perform to plan the trip.")


planner_agent = Agent(
    name="TripPlannerAgent",
    instructions=INSTRUCTIONS,
    model=azure_git_model,
    output_type=WebSearchPlan,
)
