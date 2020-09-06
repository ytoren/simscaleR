context('Col/Row Merges')

test_that('Errors work', {
  expect_error(merge_by_partition(m = m, partition = list(-1:1), check = TRUE), regexp = 'valid partition')
})

test_that('Bad partition', {
  expect_error(merge_by_partition(m, partition = list(c(2,4), c(5,6), 1), check = TRUE), regexp = 'valid partition')
})

test_that('Full returns', {
  expect_equal(merge_rows_by_partition_(m, list(1:nrow(m)), Matrix::colSums, 1)[1, ], Matrix::colSums(m))
})

test_that('partition row merges', {
  expect_false(any(merge_rows_by_partition_(m, partition, Matrix::colSums, 1) != m_merge_rows))
})

test_that('partition cols & rows', {
  expect_false(any(merge_by_partition(m, partition) != m_merged))
})
