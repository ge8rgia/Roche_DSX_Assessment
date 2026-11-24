# Question 6: GenAI Clinical Data Assistant (LLM & LangChain)

Develop a Generative AI Assistant that translates natural language questions into structured Pandas queries.

A clinical safety reviewer wants to ask free-text questions about the AE dataset. They don't know the column names. The following Agent must "understand" the dataset schema and route the question to the correct variable. 

---

### Package structure
```
question_6/
├── data/adae.csv     # pharmaverseadam::adae data saved in .csv format
├── agent.py          # Built agent script 
└── test_agent.py     # Test questions to run against the agent.py script
```

---

### Scripts

**agent.py**
- Schema definition of a selected 10 columns from the adae data
  - Columns used: AESEV, AETERM, AESOC, AEREL, AESER, AEOUT, ACTARM, TRTEMFL, SEX, AGEGR1
- Parsing executed using a mock LLM
  - mock_parse() uses key-word rules to turn a question into the required JSON output format
- Execution step validates the column against the schema, applies the pandas filter, and returns the count and list of unique subject IDs.
- Agent _ClinicalTrialDataAgent_ links the prompt, parse, and execute functions.

**test_agent.py** 
- Runs three example questions through the agent and prints the filtered output.
- Questions included:
  - Give me the subjects who had adverse events of moderate severity.
  - Which patients had a headache?
  - Show me patients with cardiac problems.
- Output from the test_agent.py script should look like the following:
  ```
  Question: Give me the subjects who had adverse events of moderate severity.
  Parsed: {'target_column': 'AESEV', 'filter_value': 'MODERATE'}
  Unique subjects: 136
  First 3 subject IDs: ['01-701-1023', '01-701-1047', '01-701-1097']
  ```

---

### Example Usage

```r
# Dependencies installed in Q5 can be used again as it includes pandas, which is the only dependency
# Otherwise:
conda install pandas

# Load the data from pharmaverseadam::adae (saved in question_6/data/ directory from R)
adae = pd.read_csv("data/adae.csv")

# Test the agent
python test_agent.py 
```
