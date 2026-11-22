# Question 4.1: Summary Table using {gtsummary}

# Load libraries
libs <- c("dplyr", "gtsummary", "pharmaverseadam")
invisible(lapply(libs, library, character.only = TRUE))

# Read in input datasets
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# Create a summary table of treatment-emergent adverse events (TEAEs) ------------------

## Filter TEAE records that have TRTEMFL == "Y"
adae_select <- adae %>%
  filter(TRTEMFL == "Y")
## Removed 69 rows

## Rows: AETERM or AESOC 
## Columns: Treatment groups (ACTARM): Placebo, Xanomeline High Dose, Xanomeline Low Dose
## Cell values: Count (n) and Percentage (%)
## Include total row with all subjects
## Sort in descending frequency

tbl <- tbl_hierarchical(
  data = adae_select,
  variables = c(AESOC, AETERM),
  by = ACTARM,
  denominator = adsl,
  id = USUBJID,
  overall_row = TRUE, 
  label = list(..ard_hierarchical_overall.. = "Treatment Emergent AEs")
) %>%
  add_overall(last = TRUE) %>%
  sort_hierarchical(sort = "descending")

tbl

# Save file as html -------------------------------------------------------------------

tbl %>% as_gt() %>% gt::gtsave("outputs/ae_summary_table.html")
  
  
  