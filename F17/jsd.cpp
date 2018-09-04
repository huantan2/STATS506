#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

// [[Rcpp::export]]
NumericMatrix jsd(NumericMatrix x) {
  int i, j, n = x.nrow();
  NumericMatrix rmat(n,n,0);
  NumericMatrix::Row 
  for(i=0; i<n; i++)
    {
      
    }
  
  
  return rval;
}

double kld(std::vector<double> a, std::vector<double> b) {
  int i;
  double rval = 0;
  for(i=0; i<a.size(); i++){
    if(a(i) > 0 && b(i)>0)
      {
        rval += std::log(a(i)/b(i))*a(i);
      }
  }
}

// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R
timesTwo(42)
*/
