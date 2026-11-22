# Question 4.3: Listing using {gtsummary}

# Load libraries
libs <- c("tidyverse", "pharmaverseadam", "gtsummary", "gtreg")
invisible(lapply(libs, library, character.only = TRUE))

# Read in input datasets
adae <- pharmaverseadam::adae

## Select for relevant columns
listing_select <- adae %>%
  filter(TRTEMFL == "Y") %>%                                         # Filter for AE records
  select(USUBJID, ACTARM, AETERM, AESEV, AEREL, ASTDT, AENDT) %>%    # Select relevant columns
  arrange(USUBJID, ASTDT)                                            # Sort by subject then event date

## Add layman term names for each column
listing_select <- listing_select %>%
  tbl_listing(bold_headers = FALSE) %>%
  modify_header(
    USUBJID ~ "Unique Subject Identifier",
    ACTARM ~ "Description of Actual Arm",
    AETERM ~ "Reported Term for the Adverse Event",
    AESEV ~ "Severity/Intensity",
    AEREL ~ "Causality",
    ASTDT ~ "Start Date/Time of Adverse Event",
    AENDT ~ "End Date/Time of Adverse Event"
  )

listing_select <- listing_select %>%
  modify_caption("Listing of Treatment-Emergent Adverse Events by Subject<br>Excluding Screen Failure Patients")

listing_select

listing_select %>% as_gt() %>% gt::gtsave("outputs/ae_listings.html")
