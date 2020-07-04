#' @importFrom Matrix Matrix
#' @title Sparse block-matrix builder 
#' @description build a sparse block matrix of 1's along the diagonal, based on a vector of block sizes
#' @param blocks A vector of integers corresponding to block sizes, from top left to bottom right (along the diagonal)
#' @param values A vector of values for each block or a single value for all blocks. Default is 1
#' @export
sparse_block_matrix <- function(blocks, values = 1) {
  if (length(values) > 1 & length(blocks) != length(values)) {stop('number of blocks and values differs')}

  blocks <- as.integer(blocks)
  s <- sum(blocks)
  n <- length(blocks)
  if (length(values) == 1) {values = rep(values, n)}
  block_offset <- 0
  
  B <- Matrix(data = 0, nrow = s, ncol = s, sparse = TRUE)
  
  for (i in 1:n) {
    B[block_offset + (1:blocks[i]), block_offset + (1:blocks[i])] = values[i]
    block_offset <- block_offset + blocks[i]
  }
  
  return(B)
}

