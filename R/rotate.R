#' Performs clockwise rotations (0,90,180,270 degrees)
#'
#' This function rotates a data.frame of any size by 0 (no rotation), 90, 180, or 270 degrees clockwise.
#'
#' @param df dataframe to rotate
#' @param rotation_deg_needed how many degrees clockwise to rotated (default=0 (no rotation), 90, 180, or 270)
#' @return A dataframe rotated by {rotation_deg_needed} degrees clockwise
#' @export

rotate <- function(df,rotation_deg_needed=0){
  #define a sub-function which rotates by 90 degrees clockwise
  rotate_90deg <- function (df){
    df <- t(df[nrow(df):1,,drop=FALSE])
    return (df)
  }
  #verify if the input degree is a multiple of 90
  if (rotation_deg_needed %in% c(0,90,180,270)){
    n_rotation_needed <- rotation_deg_needed/90
    while (n_rotation_needed > 0){
      df <- rotate_90deg(df)
      n_rotation_needed <- n_rotation_needed - 1}
    #if the header is a string, the sample will be automatically assumed to be a str, which becomes problematic when normalizing.
    rownames_holder <- rownames(df) 
    df <- as.data.frame(apply(df,2,as.numeric))
    rownames(df) <- rownames_holder
    
    return (df)
  } else{
      stop("Invalid angle. Allowed rotation_deg_needed are 0, 90, 180, or 270.")
    }
}
