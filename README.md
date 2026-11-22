# DSX Data Scientist Coding Assessment 

This repository contains the code and outputs for the **Technical Interview** for the role of **ADS Programmer** at Roche. 

The purpose of this assessment was to evaluate skills in R Package Development, Clinical Data Programming, Data Manipulation and Derivations, and applying Python for data science. 

---

## Repository Structure

```
Roche_DSX_Assessment/
├── README.md
├── question_1/                            # Descriptive Statistics - R Package Development
│   └── descriptiveStats/                  # Repository containing package R script and package structure
│
├── question_2_sdtm                        # SDTM DS Domain Creation using {sdtm.oak}
│   ├── data/sdtm_ct.csv                   # Controlled terminology (metadata)
│   └── 02_create_ds_domain.R              # Script creating an STDM Disposition (DS) dataset from raw clinical data
│
├── question_3_adam                        # ADaM ADSL Dataset Creation
│   └── create_adsl.R                      # Script creating an ADSL (Subject level) dataset using SDTM source data
│
├── question_4_tlg                         # TLG - Adverse Events Reporting
│   ├── outputs/                           # Outputs from R scripts. Two HTML tables and two PNG plots
│   ├── 01_create_ae_summary_table.R       # Code generating outputs/ae_summary_table.html
│   ├── 02_create_visualizations.R         # Code generating outputs/plot1* and outputs/plot2*
│   └── 03_create_listings.R               # Code generating outputs/ae_listings.html
│
├── question_5                             # Clinical Data API (FastAPI)
│   ├── data/adae.csv                      # Data exported from pharmaversesdtm::adae 
│   └── main.py                            # Python script using FastAPI that calculates patient risk scores
│
└── question_6                             # GenAI Clinical Data Assistant (LLM & LangChain)
    ├── data/adae.csv                      # Data exported from pharmaversesdtm::adae
    ├── agent.py                           # Maps user intent to the correct dataset variable
    └── test_agent.py                      # Tests the AI Agent with example queries
``` 
All question directories contain their own README.md with execution instructions and data information.

---

## Environment & Installation

All analyses were conducted either on R version 4.5.1 or Python v3.14.10.

R scripts are self-contained and install required packages in individual scripts. 

A conda environment can be set up for the performance of questions 5 and 6 in Python.

```bash
# Dependencies required
conda install fastapi uvicorn pandas
```

---

## AI Use Statement

AI assistance was used with respect to the Technical Assessment guidelines. 

Claude Sonnet 5.5 was used as a guide for new concepts, notably variable explanations/definitions within the Q2-4 pharmaverse STDM and ADaM datasets, and sofware design/concept clarification within Q6. 

All code was written and is understood by the author, Georgia Goddard.
