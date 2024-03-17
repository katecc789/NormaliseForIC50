#' @name plate_map_functions
#' @title Read in and validates, or generate PlateMap following strict formatting as Example_PlateMap.xlsx
#' @aliases validate_plate_map
#' @aliases generate_plate_map
#' @param plateMap_file PlateMap excel file name
#' @param sheet the sheet which the wanted PlateMap resides on in the plateMap_file
#' @param directory_of_files the directory_of_files that is iterated through to look for Promega output files to generated output_plateMap_file.
#' @param output_plateMap_file filepath where the generated PlateMap will be located.
#' @importFrom magrittr %>%

expected_columns <- c("Group","Negative_Control_Column","Positive_Control_Column",
             "Individual_condition","Virus","Plate","Plate_Name","Well","dilution_or_concentration","Starting_Dilution_or_concentration","dilution_series")

#' @section general:
validate_plate_map <- function(df,plateMap_file,mode="default"){
  # keep and check unexpected columns
  unexpected_columns <- setdiff(colnames(df),expected_columns)
  if (mode=="debug"){
    warning(glue::glue("detected {length(unexpected_columns)} unexpected_columns:{paste(unexpected_columns,collapse=',')} in {plateMap_file}, please double check if you made any changes to expected column headers."))
    }
  # If there are missing columns, add them to the df
  missing_columns <- setdiff(expected_columns, colnames(df))
  if (length(missing_columns) > 0) {
    for (col in missing_columns) {
      df[[col]] <- NA  # You can replace NA with any default value if needed
      if (mode=="debug"){warning(glue::glue("Your platemap {plateMap_file} is missing '{col}'. Adding a '{col}' column with empty values."))}
    }
  }
  # Reorder df with the ORDERED expected columns and unexpected columns to the list
  df <- df[, c(expected_columns,unexpected_columns), drop = FALSE]
  return(df)
}

#' @section read-created-plate-map:
#' @export 
read_validate_plate_map <- function(plateMap_file,sheet="Sheet1"){
  df <- readxl::read_excel(plateMap_file,
                           sheet=sheet,
                           .name_repair = "unique_quiet")
  df <- data.frame(df)
  df <- validate_plate_map(df,plateMap_file,mode = "debug")
  return(df)
}

#' @section generate-plate-map: 
#' 
find_promega_plate_paths <- function(directory_of_files){
  all_excel_files <- list.files(path=directory_of_files,pattern = ".xlsx",full.names = TRUE,recursive = TRUE,ignore.case = FALSE)
  # catch instances where the entire home directory and all sub-directories are searched. TODO: Improve condition for this catch.
  if (length(all_excel_files) > 2500){
    warning("more than 2500 excel files found, please check if the directory you have given is as intended. Searching a larger directory than necessary will lead to poor performance and long search times.")
  }
  # The current filter strategy = checking if .xlsx have a sheet called "Results". TODO: This needs further optimising to prevent false negatives
  promega_excel_files <- Filter(function(file) "Results" %in% readxl::excel_sheets(file),all_excel_files)
  
  message(glue::glue("A total of {length(promega_excel_files)} promega data plates are found out of {length(all_excel_files)} excel files in the directory {directory_of_files}."))
  return(promega_excel_files)
}

#' @section generate-plate-map:
#' @examples
#' get_read_date("Validation/2022-09-04 reads/example1.xlsx")
get_read_date <- function(file){
  execution_date_as_numeric <- (data.frame(suppressMessages(readxl::read_excel(file,sheet=1,col_names = FALSE)))[7,4])
  execution_date <- as.Date(as.numeric(execution_date_as_numeric),origin="1899-12-30") # excel specifically uses Dec 30, 1899 as origin
  return(execution_date)
}

#' @section generate-plate-map:
#' @rdname generate_plate_map
#' @param mode "return" will return into a variable, "write" will write to excel file defined by output_plateMap_file
#' @returns A dataframe, or an excel file with two additional columns. 1) The file path of the plates, and 2) the file creation date which corresponds to read date.
#' @examples
#' generate_plate_map("Validation/")
#' @export
generate_plate_map <- function(directory_of_files,output_plateMap_file="Validation/generated_platemap.xlsx",mode="return"){
  promega_plate_paths <- find_promega_plate_paths(directory_of_files)
  promega_plate_path <- data.frame(promega_plate_paths) %>% dplyr::rename(promega_plate_path=promega_plate_paths)
  
  output_plateMap <- promega_plate_path %>% 
    dplyr::mutate(Plate_Name=
                    tools::file_path_sans_ext(basename(promega_plate_path))
                    )%>%
    dplyr::rowwise()%>% dplyr::mutate(file_creation_date=get_read_date(promega_plate_path))
    
  output_plateMap <- validate_plate_map(output_plateMap)
  if (mode=="return"){
    return (output_plateMap)
  } else if (mode=="write"){
    openxlsx::write.xlsx(x=output_plateMap,file = output_plateMap_file)
    message(glue::glue("Generated platemap based on Promega files in {directory_of_files} written to {output_plateMap_file}"))
  }
}