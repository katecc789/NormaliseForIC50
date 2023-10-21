#purpose: automating the normalization process before importing to PRISM to reduce memory burden.
#output: xlsx files with sheets named after original - easy for copy and pasting into PRISM

library(readxl)
library(scales)

# CHANGE THESE TO YOUR FILENAMES
input_file <- "Validation/2022-09-04 reads/example1.xlsx" #CHANGE to example file in your directory
input_directory = "Validation/2022-09-04 reads/" #CHANGE this to directory of input .xlsx data files
output_file <- "Validation/test.xlsx" # CHANGE directory and name for yourself 
rotate_by <- 0 # clockwise degrees, multiples of 90, useful when doing 12 fold dilutions.

# Test case
# read in and select relevant 8x12 area of the excel Results sheet
df <- read_excel(input_file,sheet = "Results")[8:16,6:17]
df <- data.frame(df)
colnames(df) <- df[c(1),] #set first row (default is 1-12, or whatever it is being renamed to) as headers
df <- df [-c(1),] # remove first row (1-12)
df <- as.data.frame(sapply(df,as.numeric)) #if the header is a string, the sample will be automatically assumed to be a str, which becomes problematic when normalizing.

# 90deg clockwise rotation function. When you accidentally rotate your plate or a 12 step serial dilution ------
rotate <- function (x){
  placeholder = data.frame((t(apply (x,2,rev))))
  return (placeholder)
}
df <- rotate(df)
# mean of cell control and virus control ----
control.cell <- mean(df[,1],na.rm=TRUE)
control.virus <- mean(df[,2],na.rm=TRUE)
df.values <- df[,-(1:2)] # remove first 2 columns = cell and virus control
#normalize function
normalise <- function(x,control_cell=control.cell,control_virus=control.virus){
  return(
    round((1-
       scale(x,center = control_cell,scale = control_virus-control_cell)/1 #actual normalization
     ) # express as inverse value (neutralization activity)
    *100 #express as percentage
  ,3) # round to decimal point (prism standard)
  )}
output = data.frame(lapply(df.values, FUN = normalise,control_cell=control.cell,control_virus=control.virus))

#final function
final_func <- function(neut_xlsx_path, rotation_deg_needed=0){
  print(paste0("processing input file: ",neut_xlsx_path))
  # 1. read in and select relevant 8x12 area of the excel Results sheet
  df <- read_excel(neut_xlsx_path,sheet = "Results")[8:16,6:17]
  df <- data.frame(df)
  colnames(df) <- df[c(1),] #set first row (1-12) as headers
  df <- df [-c(1),] # remove first row (1-12)
  df <- as.data.frame(sapply(df,as.numeric)) #if the header is a string, the sample will be automatically assumed to be a str, which becomes problematic when normalizing.
  # 2. rotate by 90 degrees n number of times, if needed
  n_rotation_needed <- rotation_deg_needed/90
  while (n_rotation_needed > 0){
    df <- rotate(df)
    n_rotation_needed <- n_rotation_needed - 1
  }
  df <- as.data.frame(sapply(df,as.numeric)) #if the header is a string, the sample will be automatically assumed to be a str, which becomes problematic when normalizing.
  # 3. normalize the rotated df
  control.cell <- mean(df[,1],na.rm=TRUE)
  control.virus <- mean(df[,2],na.rm=TRUE)
  print(paste0("cell control = ",control.cell))
  print(paste0("virus control = ",control.virus))
  df.values <- df[,-(1:2)] # remove first 2 columns = cell and virus control
  output <- data.frame(lapply(df.values,FUN = normalise,control_cell=control.cell,control_virus=control.virus))
  # 4. write the table to .tsv file
  input_name = tools::file_path_sans_ext(neut_xlsx_path)
  print(paste0("Finished processing:",neut_xlsx_path))
  return(output)
}

# final check
neut_raw_files = Sys.glob(
  paste0(input_directory,"*.xlsx")) # find all .xlsx file in input directory
final_func(neut_raw_files[1],rotation_deg_needed = rotate_by)
#create xlsx and populate df into separate sheets. CHANGE rotation_deg_needed if the plate was ROTATED when setting up.
library(openxlsx)
wb <- createWorkbook()
for (neut_raw_file in neut_raw_files){
  neut_file = basename(neut_raw_file) #remove file path
  neut_file = tools::file_path_sans_ext(neut_file) #remove extension
  addWorksheet(wb,sheetName=neut_file)
  writeData(wb, sheet = neut_file,x = final_func(neut_raw_file,rotation_deg_needed = rotate_by))
}
saveWorkbook(wb,file=output_file,overwrite = TRUE)

