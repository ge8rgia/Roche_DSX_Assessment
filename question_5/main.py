# Question 5: Clinical Data API (FastAPI)

import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List

# Load the data from pharmaverseadam::adae (saved in question_5/data/ directory from R)
adae = pd.read_csv("data/adae.csv")

app = FastAPI()

# GET/ -------------------------------------------------------------------------------------------------------------------------------

@app.get("/")           # Return initial JSON welcome message
def root():
    return {"message": "Clinical Trial Data API is running."}

# POST/ae-query ----------------------------------------------------------------------------------------------------------------------

# Define BaseModel
class aeQuery(BaseModel):                              # Provides structure for the user to input required criteria
    severity: Optional[List[str]] = None               # Severity - can be a list of multiple or just one 
    treatment_arm: Optional[str] = None                # Treatment arm - can be any of the 3 from the adae dataset 

@app.post("/ae-query")
def Dynamic_Filtering(query: aeQuery):
    df = adae                                          # Begin with entire adae data frame 

    if query.severity is not None:                     # Identifies whether the user provided severity filters
        df = df[df["AESEV"].isin(query.severity)]

    if query.treatment_arm is not None:                # Identifies whether the user provided treatment arm filters
        df = df[df["ACTARM"] == query.treatment_arm]   

    return {                                           # Returns the JSON format list of all subject IDs matching the criteria
        "count": len(df),                              # Count of matching records
        "subjects": df["USUBJID"].unique().tolist()    # List of unique USUBJIDs in the cohort
        }

# GET/subject-risk/{subject_id} ------------------------------------------------------------------------------------------------------

@app.get("/subject-risk/{subject_id}")
def Calculation_Logic(subject_id: str):
    df = adae[adae["USUBJID"] == subject_id]                   # Select data relative only to the provided subject_id

    if df.empty:                                               # Return a 404 HTTP exception if the subject_id does not exist
        raise HTTPException(status_code=404, detail=f"Subject {subject_id} does not exist.")

    weight_score = {"MILD": 1, "MODERATE": 3, "SEVERE": 5}     # Weighted score based on AESEV
    risk_score = int(df["AESEV"].map(weight_score).sum())      # Convert AESEV to weighted scores and sum for a total risk_score

    if risk_score < 5:                                         # Assign the risk category: <5 => Low, <15 => Medium, >=15 => High
        risk_category = "Low"  
    elif risk_score < 15:         
        risk_category = "Medium" 
    else:
        risk_category = "High"

    return {                                                   # Returns the JSON format of information related to the listed subject_id
        "subject_id": subject_id,
        "risk_score": risk_score,
        "risk_category": risk_category
    }