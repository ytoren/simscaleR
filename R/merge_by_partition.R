#' @keywords internal
merge_rows_ <- function(m, row_range, agg = Matrix::colSums) {
  N <- nrow(m)
  end <- max(row_range)
  start <- min(row_range)
  
  if (end > N | start < 1) { stop('start / end should match matrix size') }
  if (start == 1 & end == N) { return(agg(m)) }
  
  if (start == 1) {
    m_above <- NULL
  } else {
    m_above <- m[1:(start - 1), ]
  }
  
  if (end == N) {
    m_below <- NULL
  } else {
    m_below <- m[(end + 1):N, ]
  }
  
  return(rbind(m_above, agg(m[start:end, ]), m_below))
}


#' @keywords internal
merge_rows_by_partition_ <- function(m, partition, merge_order, agg = Matrix::colSums) {
  for (p in merge_order) {
    if (length(partition[[p]]) == 1) {next}
    m <- merge_rows_(m, partition[[p]], agg)
  }
  
  rownames(m) <- c()
  return(m)
}


#' @title Merge matrix rows by a partition  
#' @description Merge matrix rows according to a continuous partition of row indices 
#' @param m A matrix
#' @param partition A list of integer vectors. Each vector can contain all rows in the group or just first & last rows (min/max will be used to extract range)
#' @param agg Function. The function that will be called to merge the rows. Must return a matrix with the same number of columns and as many rows as needed. Default is `colSums`.
#' @return A new matrix with less (or more?) rows, depending on the aggregation function.
merge_by_partition <- function(m, partition, agg = Matrix::colSums) {
  ## Check that partition is... a partition
  if (!all(sort(unlist(partition)) == 1:nrow(m))) {stop('Missing / too many indices in partition')}
  invisible(
    lapply(
      partition, 
      function(x) {
        if (!all(sort(x) == min(x):max(x))) {
          stop(paste0('Non-continuous partition: ', paste(x, collapse = ',')))
        }
      }
    )
  )
  
  # To maintain index relevance we start from the last partition and go back
  merge_order <- order(
    unlist(lapply(partition, min)), 
    decreasing = TRUE
  )

  m_col_merged <- t(merge_rows_by_partition_(m, partition, merge_order))
  return(merge_rows_by_partition_(m_col_merged, partition, merge_order))
}

