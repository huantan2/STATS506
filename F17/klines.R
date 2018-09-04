## Assuming bivariate data from k-lines, use kmeans extension to cluster points and learn the lines

n = 100
X = cbind(1, rnorm(n))
beta0 = runif(2)
beta1 = runif(2)
z0 = X %*% beta0
z1 = X %*% beta1
clust0 = sample(c(0,1), n, replace=TRUE)
y = as.vector(z0*{1-clust0} + z1*clust0 + rnorm(n, 0, .1))
plot(y~X[,2])

#fit = .lm.fit(X,y)
#fit$residuals
#C_Cdqrls

## given clusters, learn lines: return as 2xk matrix
getlines <- function(j,x,y,clusters){
	ind <- which(clusters==j)
	coef(lm(y[ind]~x[ind]))
}
mstep <- function(x,y,clusters,k){
	out <- sapply(1:k,getlines,x=x,y=y,clusters=clusters)
}

## given lines, assign points to clusters ##
estep <- function(coefficients,x,y){
	dist <- {y-cbind(1,x) %*% coefficients}^2
	clusters <- apply(dist,1,which.min)
	rss <- sum(diag(dist[,clusters]))
	return(list(clusters=clusters,rss=rss))
}

klines <- function(x,y,k,epsilon=1e-4,max.iter=1e4){
  # First iteration
	clusters <- sample(1:k,length(x),replace=T)
	coefficients <-  mstep(x,y,clusters,k)
	e <- estep(coefficients,x,y)		
	rss.vec = e$rss
	delta <- 1
	n.iter <- 1
	
	while(delta > epsilon & n.iter <= max.iter){
	  n.iter <- n.iter + 1
		coefficients <-  mstep(x,y,e$clusters,k)
		e <- estep(coefficients,x,y)		
		delta <- rss.vec[n.iter-1] - e$rss
		rss.vec[n.iter] <- e$rss
	}
	return(list(clusters=clusters,coefficients=coefficients,rss.vec=rss.vec,n.iter=n.iter))
}


kl_fit = klines(X[,2],y,2)
names(kl_fit)
kl_fit$coefficients

