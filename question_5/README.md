# Question 5: Clinical Data API (FastAPI)

Create a RESTful API using FastAPI that serves clinical trial data, performs dynamic cohort analysis, and calculates patient risk scores. 

This task was completed using the FastAPI resources for API development, including the learning resource [FastAPI Request Body](https://fastapi.tiangolo.com/tutorial/body/) link provided in the assessment guidelines.

### Package structure
```
question_5/
├── data/adae.csv    # pharmaverseadam::adae data saved in .csv format
└── main.py          # Python script using FastAPI 
```

---

### Endpoints

**GET/**
- Returns startup running message in JSON format, confirming API is running.

**POST/ae-query** Dynamic Loading
- Filter data based on a dynamic payload
- JSON object with optional filters for: severities (AESEV) and/or treatment arm (ACTARM)
- Dataset is filtered to match criteria, returning all records if no filter is provided
- Output in JSON format reporting total counts and list of unique subject IDs

**GET/subject-risk/{subject_id}** Calculation Logic
- Calculates a "Safety Risk Score" for a specific patient
- First computes a weighted score based on severity (AESEV)
- Sums all the points to get a total risk_score
- Assigns one of three risk categories:
  - Low: score < 5
  - Medium: 5 <= score < 15
  - High: score >= 15
- Returns a 404 HTTP exception if the subject ID does not exist
- Output in JSON format reporting subject ID, risk score, and risk category

---

### Example Usage

```r
# Install dependencies
conda install fastapi uvicorn pandas

# Load the data from pharmaverseadam::adae (saved in question_5/data/ directory from R)
adae = pd.read_csv("data/adae.csv")

# Start the server
uvicorn main:app --reload

# Server startup will provide links to access the API and interactive documentation
## http://127.0.0.1:8000        -> for the API
## http://127.0.0.1:8000/docs   -> for the interactive documentation
 
```
