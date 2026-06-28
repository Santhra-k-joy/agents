from pydantic import BaseModel, Field
from agents import Agent
import os
from dotenv import load_dotenv
load_dotenv(override=True)

<<<<<<< HEAD

import os
from openai import AsyncOpenAI
from dotenv import load_dotenv
load_dotenv()
from agents import Agent, Runner, trace, function_tool, OpenAIChatCompletionsModel
AZURE_GIT_BASE_URL = "https://models.inference.ai.azure.com"
azure_git_client = AsyncOpenAI(base_url=AZURE_GIT_BASE_URL, api_key=os.environ.get("GITHUB_TOKEN"), timeout=60.0)
azure_git_model = OpenAIChatCompletionsModel(model="gpt-4.1-mini", openai_client=azure_git_client)

HOW_MANY_SEARCHES = 5
=======
MODEL_NAME = os.getenv("DEFAULT_MODEL_NAME", "gpt-5.4-mini")
HOW_MANY_SEARCHES = int(os.getenv("HOW_MANY_SEARCHES", 5))
>>>>>>> main


INSTRUCTIONS = f"""
You are a research assistant. Given a user query, come up with a set of web searches
to perform to best answer the query. Output {HOW_MANY_SEARCHES} terms to query for.
"""

class WebSearchItem(BaseModel):
    reason: str = Field(description="Your reasoning for why this search is important to the query.")
    query: str = Field(description="The search term to use for the web search.")


class WebSearchPlan(BaseModel):
    searches: list[WebSearchItem] = Field(description="A list of web searches to perform to best answer the query.")
    
<<<<<<< HEAD
planner_agent = Agent(
    name="PlannerAgent",
    instructions=INSTRUCTIONS,
    model=azure_git_model,
    output_type=WebSearchPlan,
)
=======
planner_agent = Agent(name="Planner Agent", instructions=INSTRUCTIONS, model=MODEL_NAME, output_type=WebSearchPlan)
>>>>>>> main
