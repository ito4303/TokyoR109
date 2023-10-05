#
# example for NIMBLE
#

# Import packages
library(nimble)
library(posterior)
library(bayesplot)

# Settings

set.seed(123)
data_dir <- "data"
script_dir <- "scripts"
data_file <- file.path(data_dir, "data.rds")
datagen_script <- file.path(script_dir, "datagen.R")

# Data

if (file.exists(data_file)) {
  Y <- readRDS()
} else {
  source(datagen_script)
}

# NIMBLE

code <- nimbleCode({
  for (n in 1:N) {
    Y[n] ~ dnegbin(p, phi)
    # replicated data
    yrep[n] ~ dnegbin(p, phi)
  }
  # priors
  p ~ dunif(0, 1)
  phi ~ dunif(0, 100)
})

init_fun <- function() {
  list(p = runif(1, 0, 1),
       phi = runif(1, 0, 2),
       yrep = rpois(length(Y), 3))
}

fit <- nimbleMCMC(code,
                  constants = list(N = length(Y)),
                  data = list(Y = Y),
                  inits = init_fun,
                  monitors = c("p", "phi", "yrep"),
                  nchains = 3,
                  niter = 4000, nburnin = 2000,
                  samplesAsCodaMCMC = TRUE) |>
  as_draws()

# Trace

mcmc_trace(fit, pars = c("p", "phi"))

# Summary

fit |>
  subset_draws(variable = c("p", "phi")) |>
  summary()

## Posterior predictive check using rootogram

yrep <- fit |>
  subset_draws(variable = "yrep") |>
  as_draws_matrix()

ppc_rootogram(Y, yrep, style = "standing")
