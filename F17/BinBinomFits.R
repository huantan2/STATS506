## A method for binomial glm fits to bin data points according
## to the predicted probabilities.

bin_pred <- function(obj, n_bins=NULL){
  # Do some basic error checking
  stopifnot(any('glm' %in% class(obj)))

  # if n_bins is not specified 
  # set a default using 'hist'
  if(is.null(n_bins)){
    n_bins = nclass.Sturges(obj$fitted.values)
  }
  
  bins = seq(0, 1, length.out=n_bins)
  
  ## summarize bins in each group
  tibble(fitted=obj$fitted.values, y=obj$y) %>%
    mutate(bin = sapply(fitted, function(yhat) max(which(yhat >= bins)))) %>%
    group_by(bin) %>% 
    summarize(Obs=mean(y),Pred=mean(fitted))

}

fit1 = glm(es_fridge ~ 0 + region + totsqft, data=recs,
           family=binomial(link='probit'))
binned = bin_pred(fit0)
binned = bin_pred(fit0)

bind_rows(bin_pred(fit0) %>% mutate(type='logit'),
          bin_pred(fit1) %>% mutate(type='probit')) %>%
  ggplot(aes(x=Pred,y=Obs,col=type)) + geom_point()

AIC(fit1)
AIC(fit0)
