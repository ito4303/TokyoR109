data {
  int<lower=0> N;
  array[N] int Y;
}

parameters {
  real<lower=0> lambda;
}

model {
  Y ~ poisson(lambda);
  lambda ~ normal(0, 10);
}

generated quantities {
  array[N] int yrep;

  for (n in 1:N)
    yrep[n] = poisson_rng(lambda);
}
