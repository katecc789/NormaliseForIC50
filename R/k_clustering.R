#'install.packages("Ckmeans.1d.dp")
#'select k-cluster mean that is closest to the mean of your first and last rows without outliers
k_clustering <- function(df, lim, na.rm=TRUE){
  controlmeans <- Ckmeans.1d.dp::Ckmeans.1d.dp(df)
  check_none_min_warning(controlmeans$size)
  k <- data.frame(controlmeans$size, controlmeans$centers)
  numeric_vector <- as.numeric(unlist(lim)) #unlist values in dataset containing upper and lower limit values, define the column
  lim_mean_without_outliers <- mean_without_outliers(numeric_vector) #mean without outliers
  closest_index <- which.min(abs(k$controlmeans.centers - lim_mean_without_outliers))
  control.mean <- k$controlmeans.centers[closest_index] #means of control that is closest to lower/upper limit mean
}
