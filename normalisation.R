#purpose: automating the normalization process before importing to PRISM to reduce memory burden.
#output: xlsx files with sheets named after original - easy for copy and pasting into PRISM


# CHANGE THESE TO YOUR FILENAMES
input_file <- "Validation/2022-09-04 reads/example1.xlsx" #CHANGE to example file in your directory
input_directory = "Validation/2022-09-04 reads/" #CHANGE this to directory of input .xlsx data files
output_file <- "Validation/test.xlsx" # CHANGE directory and name for yourself 
rotate_by <- 0 # clockwise degrees, multiples of 90, useful when doing 12 fold dilutions.

#final function
final_func <- function(neut_xlsx_path, sheetname="Results", rotation_deg_needed=0){
  print(paste0("processing input file: ",neut_xlsx_path))
  # 1. read in and select relevant 8x12 area of the excel Results sheet
  df <- read_promega_plate_excel(neut_xlsx_path)
  # 2. rotate by 90 degrees n number of times, if needed
  n_rotation_needed <- rotation_deg_needed/90
  while (n_rotation_needed > 0){
    df <- rotate(df)
    n_rotation_needed <- n_rotation_needed - 1}
  df <- as.data.frame(sapply(df,as.numeric)) #if the header is a string, the sample will be automatically assumed to be a str, which becomes problematic when normalizing.
  # 3. normalize the rotated df
  output <- normalise(df = df,control_neg_column = 1,control_pos_column = 2) #change if negative and positive column not on far left
  # 4. Return and announce completion
  return(output)
  
  input_name = tools::file_path_sans_ext(neut_xlsx_path)
  print(paste0("Finished processing:",neut_xlsx_path))
}

#grab file name of all relevant sheet
neut_raw_files = Sys.glob(
  paste0(input_directory,"*.xlsx")) # find all .xlsx file in input directory
#final test
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

