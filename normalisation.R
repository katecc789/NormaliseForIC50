#purpose: automating the normalization process before importing to PRISM to reduce memory burden.
#output: xlsx files with sheets named after original - easy for copy and pasting into PRISM

source("R/final_func.R")
source("R/k_clustering.R")
source("R/mean_without_outliers.R")
source("R/normalise_plate.R")
source("R/read_promega_plate_xlsx.R")
source("R/rotate.R")

library(Ckmeans.1d.dp)
library(tidyverse)
library(openxlsx)

# USER INPUT 1: CHANGE THESE TO YOUR FILENAMES and OUTPUT FILE NAME -----------------------------------
input_file <- here::here("Validation/anomaly_detection/example1kcv2.xlsx") #CHANGE to example file in your directory
input_directory <- here::here("Validation/2022-09-04_reads/") #CHANGE this to directory of input .xlsx data files

output_file <- here::here("Validation/test_normalisation_without_anomaly_detection.xlsx") # CHANGE directory and name for yourself

# USER INPUT 2: CHANGE THESE TO YOUR SETTINGS  --------------------------------------------------------
control_neg_column <- c(1)
control_pos_column <- c(2)
rotate_by <- 0

#grab file name of all relevant sheet
neut_raw_files <- Sys.glob(file.path(input_directory,"*.xlsx")) # find all .xlsx file in input directory
neut_raw_files

#test with one data file
final_func(input_file, control_neg_column = control_neg_column, control_pos_column = control_pos_column,
           rotation_deg_needed = rotate_by,cluster = TRUE) # to turn on clustering

final_func(neut_raw_files[1], control_neg_column = control_neg_column, control_pos_column = control_pos_column,
           rotation_deg_needed = rotate_by) # by default no clustering is done

#create xlsx and populate df into separate sheets. CHANGE rotation_deg_needed if the plate was ROTATED when setting up.
wb <- createWorkbook()
for (neut_raw_file in neut_raw_files){
  neut_file = basename(neut_raw_file) #remove file path
  neut_file = tools::file_path_sans_ext(neut_file) #remove extension
  addWorksheet(wb,sheetName=neut_file)
  writeData(wb, sheet = neut_file,
            x = final_func(
              neut_raw_file,
              control_neg_column = control_neg_column,
              control_pos_column = control_pos_column,
              rotation_deg_needed = rotate_by,cluster = FALSE)
            )
  message("normalised data written to sheet:",neut_file)
}
saveWorkbook(wb,file=output_file,overwrite = TRUE)

# USER INPUT 3: If you want to test out anomaly detection, un-comment below and change output_filename_AD ------------
# output_file_AD <- here::here("Validation/test_normalisation_with_anomaly_detection.xlsx") # CHANGE directory and name for yourself
# #create xlsx and populate df into separate sheets. CHANGE rotation_deg_needed if the plate was ROTATED when setting up.
# wb <- createWorkbook()
# for (neut_raw_file in neut_raw_files){
#   neut_file = basename(neut_raw_file) #remove file path
#   neut_file = tools::file_path_sans_ext(neut_file) #remove extension
#   addWorksheet(wb,sheetName=neut_file)
#   writeData(wb, sheet = neut_file,
#             x = final_func(
#               neut_raw_file,
#               control_neg_column = control_neg_column,
#               control_pos_column = control_pos_column,
#               rotation_deg_needed = rotate_by,cluster = FALSE)
#   )
#   message("normalised data written to sheet:",neut_file)
# }
# saveWorkbook(wb,file=output_file_AD,overwrite = TRUE)
