library(readr)  # read_csv
library(dplyr)  # mutate
library(scales) # trans_format, math_format
library(ggplot2)

## Read in the source data.
df <- read_csv("results/03-spreadsheet-cfu/abx-cfu.csv",
               col_types = "cdiii")

## Calculate limit of detection (LoD)
df_lod_minimal <-
    df %>%
    ## Squash treatment replicates.
    count(abx, limit_of_detection) %>%
    group_by(abx) %>%
    ## Choose most prevalent count.
    filter(n == max(n)) %>%
    ## Break ties with worst case.
    filter(limit_of_detection == max(limit_of_detection)) %>%
    ungroup()

## Add the x-axis for plotting the limit of detection (LoD).
df_lod <-
    df %>%
    select(-limit_of_detection) %>%
    inner_join(df_lod_minimal, by = "abx") %>%
    group_by(abx) %>%
    summarize(conc_ug_per_ml = range(conc_ug_per_ml),
              limit_of_detection = mean(limit_of_detection)) %>%
    rename(cfu_per_ml = limit_of_detection)
## Nudge the untreated minimum and maximum values.
df_lod[df_lod$abx == "Untreated", 2] <- 1e-3 * c(0.8, 1.5)
## Create the log-log plot.
label_10exp <- trans_format("log10", math_format(10^.x))
df %>%
    ## Use fake concentration for untreated for to show on plot.
    mutate(conc_ug_per_ml =
               ifelse(abx == "Untreated", 1e-3, conc_ug_per_ml)) %>%
    ggplot(aes(conc_ug_per_ml, cfu_per_ml, color = abx)) +
    geom_point() +
    geom_smooth(method = lm, formula = y ~x) +
    geom_line(data = df_lod, linetype = 2) +
    scale_x_log10(labels = label_10exp) +
    scale_y_log10(labels = label_10exp) +
    labs(x = "Drug concentration (ug/ml)",
         y = "Colony forming units (CFU)/ml",
         color = "Antibiotic")

## Save the plot.
scale <- 2.5
ggsave("results/04-plots-cfu/log-log.png",
       width = 3 * scale,
       height = 1 * scale)
