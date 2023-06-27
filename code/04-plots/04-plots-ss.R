library(readr)
library(readxl)
library(stringr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(broom)
library(forcats)

## Read all observations to check agreement between manual and
## automated counts.
file_csv_all <- "data/data-collection.csv"
df_all <-
    read_csv(file_csv_all, show_col_types = FALSE) %>%
    `colnames<-`(c("plate", "trt", "time", "drug", "drug_conc", "rep",
                   "quadrant", "count_auto", "count_manual", "count_abs_diff",
                   "min_eccentricity", "max_minor_axis_len", "notes")) %>%
    mutate(time = as.integer(str_remove(time, "^T")))

## Separate error values:
keep <- df_all$count_auto %>% grepl(pattern = "\\d+")
df <-
    df_all %>%
    filter(keep) %>%
    mutate(across(rep:count_abs_diff, as.integer))

## Show agreement of manual with semi-automated colony counts.
model <- lm(count_auto ~ count_manual - 1, df)
df_fit <- augment(model)
ggplot(df_fit, aes(count_manual, count_auto)) +
    geom_point(alpha = .5) +
    coord_fixed() +
    ## geom_abline(slope = 1, intercept = c(0, 0)) +
    geom_smooth(method = "lm", formula = y ~ x - 1) + # -1 omits the intercept.
    labs(x = "Manual count", y = "Semi-automatic count")

breaks = trans_breaks("log10", function(x) 10^x, n = 4)
labels = trans_format("log10", math_format(10^.x))
limits = c(10^0, 10^3)
ggplot(df_fit, aes(count_manual, count_auto)) +
    geom_point(alpha = .5) +
    scale_x_log10(breaks = breaks, labels = labels, limits = limits) +
    scale_y_log10(breaks = breaks, labels = labels, limits = limits) +
    ## geom_abline(slope = 1, intercept = c(0, 0)) +
    geom_smooth(method = "lm", formula = y ~ x - 1) + # -1 omits the intercept.
    labs(x = "Manual count", y = "Semi-automatic count")

scale <- 190 / 3 # mm
ggsave("results/04-plots-cfu/manual-semiauto.jpg",
       width = 3 * scale,
       height = 3 * scale,
       units = "mm",
       dpi = 300)

df_fit

## Show error.
df_fit %>%
    ggplot(aes(.resid)) +
    geom_histogram(binwidth = 5) +
    ggtitle("Residual distribution")

## Fit error to N(mu, sigma).
df_fit %>%
    ggplot(aes(.resid)) +
    geom_histogram(aes(y = ..density..), binwidth = 5) +
    stat_function(color = "red",
                  fun = dnorm,
                  args = list(
                      mean = mean(df_fit$.resid, na.rm = TRUE),
                      sd = sd(df_fit$.resid, na.rm = TRUE)))##  +
    ## ggtitle("Residual density fitted to a Normal distribution")



## Sanity check group sizes.
df %>%
    group_by(trt, time, drug, drug_conc) %>%
    count() %>%
    summary()

## Choose median value and Calculate CFU values from colony counts.
df_med <-
    df %>%
    filter(! drug %in% c("PT", "Unt")) %>%
    group_by(trt, time, drug, drug_conc) %>%
    summarize(count_auto = median(count_auto)) %>%
    left_join(df %>% select(trt, time, drug, drug_conc, count_auto, quadrant),
              by = c("trt", "time", "drug", "drug_conc", "count_auto")) %>%
    mutate(cfu_per_ml = count_auto * 10 ^ quadrant / 0.05) %>%
    drop_na() %>%
    ungroup()

## Plot bacteriacidal curves.
df_med %>%
    ggplot(aes(drug_conc, cfu_per_ml, color = trt,
               group = interaction(trt, time, drug))) +
    geom_point() +
    geom_line() +
    facet_wrap(~ drug + time,
               scales = "free_y",
               labeller = "label_both") +
    labs(color = "Microenvironment",
         y = "CFU / mL",
         x = "[drug]")

## Read in concentrations.
file_metadata <- "data/plateDescriptions_colonyCountPaper.xlsx"
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

## Read only the usable data.
file_csv <- "data/usable-data.csv"
df <-
    read_csv(file_csv, col_select = 1:9, show_col_types = FALSE) %>%
    rename(image = 1, cond = 2, time_days = 3, abx_label = 4, conc_label = 5,
           rep = 6, quadrant = 7, counts = 8, cfu_per_ml = 9) %>%
    ## Remove unused columns.
    select(-1, -7) %>%
    ## PT is an untreated time point, not an antibiotic!
    mutate(conc_label = ifelse(time_days == "PT", 0, conc_label),
           conc_label = ifelse(time_days == "PT", "Unt", conc_label)) %>%
    mutate(conc_label = as.integer(ifelse(conc_label == "Unt", 0, conc_label))) %>%
    ## Add concentrations.
    inner_join(df_abx) %>%
    ## Fix factor order.
    mutate(time_days = as.integer(str_extract(time_days, "\\d+$")))

## Plot linear trajectories.
df %>%
    rename(Condition = cond, `Time (days)` = time_days) %>%
    mutate(conc_ug_per_ml = ifelse(abx_label == "Unt", 1e-3, conc_ug_per_ml)) %>%
    ## filter(cfu_per_ml != 0) %>%
    ggplot(aes(conc_ug_per_ml, cfu_per_ml, color = abx)) +
    facet_wrap(~ Condition + `Time (days)`,
               labeller = "label_both"
               ## labeller = labeller(Condition = label_both,
               ##                     `Time (days)` = label_both,
               ##                     .multi_line = FALSE)
               ) +
    geom_point() +
    geom_smooth(method = lm## , formula = y ~ exp(-x)
                ) +
    scale_x_log10() +
    scale_y_log10() +
    labs(x = "Drug concentration (ug/ml)",
         y = "CFU concentration (CFU/ml)",
         color = "Antibiotic")

ggsave("results/04-plots-cfu/log_drug-log_cfu.pdf", )

## Plot error bar trajectories.
df %>%
    mutate(conc_ug_per_ml = ifelse(abx_label == "Unt", 1e-3, conc_ug_per_ml)) %>%
    group_by(conc_ug_per_ml, cond, time_days, abx) %>%
    mutate(ymin = min(subset(cfu_per_ml, cfu_per_ml != 0)),
           ymax = max(cfu_per_ml)) %>%
    ## filter(cfu_per_ml != 0) %>%
    rename(Condition = cond, `Time (days)` = time_days) %>%
    ggplot(aes(conc_ug_per_ml, cfu_per_ml, color = abx,
               group = interaction(abx, conc_ug_per_ml))) +
    facet_wrap(~ Condition + `Time (days)`,
               labeller = "label_both"
               ## labeller = labeller(Condition = label_both,
               ##                     `Time (days)` = label_both,
               ##                     .multi_line = FALSE)
               ) +
    geom_point() +
    geom_errorbar(aes(ymin = ymin, ymax = ymax)) +
    scale_x_log10() +
    scale_y_log10() +
    labs(x = "Drug concentration (ug/ml)",
         y = "CFU concentration (CFU/ml)",
         color = "Antibiotic")

ggsave("results/04-plots-cfu/log_drug-log_cfu-errorbar.pdf", )
