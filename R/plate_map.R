#' Read in, validates, and stores PlateMap formatted in the same way as Example_PlateMap.xlsx
#'
#' @param plateMap_file platemap excel path and filename
#' @param sheet the sheet which the wanted platemap resides on in the excel file
#' @return A dataframe rotated by {rotation_deg_needed} degrees clockwise
#' @export

expected_columns <- c("Group","Negative_Control_Column","Positive_Control_Column",
             "Individual_condition","Virus","Plate","Plate_Name","Well","dilution_or_concentration","Starting_Dilution_or_concentration","dilution_series")

validate_plate_map <- function(df,plateMap_file,mode="default"){
  # keep and check unexpected columns
  unexpected_columns <- setdiff(colnames(df),expected_columns)
  if (mode=="loud"){
    warning(glue::glue("detected {length(unexpected_columns)} unexpected_columns:{paste(unexpected_columns,collapse=',')} in {plateMap_file}, please double check if you made any changes to expected column headers."))
    }
  # If there are missing columns, add them to the df
  missing_columns <- setdiff(expected_columns, colnames(df))
  if (length(missing_columns) > 0) {
    for (col in missing_columns) {
      df[[col]] <- NA  # You can replace NA with any default value if needed
      if (mode=="loud"){warning(glue::glue("Your platemap {plateMap_file} is missing '{col}'. Adding a '{col}' column with empty values."))}
    }
  }
  # Reorder df with the ORDERED expected columns and unexpected columns to the list
  df <- df[, c(expected_columns,unexpected_columns), drop = FALSE]
  return(df)
}

read_validate_plate_map <- function(plateMap_file,sheet="Sheet1"){
  df <- readxl::read_excel(plateMap_file,
                           sheet=sheet,
                           .name_repair = "unique_quiet")
  df <- data.frame(df)
  df <- validate_plate_map(df,plateMap_file,mode = "loud")
  return(df)
}

read_validate_plate_map(plateMap_file = "Validation/Example_PlateMap.xlsx",sheet = "Sheet_with_errors")

find_promega_plate_paths <- function(directory_of_neut_files){
  all_excel_files <- list.files(path=directory_of_neut_files,pattern = ".xlsx",full.names = TRUE,recursive = TRUE,ignore.case = FALSE)
  # catch instances where the entire home directory and all sub-directories are searched. TODO: Improve condition for this catch.
  if (length(all_excel_files) > 2500){
    warning("more than 2500 excel files found, please check if the directory you have given is as intended. Searching a larger directory than necessary will lead to poor performance and long search times.")
  }
  # The current filter strategy = checking if .xlsx have a sheet called "Results". TODO: This needs further optimising to prevent false negatives
  promega_excel_files <- Filter(function(file) "Results" %in% readxl::excel_sheets(file),all_excel_files)
  
  message(glue::glue("A total of {length(promega_excel_files)} promega data plates are found out of {length(all_excel_files)} excel files in the directory {directory_of_neut_files}."))
  return(promega_excel_files)
}

directory_of_neut_files='Validation'

generate_plate_map <- function(directory_of_neut_files,output_plateMap_file="Validation/generated_platemap.xlsx"){
  promega_plate_paths <- find_promega_plate_paths(directory_of_neut_files)
  promega_plate_paths <- data.frame(promega_plate_paths)
  
  output_plateMap <- promega_plate_paths %>% dplyr::mutate(
    Plate_Name=tools::file_path_sans_ext(basename(promega_plate_paths))
    )
  output_plateMap <- validate_plate_map(output_plateMap)
  openxlsx::write.xlsx(x=output_plateMap,file = output_plateMap_file)
  message(glue::glue("Generated platemap based on Promega files in {directory_of_neut_files} written to {output_plateMap_file}"))
}

generate_plate_map("Validation/")


