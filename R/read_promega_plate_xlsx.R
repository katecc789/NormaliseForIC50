#' Reading in Promega plate data, from the excel sheet format. 
#'
#' This function loads the Promega system generated excel sheet in a 8x12 matrix
#' whilst keeping the column and row names.
#'
#' @param input_promega_excel_file_path Path to the input file
#' @param sheetname The sheetname where the result is recorded on the Promega file. Should be "Results" if not manually changed.
#' @return A 8x12 data.frame with rownames and column headers
#' @export
read_promega_plate_excel= function(input_promega_excel_file_path,sheetname="Results"){
  df <- readxl::read_excel(input_promega_excel_file_path,
                           sheet=sheetname,
                           .name_repair = "unique_quiet")[8:16,5:17] # subset relevant columns and rows
  df <- data.frame(df)
  colnames(df) <- df[c(1),] #set first row as colnames (default is 1-12, or whatever it is being renamed to) as headers
  df <- df [-c(1),] # remove first row (1-12) from df
  colnames(df)[1] <- "row" 
  rownames(df) <- df[,1] # set A,B,C....H as rownames
  df<- df[,-1] # then remove A,B,C....H from df
  df <- as.data.frame(df)
  df[] <- lapply(df,as.numeric) #if header is contains string, values are assumed to be str, problematic when normalizing.
  return (df)
}