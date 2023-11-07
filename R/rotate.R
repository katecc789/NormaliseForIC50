#' Reading in Promega plate data, from the excel sheet format. 
#'
#' This function rotates a data.frame of any size by 90 degrees.
#'
#' @param x dataframe to rotate
#' @return A dataframe rotated 90 degrees clockwise
#' @export

rotate <- function (x){
  placeholder = data.frame((t(apply (x,2,rev))))
  return (placeholder)
}