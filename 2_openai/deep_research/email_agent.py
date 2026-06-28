from agents import Agent, function_tool, ModelSettings
from messenger import send_email, push
import os
from dotenv import load_dotenv
load_dotenv(override=True)

MODEL_NAME = os.getenv("DEFAULT_MODEL_NAME", "gpt-5.4-mini")
USE_EMAIL = os.getenv("USE_EMAIL", "true").lower() == "true"

settings = ModelSettings(tool_choice="required")

<<<<<<< HEAD
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
=======
@function_tool
def send_email_tool(subject: str, text_body: str, html_body: str) -> str:
    """
    Send out an email with the given subject and body
    
    Args:
        subject: The subject of the email
        text_body: The body of the email as plain text
        html_body: The HTML body of the email
    """
    if USE_EMAIL:
        send_email(subject, text_body, html_body)
    else:
        push(f"Subject: {subject}\n\n{text_body}")
    return "Email sent successfully"


INSTRUCTIONS = """
You are provided with a detailed report. Use your tool to send an email, converting the report into
a clean, well presented HTML email with an appropriate subject line.
"""

email_agent = Agent(name="Email Agent", instructions=INSTRUCTIONS, tools=[send_email_tool], model=MODEL_NAME, model_settings=settings)
>>>>>>> main
