#' @keywords internal
SUPPORTED_METRICS = c('cosine', 'hamming')
#' @keywords internal
ERROR_MESSAGE_METRIC = 'Only cosine and Hamming metric are supported (and custom functions in some cases, see documentation)'
#' @keywords internal


#' @importFrom Matrix Matrix
#' @importFrom Matrix sparseMatrix
#' @importFrom methods as
#' @importFrom parallel makeCluster
#' @importFrom parallel stopCluster
#' @importFrom doParallel registerDoParallel
#' @importFrom foreach %dopar%
#' @importFrom foreach foreach


#' @title Generate similarity matrix using different methods
#' @description A collection of functions that take a numeric / 0-1 integer matrix and calculate row-wise similarity. 
#' @param X A matrix, or an object that can be coerced into a matrix. Values depend on the type of metric used (numeric, 1/0 integers, etc.) 
#' @param metric One of the supported metrics. Currently \code{hamming} or \code{cosine}. For loop based functions you can also specify a function that takes two rows from the raw X and returns a distance
#' @param row_blocks Integer. How to divide matrix rows into blocks for block-wise similarity calculation (using matrix multiplication). Default is 1 which means similarity is calculated in a single step.  
#' @param col_block Integer. Not implemented yet
#' @param thresh Float. Minimal similarity threshold to be returned. Values below are converted to 0 (to allow sparse representation). Default is 0.0
#' @param n_cpu Integer. Number of cores to use for the local cluster (using the \code{doParallel} and \code{parallel} backend). Default is 1 which results in a simple R loop. Negative numbers are interpreted as "all CPU expect".
#' @param cl A cluster object, pointing to the cluster to be used instead of a local cluster. This option overrides the \code{n_cpu} parameter.
#' @return An object of \code{symmetricMatrix} class. Default is a sparse matrix but this can be modified using the \code{sparse} parameter


#' @describeIn sim_loopR Generate sparse similarity matrix using simple R loop in a single thread or a cluster
#' @export 
sim_loopR <- function(X, metric, thresh = 0.0, n_cpu = 1, cl = NA) {
  X <- as.matrix(X)
  
  if (class(metric) == 'character') {
    if (tolower(metric) == 'cosine') {
      storage.mode(X) <- 'numeric'
      X <- X / sqrt(rowSums(X^2))
      row_sim <- function(x, y) {sum(x * y)}  
    } else if (tolower(metric) == 'haming') {
      X <- X != 0.0
      row_sim <- function(x, y) {sum((x & y) + ((!x) & !(y))) / length(x)}
    } else {stop(ERROR_MESSAGE_METRIC)}
  } else if (class(metric) == 'function') {
    row_sim <- metric
  } else {stop(ERROR_MESSAGE_METRIC)}
  
  if (n_cpu == 1 & is.na(cl)) {
    S <- Matrix(data = 0, nrow = nrow(X), ncol = nrow(X), sparse = TRUE)

    for (i in 1:nrow(X)) {
      for (j in 1:i) {
        s <- row_sim(X[i,], X[j,])
        if (s > thresh) {S[i,j] <- s; S[j,i] <- s}
      }
    }    
    
    S <- as(S, 'symmetricMatrix')
    
  } else {
    if (n_cpu <= 0) {n_cpu <- detectCores(logical = FALSE)[1] + n_cpu}
    stop_cl <- FALSE
    if (is.na(cl)) {
      # based on https://github.com/rstudio/rstudio/issues/6692
      cl <- makeCluster(n_cpu, setup_timeout = 0.5)
      stop_cl <- TRUE
    }
    registerDoParallel(cl)
    n <- nrow(X)
    
    raw_S <- foreach(i = 1:n, .combine=rbind) %dopar% {
      row_sim_matrix <- matrix(0, nrow = 0, ncol = 3)
      for (j in i:n) {
        s = row_sim(X[i,], X[j,])
        if (s > thresh) {
          row_sim_matrix <- rbind(row_sim_matrix, c(i, j, s))
        }
      }
      row_sim_matrix
    }
    
    if (stop_cl) {stopCluster(cl)}
    
    S <- sparseMatrix(i = raw_S[,1], j = raw_S[,2], x = raw_S[,3],  symmetric = TRUE)
  }

  return(S)
}


# @describeIn sim_loopR Generate similarity matrix using a C loop
# @export 
sim_loopCpp <- function(X, metric, thresh = 0.0, sparse = TRUE) {
  ## Next step: RcppEigen
  ## Next step: faster with CPU SIMD
  return(NA)
}


#' @keywords internal
cosine_similarity_ <- function(X, Y) {
  return(X %*% Y)
}
#' @keywords internal
hamming_similarity_ <- function(X,Y) {
  return((X %*% Y + (1 - X) %*% (1 - Y)) / ncol(X))
}


#' @describeIn sim_loopR Generate sparse similarity matrix using block-wise matrix multiplication
#' @export 
sim_blocksR <- function(X, metric, row_blocks = 1, thresh = 0.0, n_cpu = 1, cl = NA) {
  X <- as.matrix(X)
  rows <- ceiling(nrow(X) / row_blocks)
  
  if (class(metric) == 'character') {
    if (tolower(metric) == 'cosine') {
      storage.mode(X) <- 'numeric'
      X <- X / sqrt(rowSums(X^2))
      sim_f <- cosine_similarity_
    } else if (tolower(metric) == 'hamming') {
      storage.mode(X) <- 'logical'
      sim_f <- hamming_similarity_
    } else {stop(ERROR_MESSAGE_METRIC)}
  } else {stop(ERROR_MESSAGE_METRIC)}

  if (n_cpu == 1 & is.na(cl)) {
    S_sparse_list <- list()
    
    for (b in 1:row_blocks) {
      row_range <- (1 + (b - 1) * rows):min((b * rows), nrow(X))
      f <- ifelse(length(row_range) > 1, t, identity) # single row is a transposed vector
      Sb <- sim_f(X, f(X[row_range, ]))
      
      if (thresh > 0) {Sb[Sb < thresh] <- 0}
      S_sparse_list[[b]] <- Matrix(Sb, sparse = TRUE)
    }
  } else {
    if (n_cpu <= 0) {n_cpu <- detectCores(logical = FALSE)[1] + n_cpu}
 
    stop_cl <- FALSE
    if (is.na(cl)) {
      # based on https://github.com/rstudio/rstudio/issues/6692
      cl <- makeCluster(n_cpu, setup_timeout = 0.5)
      stop_cl <- TRUE
    }
    registerDoParallel(cl)    
    
    S_sparse_list <- foreach(b = 1:row_blocks, .packages = 'Matrix') %dopar% {
      row_range <- (1 + (b - 1) * rows):min((b * rows), nrow(X))
      f <- ifelse(length(row_range) > 1, t, identity) # single row is a transposed vector
      Sb <- sim_f(X, f(X[row_range, ]))
      
      if (thresh > 0) {Sb[Sb < thresh] <- 0}
      Matrix(Sb, sparse = TRUE)
    }
  }
  
  return(as(Reduce(cbind, S_sparse_list), "symmetricMatrix"))
}
