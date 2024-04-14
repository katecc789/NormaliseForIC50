#' Remove the outliers from your first and last rows (upper and lower bounds) and find the mean
#' Define numeric_vector
mean_without_outliers <- function(numeric_vector, num_sd = 2) { #2 SD default
  mean_value <- mean(numeric_vector)
  sd_value <- sd(numeric_vector)
  lower_bound <- mean_value - num_sd * sd_value
  upper_bound <- mean_value + num_sd * sd_value
  data_filtered <- numeric_vector[numeric_vector >= lower_bound & numeric_vector <= upper_bound]
  
  # let user know what outliers are detected.
  outliers <- numeric_vector[!(data_filtered %in% numeric_vector)]
  if (length(outliers) > 0){
    warning(glue::glue("{length(outliers)} outliers removed: They are {outliers}"))
  }
  return(mean(data_filtered))
}
