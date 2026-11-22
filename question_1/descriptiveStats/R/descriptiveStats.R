#' Calculate the mean of a vector
#' @param x A vector
#' @returns A numeric mean of the input vector. Empty vectors, NAs, and non-numeric values will return a respective error message.
#' @examples
#' calc_mean(c(1, 2, 3))  # Returns 2
#' calc_mean(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)) # Returns 4.3
#' @export

calc_mean <- function(x){
  if (length(x) == 0){         # Checks length of vector > 0
    stop("Vector is empty.")
  }
  else if (is.numeric(x)){     # Checks vector is numeric
    x <- x[!is.na(x)]          # Removes NA values
    if (length(x) == 0){
      stop("Vector contains only NA values.")
    }
    n_total <- sum(x)
    n_values <- length(x)
    n_mean = n_total / n_values  # Calculates mean value
    return(n_mean)               # Prints mean value
  }
  else
    stop("Vector contains non-numeric values.")
}

#' Calculate the median of a vector
#' @param x A vector
#' @returns A numeric median of the input vector. Empty vectors, NAs, and non-numeric values will return a respective error message.
#' @importFrom stats median
#' @examples
#' calc_median(c(1, 2, 3))  # Returns 2
#' calc_median(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)) # Returns 4.5
#' @export

calc_median <- function(x){
  if (length(x) == 0){
    stop("Vector is empty.")
  }
  else if (is.numeric(x)){
    n_median = median(x, na.rm = TRUE) # Uses stats package median function, accounts for NA values
    return(n_median)
  }
  else
    stop("Vector contains non-numeric values.")
}

#' Calculate the mode of a vector
#' @param x A vector
#' @returns One or more numeric modes of the input vector. Empty vectors, NAs, and non-numeric values will return a respective error message.
#' @examples
#' calc_mode(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)) # Returns 5
#' @export

calc_mode <- function(x){
  if (length(x) == 0){
    stop("Vector is empty.")
  }
  else if (is.numeric(x)){     # Checks vector is numeric
    x <- x[!is.na(x)]          # Removes NA values
    if (length(x) == 0){
      stop("Vector contains only NA values.")
    }

    unique_n <- unique(x)

    # Account for no mode
    if (length(unique_n) == length(x) & length(x) > 1){
      stop("Vector has no mode.")
    }
    # Report back mode or modes if multiple
    positions <- match(x, unique_n)         # Finds value positions in list
    tab <- tabulate(positions)              # Counts unique value appearances
    max_count <- max(tab)                   # Identifies values with highest frequency
    modes <- unique_n[tab == max_count]     # Keeps identified modes
    return(modes)
  }
  else
    stop("Vector contains non-numeric values.")
}

#' Calculate the first quartile of a vector
#' @param x A vector
#' @returns The numeric first quartile of the input vector. Empty vectors, no mode, and ties will return a respective error message or information.
#' @importFrom stats quantile
#' @examples
#' calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)) # Returns 2.25
#' @export

calc_q1 <- function(x){
  if (length(x) == 0){         # Checks length of vector > 0
    stop("Vector is empty.")
  }
  else if (is.numeric(x)){     # Checks vector is numeric
    n_q1 <- quantile(x, 0.25, na.rm = TRUE)  # Uses stats package quantile function
    n_q1_clean <- unname(n_q1)                # Removes "25%" title from output
    return(n_q1_clean)
  }
  else
    stop("Vector contains non-numeric values.")
}

#' Calculate the third quartile of a vector
#' @param x A vector
#' @returns The numeric third quartile of the input vector. Empty vectors, NAs, and non-numeric values will return a respective error message.
#' @importFrom stats quantile
#' @examples
#' calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)) # Returns 5
#' @export

calc_q3 <- function(x){
  if (length(x) == 0){         # Checks length of vector > 0
    stop("Vector is empty.")
  }
  else if (is.numeric(x)){     # Checks vector is numeric
    n_q3 <- quantile(x, 0.75, na.rm = TRUE)  # Uses stats package quantile function
    n_q3_clean <- unname(n_q3)                # Removes "75%" title from output
    return(n_q3_clean)
  }
  else
    stop("Vector contains non-numeric values.")
}

#' Calculate the interquartile range (IQR = Q3 - Q1) of a vector
#' @param x A vector
#' @returns The numeric IQR of the input vector. Empty vectors, NAs, and non-numeric values will return a respective error message.
#' @examples
#' calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)) # Returns 2.75
#' @export

calc_iqr <- function(x){
  if (length(x) == 0){         # Checks length of vector > 0
    stop("Vector is empty.")
  }
  else if (is.numeric(x)){     # Checks vector is numeric
    n_iqr <- calc_q3(x) - calc_q1(x) # Uses previously defined functions within the package
    return(n_iqr)
  }
  else
    stop("Vector contains non-numeric values.")
}
