#Install Mark's Package for Normalization of Neutralization Assay
install.packages("devtools")
devtools::install_github("TKMarkCheng/NormaliseForIC50", force = TRUE)

#Dowloading all the input data
input_file <- "/Users/katie/Desktop/Prof. Gupta/Normalization/Example1.xlsx"
input_directory = "/Users/katie/Desktop/Prof. Gupta/Normalization/"
output_file <- "/Users/katie/Desktop/Prof. Gupta/Validation.xlsx" #Make sure to create a blank excel file for the normalized data to be set

rotate_by <- 0 # clockwise degrees, multiples of 90, useful when doing 12 fold dilutions.
control_neg_column <- c(1) # default negative control column is on first column from the left
control_pos_column <- c(2) # default positive control column is on second column from the left

#download all the directory files
neut_raw_files <- Sys.glob(paste0(
  paste0(input_directory,"*.xlsx"))
)
neut_raw_files

#Correcting for Anomalies and Normalizing for Example 1
install.packages("anomalize")
library(anomalize)
install.packages("tidyverse")
install.packages("timechange") #Install tidyverse requires timechange package
library(tidyverse)

example1 <- example1[rowSums(is.na(example1)) != ncol(example1),]
colnames(example1) <- example1[1, ]
example1 <- example1[-1, ]

print(names(dat))

dat$sample1



Example1 <- neut_raw_files[1] %>% rownames_to_column() %>% as_tibble() %>%
  mutate(date = as.Date(rowname)) %>% select(-one_of('rawname'))
NormaliseForIC50::final_func(neut_raw_files[2],control_neg_column = c(1),control_pos_column = c(2), rotation_deg_needed = rotate_by)

#Normalizing all the data
library(openxlsx)
wb<-createWorkbook()
for (neut_raw_file in neut_raw_files){
  neut_file <- basename(neut_raw_file) #remove file path
  neut_file = tools::file_path_sans_ext(neut_file) #remove extension
  addWorksheet(wb,sheetName=neut_file)
  writeData(wb, sheet = neut_file,
            x = NormaliseForIC50::final_func(
              neut_raw_file,
              control_neg_column = control_neg_column,
              control_pos_column = control_pos_column,
              rotation_deg_needed = rotate_by))
  print(paste0("normalised data written to:",neut_file))
}

#Saving all the normalized data for all the files
saveWorkbook(wb,file=output_file,overwrite = TRUE)
print(paste0("saved collated sheets to excel file:",output_file))

