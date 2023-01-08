library(readr)   # read_csv
library(dplyr)   # select, mutate, rename_with, across, stars_with
library(stringr) # str_remove

## Read in the CellProfiler colony counts.
df_cp <- read_csv(
    "../../results/02-cellprofiler-spreadsheet-counts/Image.csv",
    show_col_types = FALSE,
    ## Broadly subset to these columns.
    col_select = c(
        "Count_Colonies",
        starts_with("FileName"),
        starts_with("Metadata"))) %>%
    ## Remove columns with all NA values or all zeroes.
    select(where(~ ! (all(is.na(.x)) ||
                      all(.x == 0)))) %>%
    ## Convert all numeric columns to integers.
    mutate(across(where(is.numeric), as.integer)) %>%
    ## Drop "Metadata_" prefix from column names.
    rename_with(~ str_remove(.x, "Metadata_"), starts_with("Metadata")) %>%
    ## Convert column names to lower case.
    rename_with(tolower)

## Read in the treatment concentrations and plate locations.
df_meta <- read_csv(
    "../../data/metadata.csv",
    show_col_types = FALSE)

## Merge the CellProfiler and treatment metadata and calculate CFU.
df <-
    df_meta %>%
    ## Merge columns to match the written treatment label.
    mutate(treatment = ifelse(abx_label == "Unt", "Unt",
                              str_c(abx_label, conc_label))) %>%
    ## Merge CellProfiler table with metadata.
    inner_join(df_cp, by = "treatment") %>%
    ## Calculate CFU concentration.  Plate has 50 ul; convert to ml.
    mutate(cfu_per_ml = count_colonies * 10^(-quadrant) * 1000 / 50) %>%
    select(abx, conc_ug_per_ml, cfu_per_ml, replicate)

## Save output
write_csv(df, "../../results/03-spreadsheet-cfu/abx-cfu.csv")
