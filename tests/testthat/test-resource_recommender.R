context('Resource recommendations')

test_that('Function recommendation with fixed resources', {
  resources <- list('n_cpu' = 4, 'block_memory' = 2048)

  f <- sim_auto_scale(n_rows = 10^4, resources = resources, verbose = TRUE)
  testthat::expect_identical(
    attr(f, 'resources'), 
    append(resources, list('max_cells' = 401890759, 'row_blocks' = 1))
  )
  
  f <- sim_auto_scale(n_rows = 10^6, resources = resources, verbose = TRUE)
  testthat::expect_identical(
    attr(f, 'resources'), 
    append(resources, list('max_cells' = 401890759, 'row_blocks' = 2489))
  )  
})
