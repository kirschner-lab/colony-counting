library(readr)  # read_csv
library(dplyr)  # mutate
library(scales) # trans_format, math_format
library(ggplot2)

## Read in the source data.
df <- read_csv("../../results/03-spreadsheet-cfu/abx-cfu.csv",
               col_types = "cdii")

## Create the log-log plot.
label_10exp <- trans_format("log10", math_format(10^.x))
df %>%
    ## Use fake concentration for untreated for to show on plot.
    mutate(conc_ug_per_ml =
               ifelse(abx == "Untreated", 1e-3, conc_ug_per_ml)) %>%
    ggplot(aes(conc_ug_per_ml, cfu_per_ml, color = abx)) +
    geom_point() +
    geom_smooth(method = lm, formula = y ~x) +
    scale_x_log10(labels = label_10exp) +
    scale_y_log10(labels = label_10exp) +
    labs(x = "Drug concentration (ug/ml)",
         y = "CFU concentration (CFU/ml)",
         color = "Antibiotic")

## Save the plot.
ggsave("../../results/04-plots-cfu/log-log.png", width = 6, height = 2)
