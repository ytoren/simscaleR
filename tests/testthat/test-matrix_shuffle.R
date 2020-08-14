context('Matrix shuffle')


test_that('Row shuffle matrix', {
  re_order <- c(1, 6, 3, 4, 5, 2)

  shuffle_matrix_2_6 <- matrix(
    c(1,0,0,0,0,0,
      0,0,0,0,0,1,
      0,0,1,0,0,0,
      0,0,0,1,0,0,
      0,0,0,0,1,0,
      0,1,0,0,0,0
    ),
    nrow = 6,
    byrow = TRUE
  )

  expect_false(any(row_shuffle_matrix_(re_order) != shuffle_matrix_2_6))
})



test_that('Row shuffle matrix', {
  m <- matrix(
    c(1.0, 0.9, 0.0, 0.2, 0.0, 0.1,
      0.9, 1.0, 0.6, 0.0, 0.0, 0.0,
      0.0, 0.6, 1.0, 0.0, 0.5, 0.0,
      0.2, 0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.5, 0.0, 1.0, 0.8,
      0.1, 0.0, 0.0, 0.0, 0.8, 1.0),
    nrow = 6,
    byrow = TRUE
  )
  
  re_order <- c(1, 6, 3, 4, 5, 2)
  
  m_shuffle_2_6 <- matrix(
    c(1.0, 0.1, 0.0, 0.2, 0.0, 0.9,
      0.1, 1.0, 0.0, 0.0, 0.8, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.5, 0.6,
      0.2, 0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.8, 0.5, 0.0, 1.0, 0.0,
      0.9, 0.0, 0.6, 0.0, 0.0, 1.0),
    nrow = 6,
    byrow = TRUE
  )
  
  expect_false(any(sim_matrix_shuffle(m, re_order) != m_shuffle_2_6))
})

