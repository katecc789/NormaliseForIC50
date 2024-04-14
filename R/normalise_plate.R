#' Reads in dataframe of Promega data, and normalise.
#'
#' This function assumes that the left most row is cell/negative control, and second column from the left as virus/positive control.
#'
#'
#' @param df dataframe to normalise, where left most column is negative control, and second left column is positive control.
#' @param control_neg_column The column(s) which negative/cell control are located (column number from left, integer)
#' @param control_pos_column The column(s) which positive/cell control are located (column number from left, integer)
#' @param cluster Experimental feature - uses k-means clustering to detect and exclude anomalies in negative and positive control (default = FALSE)
#' @return A normalised dataframe where negative and positive control columns are removed.
#' @export
#' 

normalise <- function(df, control_neg_column=c(1),control_pos_column=c(2),cluster=FALSE,filename=""){
  #exclude positive and negative control columns
  df.values<-df[,-c(control_neg_column,control_pos_column)]
  
  # Throw warning 
  check_max(df.values,filename = filename) #warning if last three row values are not the largest in the column 
  check_min(df.values,filename = filename) #warning if first three row values are not the smallest in the column 
  lim <- data.frame(
    lower_lim = apply(df.values, MARGIN = 2, min),
    upper_im = apply(df.values, MARGIN = 2, max)
  )
  # clustering or simple mean
  if (cluster == TRUE){
    control.neg <- k_clustering(unlist(df[,control_neg_column]), lim$lower_lim, type = "negative", na.rm=TRUE) 
    control.pos <- k_clustering(unlist(df[,control_pos_column]), lim$upper_im, type = "positive", na.rm=TRUE)  
  } else{
    control.neg <- mean(unlist(df[,control_neg_column]),na.rm=TRUE) #unlist is for when there are multiple positive/negative columns, so the dataframe will be converted to a list where mean() can be called.
    control.pos <- mean(unlist(df[,control_pos_column]),na.rm=TRUE)
  }
  message("negative control = ",control.neg)
  message("positive control = ",control.pos)
  
  # normalise all cells using negative and positive control values
  normalise_cell <- function(value){ #nested function - the normalization of individual cells
    return(
      round(
        (1-scale(value,center=control.neg,scale=control.pos-control.neg)/1 #actual normalization
        ) # express as inverse value (neutralization activity)
        *100 #express as percentage
        ,3 #round to 3 decimal points (Prism standard)
      ))
  }
  normalised_df<- data.frame(
    sapply(df.values,FUN = normalise_cell)
  )#apply nested function to all cells in subset dataframe
  rownames(normalised_df) <- rownames(df) #recall rownames
  return(normalised_df)
}

#For column maximum value, if there is no inhibition, the max value will likely not be at the end of titration. As long as it is not significantly larger it is not worrying.
check_max <- function(df.values, row_index=c(6,7,8),filename="") {
  exceed_limit=1.5
  for (col in colnames(df.values)) {
    max_val <- max(df.values[[col]],na.rm = TRUE)
    if (max_val > exceed_limit * max(df.values[row_index, col], na.rm = TRUE)) {
      warning(paste(filename,"Warning: The largest value is found outside of the last three rows of column", col))
    }
  }
}

#For each column, Check if the smallest value is correctly in the first three rows. Allow for 10 fold change as background signal can be weak. 
check_min <- function(df.values, row_index=c(1,2,3),filename="") {
  exceed_limit=10
  for (col in colnames(df.values)) {
    min_val <- min(df.values[[col]],na.rm = TRUE)
    if (min_val > exceed_limit * min(df.values[row_index, col], na.rm=TRUE)) {
      warning(paste(filename,"Warning: The smallest value is found outside of the first three rows of column", col))
    }
  }
}


