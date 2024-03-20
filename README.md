# NormaliseForIC50
## pre-process data to return normalise IC50 curves for direct input into PRISM

This script automates the normalization process for neutralization assays performed on a 96-well plate read on the Promega system, and more generally, serial dilution results with columns/rows of negative and positive controls. <br />
This script achieved [perfect concordance](https://github.com/TKMarkCheng/NormaliseForIC50/edit/main/README.md#validation) with the normalization in PRISM (R=1.0, ρ<2.2e-16).

**INPUT**: The script currently only reads in the **.xlsx file** outputs from Promega in a given directory. <br />
**OUTPUT**: 0 to 100 normalized data sheets collated into the same .xlsx file that can be imported/copied and pasted back to PRISM for IC50 curve fitting.

# Installation
Install from github using devtools.

```
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("TKMarkCheng/NormaliseForIC50")
```

# To use the script
## Method 1
loaded onto R via
```
if(!require("devtools"))install.packages("devtools",repos="http://cran.us.r-project.org")
devtools::install_github("TKMarkCheng/NormaliseForIC50")
```
A detailed tutorial is available at [`vignettes/introduction.html`](articles/introduction.html).
- It is very important that you change the input_file, input_directory, and output_file path and names to your own.

## Method 2
0. Clone/Download the github repository.
1. Move all the Promega read .xlsx files into the same folder (your `input_directory`)
2. In the `normalisation.R` script, Change the `input_directory`, `input_file` and `output_file` to appropriate names
    + input_directory=The folder you made on step 2 where you keep all your Promega read .xlsx files
    + input_file=Any file from your input_directory as a sanity check.
    + output_file=What you want to name the new Excel file (default=test.xlsx)
3. Run `normalisation.R` from start to finish

## Rotated Plate
Rotation defaults to 0 (A1 at top left corner). <br />
In cases where the plate was accidentally rotated, or a vertical serial dilution was performed, we can clockwise rotate the read orientation by a multiple of 90° by changing `rotate_by`.

## Validation
Validation set of 10 plates. Further details can be seen in the `Validation` directory. <br />
<img src="man/figures/validation_correlation_plot.png" align="center" height="400" style = "float:center;height:400px;"/>

# Using a Plate Map
A detailed tutorial is available at [`vignettes/How_to_integrate_a_platemap.html`](articles/How_to_integrate_a_platemap.html)
If you're using modifying a prior made plate map, a strict format of the platemap as specified in `Validation/validation_output/example_generated_platemap_manual_changes.xlsx` must be followed.

# Common issues
```
Error in utils::unzip(zip_path, list = TRUE) :
zip file '\~$.xlsx' cannot be opened`
```
You Need to close that (and all) excel file in your target directory for R to be able to read it.