from pydantic import BaseModel, Field
from agents import Agent
from dotenv import load_dotenv
import os

<<<<<<< HEAD

import os
from openai import AsyncOpenAI
from dotenv import load_dotenv
load_dotenv()
from agents import Agent, Runner, trace, function_tool, OpenAIChatCompletionsModel
AZURE_GIT_BASE_URL = "https://models.inference.ai.azure.com"
azure_git_client = AsyncOpenAI(base_url=AZURE_GIT_BASE_URL, api_key=os.environ.get("GITHUB_TOKEN"), timeout=60.0)
azure_git_model = OpenAIChatCompletionsModel(model="gpt-4.1-mini", openai_client=azure_git_client)

INSTRUCTIONS = (
    "You are a senior researcher tasked with writing a cohesive report for a research query. "
    "You will be provided with the original query, and some initial research done by a research assistant.\n"
    "You should first come up with an outline for the report that describes the structure and "
    "flow of the report. Then, generate the report and return that as your final output.\n"
    "The final output should be in markdown format, and it should be lengthy and detailed. Aim "
    "for 5-10 pages of content, at least 1000 words."
)
=======
load_dotenv(override=True)
MODEL_NAME = os.getenv("DEFAULT_MODEL_NAME", "gpt-5.4-mini")

INSTRUCTIONS = """
You are a senior researcher tasked with writing a cohesive report for a research query.
You will be provided with the original query, and some research.
Generate a comprehensive report based on the research and the query.
The final output should be in markdown format, and it should be lengthy and detailed. Aim 
for 5-10 pages of content, at least 1000 words.
"""
>>>>>>> main


class ReportData(BaseModel):
    short_summary: str = Field(description="A short 2-3 sentence summary of the findings.")
    markdown_report: str = Field(description="The final report")
    follow_up_questions: list[str] = Field(description="Suggested topics to research further")


<<<<<<< HEAD
writer_agent = Agent(
    name="WriterAgent",
    instructions=INSTRUCTIONS,
    model=azure_git_model,
    output_type=ReportData,
)
=======
writer_agent = Agent(name="Writer Agent", instructions=INSTRUCTIONS, model=MODEL_NAME, output_type=ReportData)
>>>>>>> main
