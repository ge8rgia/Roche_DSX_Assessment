### Question 1: R Package Development - Descriptive Statistics

## Package structure requirements
- DESCRIPTION file with metadata: Title, Version, Authors, License, Description
- NAMESPACE file with appropriate exports
- R code provided in an R/ folder

## Functions required
- calc_mean(x) - arithmetic mean
- calc_median(x) - median
- calc_mode(x) - mode (handle ties and no mode cases)
- calc_q1(x) - first quartile (Q1)
- calc_q3(x) - third quartile (Q3)
- calc_iqr(x) - interquartile range (IQR = Q3 - Q1)

Functions must be able to handle: empty vectors, non-numeric inputs, NA values, as well as handling ties and no mode cases for the calc_mode(x) function. 

## Example Usage

```r
# Install and load
devtools::install("question_1/descriptive_stats")
library(descriptiveStats)

# Example data
data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

# Use functions
calc_mean(data)    # 3.3
calc_median(data)  # 4.5
calc_mode(data)    # 5
calc_q1(data)      # 2.5
calc_q3(data)      # 5.5
calc_iqr(data)     # 3
```
