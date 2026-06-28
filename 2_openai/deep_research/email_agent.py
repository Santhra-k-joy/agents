import os
from typing import Dict

import sendgrid
from sendgrid.helpers.mail import Email, Mail, Content, To
from agents import Agent, function_tool


# @function_tool
# def send_email(subject: str, html_body: str) -> Dict[str, str]:
#     """Send an email with the given subject and HTML body"""
#     sg = sendgrid.SendGridAPIClient(api_key=os.environ.get("SENDGRID_API_KEY"))
#     from_email = Email("ed@edwarddonner.com")  # put your verified sender here
#     to_email = To("ed.donner@gmail.com")  # put your recipient here
#     content = Content("text/html", html_body)
#     mail = Mail(from_email, to_email, subject, content).get()
#     response = sg.client.mail.send.post(request_body=mail)
#     print("Email response", response.status_code)
#     return "success"


from openai import AsyncOpenAI
from dotenv import load_dotenv
load_dotenv()
from agents import Agent, Runner, trace, function_tool, OpenAIChatCompletionsModel
AZURE_GIT_BASE_URL = "https://models.inference.ai.azure.com"
azure_git_client = AsyncOpenAI(base_url=AZURE_GIT_BASE_URL, api_key=os.environ.get("GITHUB_TOKEN"), timeout=60.0)
azure_git_model = OpenAIChatCompletionsModel(model="gpt-4.1-mini", openai_client=azure_git_client)

INSTRUCTIONS = """You are able to send a nicely formatted HTML email based on a detailed report.
You will be provided with a detailed report. You should use your tool to send one email, providing the 
report converted into clean, well presented HTML with an appropriate subject line."""


import requests
@function_tool
def send_email(subject: str, html_body: str) -> Dict[str, str]:
    url = f"https://api.telegram.org/bot{os.getenv('TELEGRAM_BOT_TOKEN')}/sendMessage"
    payload = {"chat_id": os.getenv("TELEGRAM_CHAT_ID"), "text": subject + html_body}
    with requests.Session() as session:
        session.post(url, data=payload)
    return {"status": "success"}

email_agent = Agent(
    name="Email agent",
    instructions=INSTRUCTIONS,
    tools=[send_email],
    model=azure_git_model,
)
