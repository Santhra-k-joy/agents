import gradio as gr
from dotenv import load_dotenv
from trip_manager import TripManager

load_dotenv(override=True)


async def run(query: str):
    async for chunk in TripManager().run(query):
        yield chunk


with gr.Blocks(theme=gr.themes.Default(primary_hue="emerald")) as ui:
    gr.Markdown("# Trip Idea Generator")
    gr.Markdown(
        "Tell me roughly where you want to go, your budget, how many days, and the vibe "
        "(adventure / chill / foodie / cultural / family / etc.) — I'll plan it for you."
    )
    query_textbox = gr.Textbox(
        label="What kind of trip are you dreaming about?",
        placeholder="e.g. 5 days in Japan in spring, mid-budget, foodie + culture vibe",
    )
    run_button = gr.Button("Plan my trip", variant="primary")
    report = gr.Markdown(label="Itinerary")

    run_button.click(fn=run, inputs=query_textbox, outputs=report)
    query_textbox.submit(fn=run, inputs=query_textbox, outputs=report)

ui.launch(inbrowser=True)
