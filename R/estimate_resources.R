#' @title Simple resource estimator
#' @description Estimate number of cores and available memory per core for the current system

#' @param do_gc Logical. Should we run garbage collection before estimating? Default is \code{TRUE}.
#' @param headless Logical. Should we use all available CPUs or save one to keep the system interactive? Default is \code{FALSE}.
#' @param overhead_factor A number between (0,1). 
#' What fraction of total memory should be reserved for cluster memory overhead? 
#' Since any cluster has some memory overhead, we can't just divide all available memory between cores (we either run out of memory or start an slow & expensive writing to disk). 
#' Default value is 0.05 which means 5% of <total memory size> is assumed as memory overhead per core (so each core takes out an additional 5% of available memory for calculations and we can't use more than \code{1/0.05 - 1 = 19} cores). 
#' If performance slows when you increase number of cores (or you can see intensive I/O activity) consider increasing this parameter. This will break down the calculation to smaller chunks.
#' @param min_block_factor A number between (0,1). 
#' What is the minimum fraction of memory that still allows block calculations? 
#' If we establish that per-block memory is below this fraction the recommendation will be to default to loop calculations. Default is 0.05. 
#' On headless systems with multiple cores and lots of memory and the recommendation is to loop, you might want to set this value to a lower threshold (or 0 to disable this completely)
#' @param verbose Logical. Should informative messages be printed along the way?
#' @return A list with \code{n_cpu=} number of detected cores, \code{block_memory=} available memory per core as calculated by the function (\code{NA} if OS or memory limit are not detected).
#' 
#' @importFrom utils memory.limit
#' @importFrom parallel detectCores
#' @export 
estimate_local_resources <- function(do_gc = TRUE, headless = FALSE, overhead_factor = 0.05, min_block_fraction = 0.05, verbose = FALSE) {
  os <- tolower(Sys.info()['sysname'])
  if (verbose) {message(paste0('System reports as \"', os, '\"'))}
  
  if (do_gc) {gc(full = TRUE, verbose = FALSE)}
  
  max_memory <- NA
  if (os == 'windows') {
    max_memory <- memory.limit()
  } else if (os == 'darwin' | .Platform$OS.type == 'unix') {
    max_memory <- mem.maxVSize()
  } 
  if (is.infinite(max_memory)) {max_memory <- NA}
  
  n_cpu <- parallel::detectCores(logical = FALSE)[1] - ifelse(headless, 1, 0)
  if (n_cpu <= 0) {
    n_cpu <- 1
    if (verbose) {message('Found only 1 core in a n interactive system, or failed to detect cores correctly. Defaulting to 1 core')}
  } else {
    if (verbose) {message(paste0('Detected ', n_cpu, ' usable cores'))}
  }

  block_memory <- max_memory * ( 1.0 / n_cpu - overhead_factor)
  if (block_memory < max_memory * min_block_fraction) {block_memory <- NA}

  return(list('n_cpu' = n_cpu, 'block_memory' = block_memory))
}
