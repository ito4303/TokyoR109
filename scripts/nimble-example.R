#
# example for NIMBLE
#

# Import packages
library(nimble)
library(posterior)
library(bayesplot)

# Settings

data_dir <- "data"
data_file <- "data.rds"

# Data

Y <- readRDS(file.path(data_dir, data_file))

# NIMBLE

code <- nimbleCode({
  for (n in 1:N) {
    Y[n] ~ dnegbin(p, phi)
  }
  p ~ dunif(0, 1)
  phi ~ dunif(0, 100)

  # replicated data
  for (n in 1:N) {
    yrep[n] ~ dnegbin(p, phi)
  }
})

fit <- nimbleMCMC(code,
                  constants = list(N = length(Y)),
                  data = list(Y = Y),
                  inits = list(p = 0.5, phi = 2,
                               yrep = rep(1, length(Y))),
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
