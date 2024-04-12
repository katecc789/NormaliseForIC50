#Dowloading all the input data

#install packages
#install.packages("Ckmeans.1d.dp")
#install.packages("xfun", type="binary")
#install.packages("tidyverse")
#install.packages("readxl")
#install.packages("FactoMineR")
#install.packages("factoextra")

source("R/all_in_one.R")
source("R/k_clustering.R")
source("R/check_columns.R")
source("R/mean_without_outliers.R")
source("R/normalise_plate.R")
source("R/read_promega_plate_xlsx.R")
source("R/rotate.R")

library(Ckmeans.1d.dp)
library(tidyverse)
library(readxl)
library(FactoMineR)
library(factoextra)
here::here()
input_file <- here::here("normalization/example1.xlsx")
input_directory = here::here("normalization/")
output_file <- here::here("Normalized_validation_dodgyvalues.xlsx") #Make sure to create a blank excel file for the normalized data to be set

rotate_by <- 0 # clockwise degrees, multiples of 90, useful when doing 12 fold dilutions.
control_neg_column <- c(1) # default negative control column is on first column from the left
control_pos_column <- c(2) # default positive control column is on second column from the left

neut_raw_files <- Sys.glob(paste0(
  paste0(input_directory,"/*.xlsx")) # find all .xlsx file in input directory
)
neut_raw_files

#test with one data file
final_func(neut_raw_files[3],control_neg_column = c(1),control_pos_column = c(2), rotation_deg_needed = rotate_by)

#Normalizing all the data
library(openxlsx)
wb<-createWorkbook()
for (neut_raw_file in neut_raw_files){
  neut_file <- basename(neut_raw_file) #remove file path
  neut_file = tools::file_path_sans_ext(neut_file) #remove extension
  addWorksheet(wb,sheetName=neut_file)
  writeData(wb, sheet = neut_file,
            x = final_func(
              neut_raw_file,
              control_neg_column = control_neg_column,
              control_pos_column = control_pos_column,
              rotation_deg_needed = rotate_by))
  print(paste0("normalised data written to:",neut_file))
}

#Saving all the normalized data for all the files
saveWorkbook(wb,file=output_file,overwrite = TRUE)
print(paste0("saved collated sheets to excel file:",output_file))
