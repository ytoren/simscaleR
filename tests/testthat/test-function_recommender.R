context('Similarity function recommendation based on fixed/dynamic resources')

test_that('Recommend loop when no memory limit is detected', {
  resources <- list('n_cpu' = 4, 'block_memory' = NA)
  f <- sim_auto_scale(n_rows = 10^4, resources = resources, verbose = TRUE)
  expect_equal(
    attr(f, 'resources'),
    list('n_cpu' = 4, 'block_memory' = NA, 'max_block_rows' = -1, 'row_blocks' = -1)
  )
})

test_that('Recommend loop when memory cap is too low', {
  resources <- list('n_cpu' = 4, 'block_memory' = 2048)
  f <- sim_auto_scale(n_rows = 10^4, resources = resources, verbose = TRUE, row_cap = 1)
  expect_equal(
    attr(f, 'resources'),
    list('n_cpu' = 4, 'block_memory' = 2048, 'max_block_rows' = -1, 'row_blocks' = -1)
  )
})

test_that('Recommend a single block when the problem fits in memory', {
  resources <- list('n_cpu' = 4, 'block_memory' = 2048)
  f <- sim_auto_scale(n_rows = 10^4, resources = resources, verbose = TRUE)
  expect_equal(
    attr(f, 'resources'), 
    append(resources, list('max_block_rows' = 16383, 'row_blocks' = 1))
  )
})

test_that('Recommend multiple  blocks when the problem  does not fits in memory', {
  resources <- list('n_cpu' = 4, 'block_memory' = 2048)
  f <- sim_auto_scale(n_rows = 10^6, resources = resources, verbose = TRUE)
  expect_equal(
    attr(f, 'resources'), 
    append(resources, list('max_block_rows' = 16383, 'row_blocks' = 62))
  )  
})


