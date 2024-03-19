#' @name plate_map_onto_plate
#' @title map a single plate_map to a read promega_plate
#' @importFrom magrittr %>%
#' @import dplyr
#' 
#' @rdname adding_technical_replicates_to_columns_with_repeated_names
#' @param mapped_plate the dataframe of values which columns are assigned but may have repeated columns
#' @return a dataframe where all values have _techrep{n} suffixed, prevents having repeated column names. 
#' @description
#' Where there are repeated experiment columns, give them a suffix to indicate the number of technical replicates, 
#' and more importantly prevent automatic suffix addition in R to prevent unexpected results.
#' This acts as a daughter function of plate_map_onto_plate but also can act as a stand alone function.
#' @export
adding_technical_replicate_suffix <- function(mapped_plate){
  custom_suffix="_techrep"
  # Get column names and their frequencies
  col_names <- names(mapped_plate)
  col_freq <- table(col_names)
  
  new_col_names <- col_names
  # Iterate over column names and add custom suffix
  for (col in col_names) {
    indices <- which(col_names == col)
    for (i in seq_along(indices)) {
      new_col_names[indices[i]] <- paste(col, paste0(custom_suffix, i), sep = "")
    }
  }
  # Update the dataframe with modified column names
  names(mapped_plate) <- new_col_names
  return(mapped_plate)
}
#' @rdname plate_map_onto_plate
#' @title finding the plate using the path provided on the plate_map, and mapping the appropriate columns.
#' @param plate_map The platemap with strict definitions validated by plate_map.R
#' @param promega_read_values promega_plate_df generated from read_promega_plate_xlsx.R , if not specified, the plate_map column promega_plate_path will be searched
#' @return normalized values with <Group>, <dilution_or_concentration>, <dilution_serie> from plate_map
#' @export
plateMap_map_onto_promega_read <- function(plate_map,promega_read_values=""){
  if (promega_read_values==""){
    promega_plate_location <- unique(plate_map$promega_plate_path)
    if (promega_plate_location >1){
      warning(glue::glue("You have more than one promega_plate_paths for the same plate: {promega_plate_location}, only the first will be chosen, please check if you made any typos in the plate map."))}
    promega_read_values <- read_promega_plate_excel(promega_plate_location[1])
  }
  processed_read_values <- promega_read_values
  # change the column headers to <Individual_condition>_<Virus>
  colnames(processed_read_values) <- paste0(plate_map$Individual_condition[match(1:ncol(processed_read_values),plate_map$column)],
                                            "_",
                                            plate_map$Virus[match(1:ncol(processed_read_values),plate_map$column)])
  
  # adding the positive and negative control (virus specific manner)
  for (negative_control_column in unique(plate_map$Negative_Control_Column)){
    negative_control <- plate_map %>% filter(Negative_Control_Column == negative_control_column) %>% select(Virus) %>% unique()
    negative_control_virus <- negative_control[[1,1]]
    colnames(processed_read_values)[negative_control_column] <- paste0("Neg_",negative_control_virus)
  }
  for (positive_control_column in unique(plate_map$Positive_Control_Column)){
    positive_control <- plate_map %>% filter(Positive_Control_Column == positive_control_column) %>% select(Virus) %>% unique()
    positive_control_virus <- positive_control[[1,1]]
    colnames(processed_read_values)[positive_control_column] <- paste0("Pos_",positive_control_virus)
  }
  processed_read_values_with_tech_rep <- adding_technical_replicate_suffix(processed_read_values)
  
  return(processed_read_values_with_tech_rep)
}