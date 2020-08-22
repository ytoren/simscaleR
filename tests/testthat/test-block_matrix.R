context('Block Matrix')

test_that('Block constructions', {
  expected = Matrix::sparseMatrix(
    i = c(1,2,2,3,4,4,4,5,5,6),
    j = c(1,2,3,3,4,5,6,5,6,6),
    x = 1,
    symmetric = TRUE,
    giveCsparse = TRUE
  )
  
  expect_equal(sparse_block_matrix(c(1,2,3)), expected)
  
  expect_equal(sparse_block_matrix(c(1,2,3), values = 10), expected * 10)
  
  expect_error(sparse_block_matrix(c(1,2,3), values = c(1,2)), regexp = 'differ')
  
})
  