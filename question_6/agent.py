# Question 6: GenAI Clinical Data Assistant (LLM & LangChain)
# Build the agent

## Notes on the following code --------------------------------------------------------------------------------------------------------

# The following program takes a question (e.g., What patients had a headache?)
# It then identifies which columns of the data to select and which values, before returning a reduced list of matching subjects.

# I do not have an OpenAI API key, so a mock response was created instead
# The prompt -> parse -> execute logic flow is still complete and readable

## ------------------------------------------------------------------------------------------------------------------------------------

import pandas as pd
import os
from pydantic import BaseModel
import re

# Load the data from pharmaverseadam::adae (saved in question_6/data/ directory from R)
adae = pd.read_csv("data/adae.csv")

# Schema Definition -------------------------------------------------------------------------------------------------------------------
# Using a set of 10 variables to keep the schema to AE-relevant columns to reduce noise and LLM cost.
# The LLM would read this test in order to pick a column.
# Due to time constraints, the following descriptions were AI-generated and checked by the author. 

schema_descriptions = {
    "AESEV": (
        "Severity or intensity of the adverse event. "
        "Use when the question mentions severity, intensity, or how bad an event was. "
        "Values: MILD, MODERATE, SEVERE."
    ),
    "AETERM": (
        "Specific condition or symptom reported (the event itself). "
        "Use when the question names a particular condition, e.g. headache, nausea, rash, pruritus. "
        "Values are uppercase text, e.g. HEADACHE, RASH, APPLICATION SITE PRURITUS."
    ),
    "AESOC": (
        "Body system or organ class the event belongs to. "
        "Use when the question names a body system, e.g. cardiac, skin, nervous system, gastrointestinal. "
        "Values: CARDIAC DISORDERS, SKIN AND SUBCUTANEOUS TISSUE DISORDERS, "
        "NERVOUS SYSTEM DISORDERS, GASTROINTESTINAL DISORDERS, etc."
    ),
    "AEREL": (
        "Relationship of the event to the study drug (causality). "
        "Use when the question asks if an event was related, caused by, or linked to treatment. "
        "Values: PROBABLE, POSSIBLE, REMOTE, NONE."
    ),
    "AESER": (
        "Whether the event was a serious adverse event (SAE). "
        "Use when the question says serious or SAE. "
        "Values: Y (serious), N (not serious)."
    ),
    "AEOUT": (
        "Outcome of the adverse event. "
        "Use when the question asks about recovery, resolution, or fatal events. "
        "Values: RECOVERED/RESOLVED, NOT RECOVERED/NOT RESOLVED, FATAL."
    ),
    "ACTARM": (
        "Treatment arm the subject actually received. "
        "Use when the question mentions placebo, drug, or dose group. "
        "Values: Placebo, Xanomeline Low Dose, Xanomeline High Dose."
    ),
    "TRTEMFL": (
        "Treatment-emergent flag: event started or worsened after the first dose. "
        "Use when the question says treatment-emergent or TEAE. "
        "Values: Y (treatment-emergent), blank otherwise."
    ),
    "SEX": (
        "Sex of the subject. "
        "Use when the question mentions male, female, men, or women. "
        "Values: M (male), F (female)."
    ),
    "AGEGR1": (
        "Age group of the subject. "
        "Use when the question mentions elderly, older, younger, or an age band. "
        "Values: >64 (elderly), 18-64."
    ),
}

# Parsing -----------------------------------------------------------------------------------------------------------------------------
# The rules below identify which columns should be filtered and which value targeted, based on the prompt provided

rules = [
    (["mild"],                   "AESEV",   "MILD"),
    (["moderate"],               "AESEV",   "MODERATE"),
    (["severe", "severity"],     "AESEV",   "SEVERE"),
    (["serious", "sae"],         "AESER",   "Y"),
    (["fatal", "death", "died"], "AEOUT",   "FATAL"),
    (["headache"],               "AETERM",  "HEADACHE"),
    (["nausea"],                 "AETERM",  "NAUSEA"),
    (["cardiac", "heart"],       "AESOC",   "CARDIAC DISORDERS"),
    (["skin"],                   "AESOC",   "SKIN AND SUBCUTANEOUS TISSUE DISORDERS"),
    (["nervous"],                "AESOC",   "NERVOUS SYSTEM DISORDERS"),
    (["gastro", "stomach"],      "AESOC",   "GASTROINTESTINAL DISORDERS"),
    (["female", "women"],        "SEX",     "F"),
    (["male", "men"],            "SEX",     "M"),
    (["elderly", "older"],       "AGEGR1",  ">64"),
    (["placebo"],                "ACTARM",  "Placebo"),
    (["high dose"],              "ACTARM",  "Xanomeline High Dose"),
    (["low dose"],               "ACTARM",  "Xanomeline Low Dose"),
]

# The following is a mock replacement for the actual LLM.
# It filters the question into a structured JSON output with target_column and filter_value
def mock_parse(question: str) -> dict:

    q = question.lower()                                         # lowercase so "Headache" and "headache" both match
    for keywords, column, value in rules:
        for word in keywords:
            if re.search(r"\b" + re.escape(word) + r"\b", q):    # \b looks for whole word only (avoid 'male' 'female' confusion)
                return {"target_column": column, "filter_value": value}
    raise ValueError(f"Mock LLM cannot filter for this question: '{question}'")


# Execution -----------------------------------------------------------------------------------------------------------------------------

# Free-text columns: partial, case-insensitive match ("cardiac" matches "CARDIAC DISORDERS")
CONTAINS_COLUMNS = {"AETERM", "AESOC"}

def execute_filter(parsed: dict) -> dict:
    column = parsed["target_column"]
    value = str(parsed["filter_value"])

    if column not in schema_descriptions:                           # Only allow columns provided within the schema
        raise ValueError(f"Unknown column '{column}'. Data available: {list(schema_descriptions)}")
 
    col = adae[column].astype(str).str.upper()                      # Convert column to uppercase 

    if column in CONTAINS_COLUMNS:
        mask = col.str.contains(value.upper(), regex=False)         # Partial match
    else:
        mask = col == value.upper()                                 # Exact match

    subjects = sorted(adae.loc[mask, "USUBJID"].unique().tolist())  # Keep unique patient IDs
    return {"count": len(subjects), "subjects": subjects}

# Agent ----------------------------------------------------------------------------------------------------------------------------------

class ClinicalTrialDataAgent:

    def parse_question(self, question: str) -> dict:
        return mock_parse(question)                     # Parse step: Turn question into column - value

    def ask(self, question: str) -> dict:
        parsed = self.parse_question(question)
        result = execute_filter(parsed)
        return {"question": question, "parsed": parsed, **result}
