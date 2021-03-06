context('Automatic resource estimation')

test_that('Beta warninig', {
  expect_warning(estimate_local_resources(), regexp = 'Beta')
})

test_that('correct number of CPUs detected', {
  expect_equal(
    estimate_local_resources(verbose = TRUE)[['n_cpu']], 
    parallel::detectCores(logical = FALSE) - 1
  )
  expect_equal(
    estimate_local_resources(verbose = TRUE, logical = TRUE, headless = TRUE)[['n_cpu']], 
    parallel::detectCores(logical = TRUE)
  )
})

test_that('Missing value retured for small memory / large fraction', {
  expect_identical(
    estimate_local_resources(min_block_fraction = 5)[['block_memory']],
    NA
  )
})