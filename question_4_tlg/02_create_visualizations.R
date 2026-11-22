# Question 4.2: Visualizations using {ggplot2}

# Load libraries
libs <- c("ggplot2", "pharmaverseadam")
invisible(lapply(libs, library, character.only = TRUE))

# Read in input datasets
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# Plot 1 ---------------------------------------------------------------------------

## AE severity distribution by treatment
## AE severity is captured by AESEV within the adae dataset

plot1 <- ggplot(adae, aes(x = ARM, fill = AESEV)) +
  geom_bar() +
  labs(title = "Adverse Event (AE) Severity Distribution by Treatment Arm",
       x = "Treatment Arm",
       y = "Count of AEs",
       fill = "Severity/Intensity") +
  theme_minimal() +
  theme(
    plot.text = element_text(size = 16)
  )

plot1
ggsave("outputs/plot1_ae_severity_by_treatment.png", plot1, width = 8, height = 7)

# Plot 2 ---------------------------------------------------------------------------

## Top 10 most frequent AEs (with 95% CI for incidence rates)
## AEs captured by AETERM within the adae dataset

n_subjects <- n_distinct(adsl$USUBJID)    # 306 total

## Extract top 10 AETERMs by total number of subjects 
top_10_aes <- adae %>%
  filter(TRTEMFL == "Y") %>%         # Filter for AE records
  distinct (USUBJID, AETERM) %>%     # Count each subject once per AE
  count(AETERM, name = "n") %>%      # Counts the number of each AE
  slice_max(n, n = 10, with_ties = FALSE) %>%
  mutate(
    pct = n / n_subjects,
    lower_ci = sapply(n, function(x) binom.test(x, n_subjects)$conf.int[1]),
    upper_ci = sapply(n, function(x) binom.test(x, n_subjects)$conf.int[2])
  )

## Plot
plot2 <- ggplot(top_10_aes, aes(x = pct, y = reorder(AETERM, pct))) +
  geom_errorbar(aes(xmin = lower_ci, xmax = upper_ci), 
                orientation = "y", width = 0.3) +
  geom_point(size = 3) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = expression(bold("Top 10 Most Frequent Adverse Events")),
    subtitle = paste0("n = ", n_subjects, "; 95% Clopper-Pearson CIs"),
    x = expression(bold("Percentage of Patients (%)")),
    y = expression(bold("Adverse Event"))
  ) +
  theme_minimal()

plot2
ggsave("outputs/plot2_top10_frequent_ae.png", plot2, width = 9, height = 6)









