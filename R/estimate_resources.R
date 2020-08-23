#' @title Simple resource estimator (BETA)
#' @description Estimate number of cores and available memory per core for the current system. Memory estimation is still in BETA, so if you can do better please show me how! (https://github.com/ytoren/simscaleR/issues)

#' @param do_gc Logical. Should we run garbage collection before estimating? Default is \code{TRUE}.
#' @param headless Logical. Should we use all available CPUs or save one to keep the system interactive? Default is \code{FALSE}.
#' @param logical Logical. Should we count logical CPUs or physical CPUs. Depending on your hardware / OS you might want to turn this on or off (in some cases using virtual cores will reduce performance)
#' @param overhead_factor A number between (0,1). 
#' What fraction of total memory should be reserved for cluster memory overhead? 
#' Since any cluster has some memory overhead, we can't just divide all available memory between cores (we either run out of memory or start an slow & expensive writing to disk). 
#' Default value is 0.05 which means 5% of <total memory size> is assumed as memory overhead per core (so each core takes out an additional 5% of available memory for calculations and we can't use more than \code{1/0.05 - 1 = 19} cores). 
#' If performance slows when you increase number of cores (or you can see intensive I/O activity) consider increasing this parameter. This will break down the calculation to smaller chunks.
#' @param min_block_fraction A number between (0,1). 
#' What is the minimum fraction of memory that still allows block calculations? 
#' If we establish that per-block memory is below this fraction the recommendation will be to default to loop calculations. Default is 0.05. 
#' On headless systems with multiple cores and lots of memory and the recommendation is to loop, you might want to set this value to a lower threshold (or 0 to disable this completely)
#' @param verbose Logical. Should informative messages be printed along the way?
#' @return A list with: 
#' \itemize{
#' \item \code{n_cpu}: Number of detected cores
#' \item \code{block_memory}: which stands for available memory per core, calculated as \code{max_memory} \code{*} \code{( 1.0 / n_cpu - overhead_factor)}. If OS or memory limit are not detected or block size is less than the size defined by \code{min_block_fraction} then this will be \code{NA}.
#' }
#' @importFrom utils memory.limit
#' @importFrom parallel detectCores
#' @export 
estimate_local_resources <- function(do_gc = TRUE, logical = FALSE, headless = FALSE, overhead_factor = 0.05, min_block_fraction = 0.05, verbose = FALSE) {
  warning('Memory estimation is still in Beta. If you can do better please show me how! https://github.com/ytoren/simscaleR/issues')
  
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
  
  n_cpu <- parallel::detectCores(logical = logical)[1] - ifelse(headless, 0, 1)
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
