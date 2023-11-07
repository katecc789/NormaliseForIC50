#' Reads in dataframe of Promega data, and normalise. 
#'
#' This function assumes that the left most row is cell/negative control, and second column from the left as virus/positive control.
#'
#'
#' @param df dataframe to normalise, where left most column is negative control, and second left column is positive control.
#' @param control_neg The column which negative/cell control are located (column number from left, integer)
#' @param control_pos The column which positive/cell control are located (column number from left, integer)
#' @return A normalised dataframe where negative and positive control columns are removed.
#' @export

normalise <- function(df,control_neg_column=1,control_pos_column=2){
  control.neg <- mean(df[,control_neg_column],na.rm=TRUE)
  control.pos <- mean(df[,control_pos_column],na.rm=TRUE)
  print(paste0("negative control = ",control.neg))
  print(paste0("positive control = ",control.pos))
  df.values<-df[,-c(control_neg_column,control_pos_column)]
  
  normalise_cell <- function(value){ #nested function - the normalization of individual cells
    return(
      round(
        (1-scale(value,center=control.neg,scale=control.pos-control.neg)/1 #actual normalization
      ) # express as inverse value (neutralization activity)
      *100 #express as percentage
      ,3 #round to 3 decimal points (Prism standard)
    ))
  }
  
  return(data.frame(lapply(df.values,FUN = normalise_cell))) # apply nested function to all cells in subsetted dataframe
}