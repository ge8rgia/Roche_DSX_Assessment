# Question 6: GenAI Clinical Data Assistant (LLM & LangChain)
# Test the agent 

from agent import ClinicalTrialDataAgent

agent = ClinicalTrialDataAgent()
print(f"Running in mode: {agent.mode}\n")

questions = [
    "Give me the subjects who had adverse events of moderate severity.",
    "Which patients had a headache?",
    "Show me patients with cardiac problems.",
]

for q in questions:
    r = agent.ask(q)
    print(f"Q: {r['question']}")
    print(f"   Parsed: {r['parsed']}")
    print(f"   Unique subjects: {r['count']}")
    print(f"   First 5 IDs: {r['subjects'][:5]}\n")