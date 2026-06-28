from agents import Agent, WebSearchTool, ModelSettings

import os
from openai import AsyncOpenAI
from dotenv import load_dotenv
load_dotenv()
from agents import OpenAIChatCompletionsModel

AZURE_GIT_BASE_URL = "https://models.inference.ai.azure.com"
azure_git_client = AsyncOpenAI(base_url=AZURE_GIT_BASE_URL, api_key=os.environ.get("GITHUB_TOKEN"), timeout=60.0)
azure_git_model = OpenAIChatCompletionsModel(model="gpt-4.1-mini", openai_client=azure_git_client)

INSTRUCTIONS = (
    "You are a travel research assistant. Given a search term related to a trip, you search the web "
    "and produce a concise summary of the most useful, traveler-relevant findings. The summary must "
    "be 2-3 paragraphs and less than 300 words. Capture concrete details that help plan a trip: "
    "names of places, neighborhoods, dishes, costs, opening hours, seasons, transit options, and any "
    "practical tips. Write succinctly; no need for complete sentences or perfect grammar. This will be "
    "consumed by someone synthesizing an itinerary, so it's vital you capture the essence and ignore "
    "fluff. Do not include any additional commentary other than the summary itself."
)

search_agent = Agent(
    name="Search agent",
    instructions=INSTRUCTIONS,
    tools=[WebSearchTool(search_context_size="low")],
    model=azure_git_model,
    model_settings=ModelSettings(tool_choice="required"),
)
