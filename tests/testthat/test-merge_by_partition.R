context('Col/Row Merges')

test_that('row merge for a single block', {
  testthat::expect_false(any(merge_rows_(m, partition[[1]]) != m_merge_first))
})

test_that('partition row merges', {
  expect_false(any(merge_rows_by_partition_(m, partition, merge_order) != m_merge_rows))
})

test_that('partition cols & rows', {
  expect_false(any(merge_by_partition(m, partition) != m_merged))
})


