library(tidyverse)
library(mixtools) # normalmixEM

## Read image creation times.
files <- dir("results/01-fiji-images/", full.names = TRUE)
df <-
    file.info(files, extra_cols = FALSE) %>%
    as_tibble() %>%
    bind_cols(file = basename(files), .) %>%
    select(file, ctime)

## Ignore mask creation time because it will be a few seconds after
## the photo creation time, whereas the goal of this script is to find
## the typical time to process a quadrant.
times <-
    df %>%
    filter(! str_detect(file, "mask")) %>%
    pull(ctime) %>%
    sort() %>%
    as_datetime() %>%
    diff() %>%
    sort()
mins <- as.numeric(times)

summary(mins) # median = 4 minutes.

dists <- normalmixEM(mins, mu = c(median(mins),
                                  mean(mins)))
mu1 <- dists$mu[1]
sd1 <- dists$sigma[1]
mu2 <- dists$mu[2]
sd2 <- dists$migma[2]
## dists <- gammamixEM(mins)## , lambda = c(median(mins),
##                          ##             mean(mins)))
## alpha1 <- with(as.list(dists$gamma.pars[, 1]), alpha)
## beta1 <- with(as.list(dists$gamma.pars[, 1]), beta)
## mu1 <- alpha1 / beta1
## sd1 <- alpha1 / beta1^2
## alpha2 <- with(as.list(dists$gamma.pars[, 2]), alpha)
## beta2 <- with(as.list(dists$gamma.pars[, 2]), beta)
## mu2 <- alpha2 / beta2
## sd2 <- alpha2 / beta2^2

tibble(mins = mins) %>%
    ggplot(aes(mins)) +
    geom_rug() +
    stat_function(fun = dnorm, args = list(mean = mu1, sd = sd1)) +
    stat_function(fun = dnorm, args = list(mean = mu2, sd = sd2)) +
    ## stat_function(fun = dgamma, args = list(shape = alpha1, rate = beta1)) +
    ## stat_function(fun = dgamma, args = list(shape = alpha2, rate = beta2)) +
    scale_x_log10()

tibble(mins = mins) %>%
    filter(mins > mu1 - 2*sd1,
           mins < mu1 + 2*sd1) %>%
    ggplot(aes(mins)) +
    geom_rug() +
    stat_function(fun = dnorm, args = list(mean = mu1,
                                           sd = sd1)) +
    geom_vline(xintercept = mu1) +
    labs(title = "Normal distribution (\u03BC = 4.60, \u03C3 = 2.33) fit to Fiji processing time",
         subtitle = "Rug plot of data shown to 2 standard deviations",
         x = "Minutes between timestamps of saved\nFiji processed TIFF files",
         y = "Probability density")

ggsave("results/04-plots-cfu/fiji-time.png", width = 7, height = 4)
