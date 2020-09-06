#' @importFrom parallel mclapply
#' @importFrom Matrix Matrix
#' @importFrom Matrix t

#' @keywords internal
is_partition_ <- function(partition, first, last) {
  p <- unlist(partition)
  if (length(p) == last - first + 1) {
    if (any(sort(p) != first:last)) {
      return(TRUE)
    }
  }
  return(FALSE)
}

#' @keywords internal
merge_rows_by_partition_ <- function(m, partition, agg, n_cpu) {
  f <- function(p) {Matrix::Matrix(agg(m[p, , drop = FALSE]), sparse = TRUE, nrow = 1)}

  if (n_cpu==1) {
    s <- lapply(partition, f)
  } else {
    s <- parallel::mclapply(partition, f, mc.cores = n_cpu)
  }

  return(do.call(rbind, s))
}

#' @title Merge matrix rows/columns by a partition  
#' @description Merge matrix rows/columns according to a partition of row indices 
#' @param m A matrix
#' @param partition A list of integer vectors, which makes a full partition of the rows of \code{m}
#' @param agg Function. The function that will be called to merge the rows. Must return a matrix with the same number of columns and as many rows as needed. Default is \code{colSums}.
#' @param n_cpu Integer. Number of cores to be used for the calculation, passed to the parameter \code{mc.cores} of the function \code{mclapply}. Default is 1 which means the "regular" \code{lapply} will be used.
#' @param check Logical. Should the function check if the provided partition is valid? Default is \code{FALSE}.
#' @return A new matrix with less (or more?) rows, depending on the aggregation function.
#' @export
merge_by_partition <- function(m, partition, agg = Matrix::colSums, n_cpu = 1, check = FALSE) {
  if (check) {
    if (!is_partition_(partition, 1, nrow(m))) {
      stop('Partition check failed. Please specify a valid partition')
    }
  }

  # Merge rows, transpose (now cols are merged) and merge rows again
  return(
    merge_rows_by_partition_(
      Matrix::t(merge_rows_by_partition_(m, partition, agg, n_cpu)),
      partition, agg, n_cpu
    )
  )
}

