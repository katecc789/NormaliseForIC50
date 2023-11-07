# normalise-for-IC50
pre-process data to return normalise IC50 curves for direct input into PRISM

This script automates the normalization process for neutralization assays performed on a 96-well plate read on the Promega system. <br />
This script achieved [perfect concordance](https://github.com/TKMarkCheng/normalise-for-IC50/edit/main/README.md#validation) with the normalization in PRISM (R=1.0, ρ<2.2e-16).

**INPUT**: The script currently only reads in the **.xlsx file** outputs from Promega in a given directory. <br />
**OUTPUT**: 0 to 100 normalized data sheets collated into the same .xlsx file that can be imported/copied and pasted back to PRISM for IC50 curve fitting.

## Installation
Install from github using devtools.

```
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("TKMarkCheng/normalise-for-IC50")
```

## To use the script
1. Move all the Promega read .xlsx files into the same folder (your `input_directory`)
2. In the `import_neuts.R` script, Change the `input_directory`, `input_file` and `output_file` to appropriate names
    + input_directory=The folder you made on step 2 where you keep all your Promega read .xlsx files
    + input_file=Any file from your input_directory as a sanity check.
    + output_file=What you want to name the new Excel file (default=test.xlsx)
3. Run `import_neuts.R` from start to finish

## Rotated Plate
Rotation defaults to 0 (A1 at top left corner). <br />
In cases where the plate was accidentally rotated, or a vertical serial dilution was performed, we can clockwise rotate the read orientation by a multiple of 90° by changing `rotate_by`.

## Validation
Validation set of 10 plates. Further details can be seen in the `Validation` directory. <br />
![alt text](https://github.com/TKMarkCheng/normalise-for-IC50/blob/main/Validation/correlation_plot.png)
