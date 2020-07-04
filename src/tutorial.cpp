#include <Rcpp.h>
using namespace Rcpp;

//' Sum up a matrix
//' 
//' @param m A numeric matrix
//' @export
// [[Rcpp::export]]
float sumCpp(NumericMatrix m) {
  int nrow = m.nrow();
  int ncol = m.ncol();
  // Rcpp::NumericMatrix S();
  float sum = 0.0;
  
  for (int i = 0; i < nrow; ++i) {
    for (int j = 0; j < ncol; ++j) {
      sum = sum + m(i,j);
    }
  }
  
  return sum;
}


//' Transpose a matrix
//' 
//' @param m A numeric matrix
//' @export
// [[Rcpp::export]]
NumericMatrix tCpp(NumericMatrix m) {
  int nrow = m.nrow();
  int ncol = m.ncol();
  NumericMatrix mt(ncol, nrow);
  
  for (int i = 0; i < nrow; ++i) {
    for (int j = 0; j < ncol; ++j) {
      mt(j,i) = m(i,j);
    }
  }
  
  return mt;
}

/***R
m <- matrix(rnorm(12), ncol = 4)
tCpp(m)
t(m)
*/