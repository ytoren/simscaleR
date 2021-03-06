#' @title Choose a similarity calculation method based on simple resource estimations
#' @description Estimate number of CPU and memory size for the current system and use these numbers to choose the appropriate calculation method (loops / matrix multiplication, see \code{\link[simscaleR:sim_loopR]{sim_loopR}})

#' @param n_rows Integer. The expected number of rows in the matrix for which we are calculating row similarity. \code{n_rows^2} will be used as the potential number of cells generated by the similarity matrix. 
#' @param resources An optional list with \code{n_cpu} and \code{block_memory}. Default is \code{NA} which calls \code{\link[simscaleR:estimate_local_resources]{estimate_local_resources}}
#' @param row2mem_coeff Float. The coefficient that converts between \code{nrows^2} and object memory size in Mb. See \code{vignette('estimating-local-resources.Rmd', package = 'simscaleR')}.
#' @param row_cap Integer. Maximum number of rows for this machine. See \code{vignette('estimating-local-resources.Rmd', package = 'simscaleR')}. Default is \code{NA} which means no limit is applied 
#' @param verbose Logical. Should informative messages be printed along the way?
#' @param ... Additional parameters passed to \code{\link[simscaleR:estimate_local_resources]{estimate_local_resources}} (when \code{resources = NA})
#' @return A function to calculate similarity with \code{n_cpu} set according to the recommendations. You need to provide \code{X, metric} and \code{thresh} if needed (defaults to 0). For more details see \code{\link[simscaleR:sim_loopR]{sim_loopR}})
#' @examples
#' \dontrun{sim_matrix <- auto_sim_scale(nrow(X))(X, 'cosine', thresh = 0.8)}
#' @export 
sim_auto_scale <- function(n_rows, resources = NA, row2mem_coeff = 7.62940039228619e-06, row_cap = NA, verbose = FALSE, ...) {
  if (is.na(resources)[1]) {resources <- estimate_local_resources(...)}
  
  resources[['max_block_rows']] <- -1
  if (!is.na(resources[['block_memory']])) {
    resources[['max_block_rows']] <- floor(sqrt(resources[['block_memory']] / row2mem_coeff))
  }

  cap_violation <- FALSE
  if (!is.na(row_cap)) {
    cap_violation <- resources[['max_block_rows']] >= row_cap
  }

  if (is.na(resources[['block_memory']]) | cap_violation) {
    if (verbose) {
      if (is.na(resources[['block_memory']])) {
        message('Could not identify OS.')
      } else {
        message('Memory limit is too low for block calculations.')
      }
      message(paste0('Defaulting to simple R loops over ', resources[['n_cpu']], ' cores'))
    }
    
    resources[['row_blocks']] <- -1
    resources[['max_block_rows']] <- -1
    
    f <- function(X, metric, thresh = 0) {
      sim_loopR(X = X, metric = metric, thresh = thresh, n_cpu = resources[['n_cpu']])
    }
  } else {
    resources[['row_blocks']] <- ceiling(n_rows / resources[['max_block_rows']])
    if (verbose) {
      message(paste0('Max rows is ', resources[['max_block_rows']], ' which means we can use ', resources[['row_blocks']], ' blocks over ', resources[['n_cpu']], ' cores'))
    }
    
    f <- function(X, metric, thresh = 0) {
      sim_blocksR(X = X, metric = metric, row_blocks = resources[['row_blocks']], thresh = thresh, n_cpu = resources[['n_cpu']])
    }
  }
  
  attr(f, 'resources') <- resources
  return(f)     
  
}
