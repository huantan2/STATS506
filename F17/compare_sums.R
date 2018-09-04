
library(microbenchmark)

rows_first = function(X){
  sum(apply(X,1,sum))
}

cols_first = function(X){
  sum(apply(X,2,sum))
}


X = matrix(rnorm(1e4),1e2,1e3)
microbenchmark(rows_first(X),cols_first(X),sum(X),times=10)
