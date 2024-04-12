#Check that the last row contains the largest value in the respective column
check_max <- function(row_index, data) {
  for (col in colnames(data)) {
    max_val <- max(data[[col]])
    if (data[row_index, col] != max_val) {
      warning(paste("Warning: Value in row", row_index, "of column", col, "is not the largest value in its respective column."))
    }
  }
}

#Check that the first row contains the smallest value in the respective column 
check_min <- function(row_index, data) {
  for (col in colnames(data)) {
    min_val <- min(data[[col]])
    if (data[row_index, col] != min_val) {
      warning(paste("Warning: Value in row", row_index, "of column", col, "is not the smallest value in its respective column."))
    }
  }
}

#Check that at least one of the k-clusters has at least 3 values
check_none_min_warning <- function(vector) {
  if (all(vector < 3)) {
    warning("Warning: None of the k-clusters from your controls have at least 3 data values. Positive or negative control values are too sparsely distributed. Are you sure some of the control values do not belong in the neutralization column?")
  }
}
