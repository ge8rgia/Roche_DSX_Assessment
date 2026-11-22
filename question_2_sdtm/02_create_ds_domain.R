# Question 2: SDTM DS Domain Creating using {sdtm.oak}

# Load libraries
libs <- c("sdtm.oak", "pharmaverseraw", "dplyr")
invisible(lapply(libs, library, character.only = TRUE))

# Load data and terminology
ds_raw <- pharmaverseraw::ds_raw
sdtm_ct <- read.csv("~/Desktop/Roche_DSX_Assessment/question_2_sdtm/data/sdtm_ct.csv")

# Generate oak_id_vars -----------------------------------------------------------------------
## Adds 3 columns: oak_id, raw_source, and patient_number
## Done so column information is retained as data is added. 
ds_raw <- ds_raw %>% 
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

# Create DS Domain ---------------------------------------------------------------------------
## Topic variable = IT.DSDECOD
ds <-
  assign_no_ct(
    raw_dat = ds_raw,
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )

# Map Rest of the Variables ------------------------------------------------------------------

ds <- ds %>%
  # Map OTHERSP to DSTERM when OTHERSP not null
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  ) %>%
  # Map IT.DSDECOD to DSDECOD when OTHERSP is null
  ## Codelist = C66727
  assign_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    ct_spec = sdtm_ct,
    ct_clst = "C66727",
    id_vars = oak_id_vars()
  ) %>%
  # Map OTHERSP to DSDECOD when OTHERSP not null
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  # DSCAT = PROTOCOL MILESTONE when IT.DSDECOD = Randomized
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, IT.DSDECOD == "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = oak_id_vars()
  ) %>%
  # DSCAT = DISPOSITION EVENT for every other non-null value in IT.DSDECOD
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(IT.DSDECOD) & IT.DSDECOD != "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "DISPOSITION EVENT",
    id_vars = oak_id_vars()
  ) %>%
  # DSCAT = OTHER EVENT when OTHERSP is not null
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    id_vars = oak_id_vars()
  ) %>%
  # Map IT.DSSTDAT to DSSTDTC
  ## Change date format from MM-DD-YYYY to the ISO8601 format YYYY-MM-DD
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("m-d-y"),
    id_vars = oak_id_vars()
  ) %>%
  # Map DSDTCOL (date) and DSTMCOL (time) to DSDTC 
  ## Change format to ISO8601 date-time structure
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("DSDTCOL", "DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c("m-d-y", "H:M"),
    id_vars = oak_id_vars()
  ) %>%
  # Map INSTANCE to VISIT
  # Codelist = VISIT
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = sdtm_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  # Map STUDY to STUDYID
  assign_no_ct(
    raw_dat = ds_raw,
    raw_var = "STUDY",
    tgt_var = "STUDYID",
    id_vars = oak_id_vars()
  ) %>%
  # DOMAIN = DS when raw_source = ds_raw
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, raw_source == "ds_raw"),
    raw_var = "raw_source",
    tgt_var = "DOMAIN",
    tgt_val = "DS",
    id_vars = oak_id_vars()
  )

# Hardcode final missing columns -------------------------------------------------------------

# Add VISITNUM values to the DS Domain using sdtm_ct codelist VISITNUM

## Make a lookup table from the sdtm_ct
visitnum_lookup <- sdtm_ct %>%
  filter(codelist_code == "VISITNUM") %>%
  mutate(label = tolower(collected_value),
         VISITNUM = as.numeric(term_value)) %>%
  select(label, VISITNUM)

visitnum_map <- ds_raw %>%
  mutate(label = tolower(INSTANCE)) %>%
  left_join(visitnum_lookup, by = "label") %>%
  mutate(VISITNUM = if_else(
    is.na(VISITNUM) & startsWith(label, "unscheduled"),
    as.numeric(sub("unscheduled ", "", label)),           # Pulls VISITNUM = x from the "Unscheduled x" inputs
    VISITNUM
  )) %>%
  select(oak_id, VISITNUM)

## Add VISITNUM column to ds
ds <- ds %>%
  select(-any_of("VISITNUM")) %>%
  left_join(visitnum_map, by = "oak_id")
ds <- ds %>% mutate(VISITNUM = as.character(VISITNUM))

# Combine STUDYID-patient_number into new column called USUBJID (Unique Subject Identifier) and then remove patient_number column
ds <- ds %>%
  mutate(USUBJID = paste(STUDYID, patient_number, sep = "-")) %>%
  select(-patient_number)

# Cannot calculate DSSTDY (start date of disposition event): missing RFSTDTC (subject's reference start date)
## Add column with missing values
ds <- ds %>%
  mutate(DSSTDY = NA_real_)

# Assign DSSEQ values
## Group dataset by STUDYID and USUBJID, then sort the records chronologically before assigning the value
ds <- ds %>%
  arrange(STUDYID, USUBJID, DSSTDTC, DSDTC, VISITNUM, DSCAT, DSDECOD, DSTERM) %>%
  group_by(STUDYID, USUBJID) %>%
  mutate(DSSEQ = row_number()) %>%
  ungroup()

# Reorder ds for final domain ----------------------------------------------------------------

ds <- ds %>%
  select(STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY) %>%
  arrange(USUBJID, DSSEQ)
