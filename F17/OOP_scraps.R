
To create new S4 generics, we use `setGeneric` and  `standardGeneric`.

```{r}

```

## An S4 Example

```{r}
library(stats4)

# Generate some data
y = rpois(30, 14)

# Write a function to compute negative log likelihood
neg_log_lik <- function(lambda) - sum(dpois(y, lambda, log=TRUE))

fit = mle(neg_log_lik, start=list(lambda=mean(y)), nobs=length(y))
isS4(fit)

fit_profile = profile(fit)
class(fit_profile)
plot(fit_profile)

names(attributes(fit_profile))
diff(fit_profile@profile$lambda[,2])
```

To view the definition of an S4 method, use `getMethod`. 
```{r}
head(getMethod(profile,'mle'))
```