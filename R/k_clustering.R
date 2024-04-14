#'install.packages("Ckmeans.1d.dp")
#'select k-cluster mean that is closest to the mean of your first and last rows without outliers
k_clustering <- function(control_column, lim, type=c("negative","positive"), na.rm=TRUE){
  control_means <- suppressWarnings(Ckmeans.1d.dp::Ckmeans.1d.dp(control_column, 
                                                                 k=c(1,5),method = "linear",estimate.k = "BIC"))
  check_none_min_warning(control_means$size)
  message(length(control_means$size), type, "clusters: sized", paste(unlist(control_means$size),collapse=","))
  
  k <- data.frame(control_means$size, control_means$centers)
  
  numeric_vector <- as.numeric(unlist(lim)) #unlist values in dataset containing upper and lower limit values, define the column
  lim_mean_without_outliers <- mean_without_outliers(numeric_vector) #mean without outliers
  
  closest_index <- which.min(abs(k$control_means.centers - lim_mean_without_outliers))
  control.mean <- k$control_means.centers[closest_index] #means of control that is closest to lower/upper limit mean
}

#Check that at least one of the k-clusters has at least 3 values
check_none_min_warning <- function(vector) {
  if (all(vector < 3)) {
    warning(neut_xlsx_path,"Warning: None of the k-clusters from your controls have at least 3 data values. Positive or negative control values are too sparsely distributed. Are you sure some of the control values do not belong in the neutralization column?")
  }
}