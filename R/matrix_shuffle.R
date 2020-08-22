#' @importFrom Matrix sparseMatrix
#' @keywords internal
row_shuffle_matrix_ <- function(rows) {
  return(
    sparseMatrix(i = 1:length(rows), j = rows, x = 1)
  )
}
  
#' @title Re-order a similarity matrix
#' @description Re-order columns / rows of a similarity matrix based on a given permutation.
#' @param X Matrix
#' @param row_order Integer vector, a permutation of \code{1:nrow(m)}.
#' @return A re-arranged similarity matrix (sparse & symmetric)
sim_matrix_shuffle <- function(X, row_order) {
  sh <- row_shuffle_matrix_(row_order)
  return (sh %*% X %*% sh)
}

