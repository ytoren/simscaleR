context('Col/Row Merges')

test_that('Errors work', {
  expect_error(merge_rows_(m, -1:1), regexp = 'match')
})

test_that('Full returns', {
  expect_equal(merge_rows_(m, 1:nrow(m)), Matrix::colSums(m))
})

test_that('row merge for a single block', {
  expect_false(any(merge_rows_(m, partition[[1]]) != m_merge_first))
})

test_that('partition row merges', {
  expect_false(any(merge_rows_by_partition_(m, partition, merge_order) != m_merge_rows))
})

test_that('Bad partition', {
  expect_error(merge_by_partition(m, partition = list(c(2,4), c(5,6), 1)), regexp = 'Missing')
})

test_that('partition cols & rows', {
  expect_false(any(merge_by_partition(m, partition) != m_merged))
})


