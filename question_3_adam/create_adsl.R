# Question 3: ADaM ADSL Dataset Creation

# Load libraries
libs <- c("pharmaversesdtm", "admiral", "tidyverse")
invisible(lapply(libs, library, character.only = TRUE))

# Read in input SDTM data
dm <- pharmaversesdtm::dm
vs <- pharmaversesdtm::vs
ex <- pharmaversesdtm::ex
ds <- pharmaversesdtm::ds
ae <- pharmaversesdtm::ae

# The DM domain is used as the basis for ADSL
adsl <- dm %>%
  select(-DOMAIN) %>%                   # Remove DOMAIN as per ADSL article
  mutate(TRT01P = ARM, TRT01A = ACTARM) # Derive treatment variables (TRT01P, planned, and TRTO1A, actual)

# Derive AGEGR9 and AGEGR9N ----------------------------------------------------------------

## Age is provided in the adsl, and can be derived directly without need for deriving DRTHDT and AAGE

## Create lookup tables for ages
agegr9_lookup <- exprs(
  ~condition,             ~AGEGR9,
  AGE < 18,                 "<18",
  between(AGE, 18, 50),   "18-50",
  AGE > 50,                 ">50",
  is.na(AGE),            "Missing"  # Set uniquely for non-numeric input AGEGR9, not included in AGEGR9N
)
agegr9n_lookup <- exprs(
  ~condition,             ~AGEGR9N,
  AGE < 18,                     1,
  between(AGE, 18, 50),         2,
  AGE > 50,                     3,
)

## Add to adsl 
adsl <- adsl %>%
  derive_vars_cat(
    definition = agegr9_lookup
  ) %>%
  derive_vars_cat(
    definition = agegr9n_lookup
  )

# Derive numeric treatment start date-time (TRTSDTM) ---------------------------------------

## Use EX.EXSTDTC and convert to numeric date-time
## Derivations only include patients with a VALID dose
## Valid dose cases: EX.EXDOSE > 0, EX.EXDOSE == 0 + EX.EXTRT = 'PLACEBO'

ex_ext <- ex %>%
  derive_vars_dtm(                # Function creates a numeric datetime variable and an imputation flag
    dtc = EXSTDTC,                # Date used in function
    new_vars_prefix = "EXST",     # Generates EXSTTM (datetime) and EXSTDTF (flag) columns
    time_imputation = "00:00:00", # Missing time parts become 00
    ignore_seconds_flag = TRUE    # Does not generate a flag if only seconds were imputed
  )
### Note: When time is 00:00:00, it does not display in R

# Add TRTSDTM and TRTSTMF to the adsl 
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |                                          # Check for dose == 0
      (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM),  # Check for dose > 0 & PLACEBO
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  )

# Derive ITTFL: Identifying patients that have been randomized -----------------------------

## Condition for randomization: when ARM is populated in the dm domain

adsl <- adsl %>%
  mutate(
    ITTFL = case_when(
      !is.na(ARM) & ARM != "" ~ "Y",    # Checks for NA values and blank cells
      TRUE                    ~ "N"     
    )
  )

# Derive ABNSBPFL --------------------------------------------------------------------------

## Identifying patients with a supine systolic blood pressure <100 or >=140 mmHg
## Set to "Y" if: VS.VSTESTCD = "SYSBP" + VS.VSSTRESU = "mmHg" + VS.VSSTRESN >= 140 or <100
## Set to "N" if any of the three above mentioned conditions do not fit

adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = vs,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ABNSBPFL,
    condition = VSTESTCD == "SYSBP" & VSSTRESU == "mmHg" & (VSSTRESN >= 140 | VSSTRESN < 100),  # Conditions to be met
    true_value = "Y",
    false_value = "N",
    missing_value = "N"
  )

# Derive LSTALVDT: Last known alive date ---------------------------------------------------

## Uses: any vital signs date, adverse event start date, disposition record, and exposure record
## Extract the following:
### Last complete date of vital assessment: VS.VSSTRESN not null + VS.VSSTRESC not null + VS.VSDTC datepart not missing
### Last complete onset date of AEs: last datepart of AE.AESTDTC
### Last complete disposition date: last datepart of DS.DSSTDTC
### Last date of treatment administration: datepart of ADSL.TRTEDTM
## Value set to max date of the above criteria. 

# Make TRTEDTM column 
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |             # Check for dose == 0
                    (EXDOSE == 0 &         # Check for dose > 0 & PLACEBO
                       str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM),
    new_vars = exprs(TRTEDTM = EXSTDTM),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  )

# Derive LSTALVDT
adsl <- adsl %>%
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      # 1. Date of vital assessment
      event(
        dataset_name = "vs",
        condition = !is.na(VSSTRESN) & !is.na(VSSTRESC) & !is.na(convert_dtc_to_dt(VSDTC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(VSDTC),
          seq = VSSEQ
        )
      ),
      # Adverse Event (AE) onset date
      event(
        dataset_name = "ae",
        condition = !is.na(convert_dtc_to_dt(AESTDTC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(AESTDTC),
          seq = AESEQ
        )
      ),
      # Disposition date
      event(
        dataset_name = "ds",
        condition = !is.na(convert_dtc_to_dt(DSSTDTC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(DSSTDTC),
          seq = DSSEQ
        )
      ),
      # Last treatment administration
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDTM),
        set_values_to = exprs(
          LSTALVDT = date(TRTEDTM),
          seq = 0
        )
      )
    ),
    source_datasets = list(vs = vs, ae = ae, ds = ds, adsl = adsl),
    tmp_event_nr_var = event_nr,
    order = exprs(LSTALVDT, seq, event_nr),
    mode = "last",
    new_vars = exprs(LSTALVDT)
  )

# Derive CARPOPFL: Identifying patients with a cardiac adverse event -----------------------

## Set to "Y" if uppercase AE.AESOC = "CARDIAC DISORDERS"
## Set to missing if not the above

adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = CARPOPFL,
    condition = toupper(AESOC) == "CARDIAC DISORDERS", # Condition to be met
    true_value = "Y",
    false_value = NA_character_,
    missing_value = NA_character_
  )
