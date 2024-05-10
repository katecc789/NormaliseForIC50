#' @name plate_map_onto_plate
#' @title map a single plate_map to a read promega_plate
#' @importFrom magrittr %>%
#' @import dplyr
#' 
#' @rdname plate_map_onto_plate
#' @title adding_technical_replicates_to_columns_with_repeated_names
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
plateMap_map_onto_promega_read <- function(plate_map,promega_read_values){
  if (missing(promega_read_values)){
    promega_plate_location <- unique(plate_map$promega_plate_path)
    if (length(promega_plate_location) >1){
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
#' @rdname plate_map_onto_plate
#' @title validate_columns
#' @param columns Negative_Control_Column, Positive_Control_Column, or column from a plate map, which can be strings like "5,6" when processing experiment columns which summarises
#' @return validated version which is a list of integers
#' @description
#' validate the columns of neg, pos, or samples
validate_columns <- function(columns) {
  if (is.numeric(columns)){
    return(columns) 
  }
  if (is.character(columns)){
    if (!grepl(",", columns)) {
      return(as.integer(columns))
    } else {
      return(as.integer(unlist(strsplit(columns,","))))
    }
  }
}

#' @rdname plate_map_onto_plate
#' @title convert_dilution_factor
#' @param dilution_factor_string dilution formatted as numerator in denominator (e.g. 1 in 3)
#' @return numeric dilution_factor
convert_dilution_factor <- function(dilution_factor_string="1 in 3"){
  numerator <- as.numeric(stringr::str_extract(dilution_factor_string,"^[0-9]+(?:\\.[0-9]+)?")) # first integer or decimal numeric
  denominator <- as.numeric(stringr::str_extract(dilution_factor_string,"[0-9]+(?:\\.[0-9]+)?$")) # last integer or decimal numeric
  dilution_factor <- denominator/numerator
  return(dilution_factor)
}

#' @rdname plate_map_onto_plate
#' @title convert_dilution_factor
#' @param Starting_Dilution_or_concentration The starting dilution or concentration (unitless)
#' @param num_steps Number of dilution rows including neat
#' @param dilution_factor dilution formatted as numerator in denominator (e.g. 1 in 3)
#' @param titration_mode If dilution, the numbers get bigger, if concentration, the numbers get smaller
#' @return comma-separated string of dilution_series
generate_dilution_series <- function(Starting_Dilution_or_concentration = 20, num_steps = 8, dilution_factor = "1 in 3", titration_mode = c("dilution","concentration")){
  dilution_factor <- convert_dilution_factor(dilution_factor)
  dilution_series <- numeric(num_steps)
  dilution_series[1] <- Starting_Dilution_or_concentration
  for (i in 2:num_steps){
    dilution_series[i] <- switch(titration_mode,
                                 "dilution" = dilution_series[i-1] * dilution_factor, 
                                 "concentration" = dilution_series[i-1] / dilution_factor)
  }
  return(dilution_series)
}
#' @rdname plate_map_onto_plate
#' @title normalise_plate_using_plateMap
#' @param plate_map platemap with the strict platemap format
#' @param processed_read_values_with_tech_rep output of plateMap_map_onto_promega_read
#' @return validated version which is a list of integers
#' @export
#' @description
#' now treat each unique virus suffix as their own set, and normalise.
#'
normalise_plate_using_plateMap <- function(plate_map=plate1_map, processed_read_values_with_tech_rep){
  if (missing(processed_read_values_with_tech_rep)){
    processed_read_values_with_tech_rep <- plateMap_map_onto_promega_read(plate_map)
  }
  df_list <- list()
  plate_specific_columns <- c("Group","column","Negative_Control_Column","Positive_Control_Column",
                              "Individual_condition","Virus","dilution_or_concentration","Starting_Dilution_or_concentration","dilution_series")
  # summarise columns of the same condition
  plate_map <- plate_map %>% 
    select(plate_specific_columns) %>%
    group_by(across(c(-column)))%>%
    summarise(column=paste(column,collapse=","),.groups = "keep")%>% ungroup() 
  # add dilution serie column
  plate_map <- plate_map %>% rowwise() %>% mutate(
    dilution_serie = paste(generate_dilution_series(titration_mode = dilution_or_concentration,num_steps = 8,
                                                    Starting_Dilution_or_concentration = Starting_Dilution_or_concentration,
                                                    dilution_factor = dilution_series)
                           ,collapse = ","))
  for (unique_condition in 1:nrow(plate_map)){
    neg_control_columns <- validate_columns(plate_map[[unique_condition,"Negative_Control_Column"]])
    pos_control_columns <- validate_columns(plate_map[[unique_condition,"Positive_Control_Column"]])
    experiment_columns <-  validate_columns(plate_map[[unique_condition,"column"]])
    plate_map_virus_specific_normalise_columns <- c(neg_control_columns,
                                                    pos_control_columns,
                                                    experiment_columns) # powerful because this also reorders them in order of negative, positive, experiment columns
    bruh <- NormaliseForIC50::normalise(df = processed_read_values_with_tech_rep[plate_map_virus_specific_normalise_columns],
                                        control_neg_column = seq(length(neg_control_columns)),
                                        control_pos_column = seq(length(neg_control_columns)+1,length(neg_control_columns)+ length(pos_control_columns)))
    # add Group, dilution_or_concentration, dilution series
    Group <- plate_map[[unique_condition,"Group"]]
    dilution_or_concentration <- plate_map[[unique_condition,"dilution_or_concentration"]]
    
    dilution_serie <- plate_map[[unique_condition,"dilution_serie"]]
    dilution_series_list <- as.numeric(unlist(strsplit(dilution_serie, ",")))
    
    bruh$Group <- Group
    bruh$dilution_or_concentration <- dilution_or_concentration
    bruh$dilution_serie <- dilution_series_list
    
    df_list[[unique_condition]] <- bruh 
  }
  merge_cols = c("Group","dilution_or_concentration","dilution_serie")
  plate_normalised <- Reduce(function (x,y) merge(x,y,by=merge_cols, all = TRUE),df_list) %>% dplyr::arrange(across(all_of(merge_cols)))
  
  return(plate_normalised)
}

#' @rdname filter_merged
#' @title filter_merged
#' @param plates_merged the dataframe of the merged normalised plates
#' @param condition The inidividual or test condition you want to filter by, can be a single string, or a list. "AZ12" 
#' @param virus The virus that you want to filter by. Can be a single string, or a list. e.g. c("Virus1","VIrus2")
#' @return A filtered dataframe of normalised values.
#' @export
#' @description
#' Filters the dataframe by conditions or virus
#' 
filter_merged <- function(plates_merged,condition=NULL,virus=NULL){
  experiment_columns <- data.frame(colnames=colnames(plates_merged)) %>% 
    subset(.,!(colnames %in% merge_cols)) %>%
    tidyr::separate(colnames, into=c("individual_condition","Virus","technical_replicate"),"_",remove=FALSE)
  
  filtered_experiment_columns <- experiment_columns %>%
    filter(if(!is.null(condition)) (individual_condition %in% condition) else TRUE) %>%
    filter(if(!is.null(virus)) (Virus %in% virus) else TRUE)
  
  filtered_plates_merged <- plates_merged %>% 
    dplyr::select(merge_cols,filtered_experiment_columns$colnames) %>%
    dplyr::filter(!if_all(-merge_cols,is.na))
  
  #remove technical replicate in colnames
  colnames(filtered_plates_merged) <- sub("_techrep[0-9]+$", "", colnames(filtered_plates_merged)) 
  
  return (filtered_plates_merged)
}