library(readxl)  # read_excel
library(purrr)   # map_df
library(stringr) # str_remove_all
library(dplyr)   # filter, mutate, rename
library(tidyr)   # fill, separate
library(ggplot2)
library(broom)   # augment

file_metadata <- "../../data/plateDescriptions_colonyCountPaper.xlsx"

## Conditions and treatment times.
(df_cond <-
     read_excel(file_metadata, n_max = 10) %>%
     fill(1:ncol(.)) %>%
     rename(cond = 1, trt_days = 2, cond_microenv = 3) %>%
     mutate(cond = str_remove_all(cond, regex("[()]")),
            cond_label = str_extract(cond, "[:graph:]+$"),
            cond = str_remove(cond, " [:graph:]+$"),
            trt_days = as.integer(str_extract(trt_days, regex("^\\d+"))),
            trt_label = str_c("T", trt_days)) %>%
     select(1, cond_label, trt_days, trt_label, everything()) %>%
     bind_rows(setNames(
         list("High Cholesterol", "HC", -1, "PT", "replicating extracellular Mtb"),
         colnames(.))) %>%
     arrange(cond, trt_days)
     ## HC and Dorm time points are swapped.
)

## Antibiotics names and concentrations.
(df_abx <-
     read_excel(file_metadata, skip = 11, n_max = 13) %>%
     fill(1) %>%
     rename(abx = 1, ug_per_ml = 2) %>%
     mutate(abx = str_remove_all(abx, regex("[()]")),
            ug_per_ml = str_remove_all(ug_per_ml, regex("[()]"))) %>%
     separate(2, c("conc_ug_per_ml", "conc_label"), sep = " ", convert = TRUE) %>%
     separate(1, c("abx", "abx_label"), sep = " ", convert = TRUE) %>%
     bind_rows(setNames(list("Untreated", "Unt", 0.0, 0L), colnames(.)))
)

file_csv <- "../../results/03-spreadsheet-cfu/Bactericidal Assay Data.xlsx"
sheets <-
    excel_sheets(file_csv) %>%
    subset(! str_detect(., "Averaged|0[.]75|^Sheet|^DormT2$"))
df_all <-
     map(sheets, read_excel, path = file_csv) %>%
     setNames(sheets)
cols_all <- map(df_all, colnames)
cols <- cols_all[[1]]
for (i in 2:length(cols_all)) {
    cols <- intersect(cols, cols_all[[i]])
}
df <-
    df_all %>%
    ## Only select common columns.
    map(select, all_of(cols)) %>%
    ## Make "Drug concentration" numeric.
    map(mutate,
        `Drug Concentration` =
            as.numeric(ifelse(`Drug Concentration` == "Unt",
                              NA, `Drug Concentration`))) %>%
    ## Combine.
    bind_rows() %>%
    ## Shorten labels.
    rename(cond = 1, time = 2, drug = 3, drug_conc = 4, rep = 5,
           quadrant = 6, count = 7, cfu_per_ml = 8) %>%
    ## Replace concentration labels with densities.
    mutate(conc_label = ifelse(drug_conc %in% 1:4, drug_conc, NA)) %>%
    left_join(df_abx %>% select(-abx),
              by = c("drug" = "abx_label", "conc_label")) %>%
    mutate(drug_conc = ifelse(! is.na(conc_ug_per_ml),
                              conc_ug_per_ml, drug_conc)) %>%
    select(-conc_label, -conc_ug_per_ml) %>%
    ## Fake concentration for untreated.
    mutate(drug_conc = ifelse(drug == "Unt", 1e-3, drug_conc)) %>%
    ## Add full drug names.
    left_join(df_abx %>% select(abx, abx_label),
              by = c("drug" = "abx_label"))

## Plot linear trajectories.
ggplot(df, aes(drug_conc, cfu_per_ml, color = abx)) +
    facet_wrap(~ cond + time) +
    geom_point() +
    geom_smooth() +
    scale_x_log10() +
    scale_y_log10()

## Plot decreasing exponential trajectories.
df %>%
    rename(Condition = cond, `Time (days)` = time) %>%
    ggplot(aes(drug_conc, cfu_per_ml, color = abx)) +
    facet_wrap(~ Condition + `Time (days)`, labeller = "label_both") +
    geom_point() +
    geom_smooth(method = lm, formula = y ~ exp(-x)) +
    scale_x_log10() +
    scale_y_log10() +
    labs(x = "Drug concentration (ug/ml)",
         y = "CFU concentration (CFU/ml)",
         color = "Antibiotic")
