data {
  int<lower=0> N;
  array[N] int Y;
}

parameters {
  real<lower=0> mu;
  real<lower=0> phi;
}

model {
  Y ~ neg_binomial_2(mu, phi);
  mu ~ normal(0, 10);
  phi ~ normal(0, 5);
}

generated quantities {
  array[N] int yrep;

  for (n in 1:N)
    yrep[n] = neg_binomial_2_rng(mu, phi);
}
