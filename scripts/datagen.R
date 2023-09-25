#
# Data generation
#

set.seed(123)
data_dir <- "data"
data_file <- "data.rds"

# Negative binomial distribution

N <- 100
mu <- 4
size <- 1
Y <- rnbinom(N, mu = mu, size = size)

# Save data as RDS

saveRDS(Y, file = file.path(data_dir, data_file))

        
