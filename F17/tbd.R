## 1. Read the function below, determine what it does,
##    and write a one sentence description. 
## 2. Write appropriate comments in the locations indicated.
## 3. What would be an appropriate name for this function?
## 4. What are appropriate names for the returned values?
## 5. Why is the check at the beginning necessary? 
##    Write an apporiate error message.
## 6. What types are appropriate for f, a, and b?

tbd_3 <- function(f, a, b, tol=.Machine$double.eps, max_iter=1e3) {

  ## 2a. Write an appropriate comment for here.
  fa = f(a)
  if (fa*f(b) > 0) {
    stop("5a. Write an error message here.")
  } else {
    ## 2b. Write another comment here.
    if ( fa < 0 ) {
      x0 = a 
      x1 = b
    } else {
      x0 = b
      x1 = a
    }
  }

  ## 2c. Write a third comment here.  
  iter = 0
  while (iter<=max_iter) {
    m = .5*{x0 + x1}
    fm = f(m)
    
    ## 2d. Write a comment here.
    if (abs(fm) < tol) {
      break
    }
    
    ## 2e. Write a final comment here.
    if (fm > 0) {
      x1 = m
    } else {
      x0 = m
    }
    iter = iter + 1 
  }

  if (iter<max_iter) {
    msg = "Function value within tolerance."
  } else {
    msg = sprintf("Reached max_iter=%i; value may not be accurate.", max_iter)
  }
            
  return( list( four_a=m, four_b=fm, four_c=msg ) )    
}
