#
# plot.R
#

# Import packages
library(cmdstanr)
library(posterior)
library(bayesplot)
library(ggplot2)
library(patchwork)

# Settings

data_dir <- "data"
data_file <- "data.rds"
model_dir <- "models"
poisson_model_file <- "poisson.stan"
negbin_model_file <- "negbin.stan"
fig_dir <- "figures"
fig_standing <- "standing.png"
fig_hanging <- "hanging.png"
fig_suspended <- "suspended.png"
fig_width <- 1920
fig_height <- fig_width / 2
scale <- 1

# Data

Y <- readRDS(file.path(data_dir, data_file))

# Stan

stan_data <- list(N = length(Y), Y = Y)

# Poisson distribution

mod_pois <- cmdstan_model(file.path(model_dir, poisson_model_file))
fit_pois <- mod_pois$sample(data = stan_data,
                            iter_warmup = 1000, iter_sampling = 1000)
yrep_pois <- fit_pois$draws("yrep") |>
  as_draws_matrix()

# Negative binomial distribution

mod_nb <- cmdstan_model(file.path(model_dir, negbin_model_file))
fit_nb <- mod_nb$sample(data = stan_data,
                        iter_warmup = 1000, iter_sampling = 1000)
yrep_nb <- fit_nb$draws("yrep") |>
  as_draws_matrix()

# Plot

bayesplot_theme_update(legend.position = "none")
pois_stand <- ppc_rootogram(Y, yrep_pois, prob = 0.9,
                            style = "standing") +
  ggtitle(label = "Poisson")
pois_hang <- ppc_rootogram(Y, yrep_pois, prob = 0.9,
                           style = "hanging") +
  ggtitle(label = "Poisson")
pois_suspend <- ppc_rootogram(Y, yrep_pois, prob = 0.9,
                              style = "suspended") +
  ggtitle(label = "Poisson")

bayesplot_theme_update(legend.position = "right")
nb_stand <- ppc_rootogram(Y, yrep_nb, prob = 0.9,
                          style = "standing") +
  ggtitle(label = "Negative binomial")
nb_hang <- ppc_rootogram(Y, yrep_nb, prob = 0.9,
                         style = "hanging") +
  ggtitle(label = "Negative binomial")
nb_suspend <- ppc_rootogram(Y, yrep_nb, prob = 0.9,
                            style = "suspended") +
  ggtitle(label = "Negative binomial")

# Patchwork

pois_stand + nb_stand
ggsave(fig_standing, device = png, path = fig_dir,
       width = fig_width, height = fig_height, units = "px",
       scale = scale)

pois_hang + nb_hang
ggsave(fig_hanging, device = png, path = fig_dir,
       width = fig_width, height = fig_height, units = "px",
       scale = scale)

pois_suspend + nb_suspend
ggsave(fig_suspended, device = png, path = fig_dir,
       width = fig_width, height = fig_height, units = "px",
       scale = scale)

