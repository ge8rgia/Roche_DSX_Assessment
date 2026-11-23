# Question 6: GenAI Clinical Data Assistant (LLM & LangChain)
# Test the agent 

from agent import ClinicalTrialDataAgent

agent = ClinicalTrialDataAgent()
print("Running with mock parse rules.\n")

questions = [
    "Give me the subjects who had adverse events of moderate severity.",
    "Which patients had a headache?",
    "Show me patients with cardiac problems.",
]

for q in questions:
    r = agent.ask(q)
    print(f"Question: {r['question']}")
    print(f"Parsed: {r['parsed']}")
    print(f"Unique subjects: {r['count']}")
    print(f"First 3 subject IDs: {r['subjects'][:3]}\n")