# Question 4: TLG - Adverse Events Reporting

Create Tables, Listings, and Graphs (TLGs) for adverse events summary using the ADAE dataset and {gtsummary}.

### Package structure
```
descriptiveStats/
├── 01_create_ae_summary_table.R             # Summary Table using {gtsummary}
├── 02_create_visualizations.R               # Visualizations using {ggplot2)
├── 03_create_listings.R                     # Listing using {gtsummary}
└── outputs/            
    ├── ae_summary_table.html                # Output HTML table from 01*.R
    ├── plot1_ae_severity_by_treatment.png   # Output plot 1 from 02*.R
    ├── plot2_top10_frequent_ae.png          # Output plot 2 from 02*.R
    └── ae_listings.html                     # Output HTML table from 03*.R
```

---

### Outputs

**01_create_ae_summary_table.R**
- Summary table of treatment-emergent adverse events (TEAEs)
- Rows: AETERM or AESOC
- Columns: Treatment groups, ACTARM (Placebo, Xanomeline High Dose, Xanomeline Low Dose)

The table was generated to match the [reference table provided](https://pharmaverse.github.io/cardinal/quarto/catalog/fda-table_10/). 

**02_create_visualizations.R**
- _Plot 1_ : AE severity distribution by treatment (bar chart or heatmap).
  - AE Severity: AESEV variable from the adae dataset.
- _Plot 2_: Top 10 most frequent AEs (with 95% CI for incidence rates).
  - AEs: AETERM variable from the adae dataset.

The plots were generated to best match the reference outputs provided in the assessment guidelines. 

**03_create_listings.R**
- Create a detailed listing of all AEs
- Information provided: Subject ID, Treatment, AE Term, Severity, Relationship to drug, Start/End dates
- Filtered for treatment-emergent events
- Sorted by subject and event date

The table was generated to best match the reference output HTML provided in the assessment guidelines.

---

### Example Usage

All package requirements and steps are outlined within the scripts. The intended user just needs to open the script within their own directory and the code will run through on its own. All outputs will be saved in the **outputs/** folder.

```r
# Data required
pharmaverseadam::adae
pharmaverseadam::adsl
```
