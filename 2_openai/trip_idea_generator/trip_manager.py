import asyncio

from agents import Runner, trace, gen_trace_id

from search_agent import search_agent
from planner_agent import planner_agent, WebSearchItem, WebSearchPlan
from writer_agent import writer_agent, TripPlan
from notifier_agent import notifier_agent


class TripManager:

    async def run(self, query: str):
        """Run the trip-idea pipeline, yielding status updates and the final itinerary."""
        trace_id = gen_trace_id()
        with trace("Trip idea trace", trace_id=trace_id):
            print(f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}")
            yield f"View trace: https://platform.openai.com/traces/trace?trace_id={trace_id}"
            print("Planning trip research...")
            search_plan = await self.plan_searches(query)
            yield "Searches planned, exploring destinations..."
            search_results = await self.perform_searches(search_plan)
            yield "Research complete, drafting itinerary..."
            trip_plan = await self.write_itinerary(query, search_results)
            yield "Itinerary ready, sending to Telegram..."
            await self.notify(trip_plan)
            yield "Telegram sent — happy travels!"
            yield trip_plan.markdown_report

    async def plan_searches(self, query: str) -> WebSearchPlan:
        print("Planning searches...")
        result = await Runner.run(planner_agent, f"Trip request: {query}")
        print(f"Will perform {len(result.final_output.searches)} searches")
        return result.final_output_as(WebSearchPlan)

    async def perform_searches(self, search_plan: WebSearchPlan) -> list[str]:
        print("Searching...")
        num_completed = 0
        tasks = [asyncio.create_task(self.search(item)) for item in search_plan.searches]
        results: list[str] = []
        for task in asyncio.as_completed(tasks):
            result = await task
            if result is not None:
                results.append(result)
            num_completed += 1
            print(f"Searching... {num_completed}/{len(tasks)} completed")
        print("Finished searching")
        return results

    async def search(self, item: WebSearchItem) -> str | None:
        input_text = f"Search term: {item.query}\nReason for searching: {item.reason}"
        try:
            result = await Runner.run(search_agent, input_text)
            return str(result.final_output)
        except Exception:
            return None

    async def write_itinerary(self, query: str, search_results: list[str]) -> TripPlan:
        print("Drafting itinerary...")
        input_text = f"Original trip request: {query}\nResearch summaries: {search_results}"
        result = await Runner.run(writer_agent, input_text)
        print("Finished writing itinerary")
        return result.final_output_as(TripPlan)

    async def notify(self, trip_plan: TripPlan) -> None:
        print("Notifying via Telegram...")
        await Runner.run(notifier_agent, trip_plan.markdown_report)
        print("Telegram sent")
