context('Similarity calculation')

test_that('Error on wrong metric', {
  expect_error(sim_blocksR(matrix(1), metric = 'other'))
  expect_error(sim_loopR(matrix(1), metric = 'other'))
}) 

test_that('Row cosine sparse similarity calulation', {
  X <- t(matrix(c(1,1,1,1,0,1,0,2,2.2,2,2.2,0.5), ncol = 3))
  # install.packages('lsa')
  # sim_expected <- lsa::cosine(t(X))
  # install.packages('proxy')
  # sim_expected <- proxy::simil(t(X), method="cosine")
  
  sim_expected <- matrix(c(1.0, 0.6708204, 0.9243651, 0.6708204, 1.0, 0.3594684, 0.9243651, 0.3594684, 1), ncol = 3)
  sim_expected <- methods::as(Matrix::Matrix(sim_expected, sparse = TRUE), "symmetricMatrix")
  expect_equal(sim_blocksR(X, metric = 'cosine'), sim_expected, tolerance = 1e-07)
  expect_equal(sim_blocksR(X, metric = 'cosine', row_blocks = 2), sim_expected, tolerance = 1e-07)
  expect_equal(sim_blocksR(X, metric = 'cosine', row_blocks = 3), sim_expected, tolerance = 1e-07)
  expect_equal(sim_blocksR(X, metric = 'cosine', row_blocks = 3, n_cpu = 2), sim_expected, tolerance = 1e-07)
  expect_equal(sim_loopR(X, metric = 'cosine', n_cpu = 1), sim_expected, tolerance = 1e-07)
  expect_equal(sim_loopR(X, metric = 'cosine', n_cpu = 2), sim_expected, tolerance = 1e-07)
  
  sim_expected[sim_expected < 0.9] <- 0
  sim_expected <- methods::as(sim_expected, "symmetricMatrix")
  expect_equal(sim_blocksR(X, metric = 'cosine', thresh = 0.9, row_blocks = 2), sim_expected, tolerance = 1e-07)
  expect_equal(sim_blocksR(X, metric = 'cosine', thresh = 0.9, row_blocks = 3), sim_expected, tolerance = 1e-07)
  expect_equal(sim_blocksR(X, metric = 'cosine', thresh = 0.9), sim_expected, tolerance = 1e-07)
  expect_equal(sim_loopR(X, metric = 'cosine', thresh = 0.9, n_cpu = 1), sim_expected, tolerance = 1e-07)
  expect_equal(sim_loopR(X, metric = 'cosine', thresh = 0.9, n_cpu = 2), sim_expected, tolerance = 1e-07)
  
  # Xn <- matrix(rep(X, 10000), ncol=3)
  # Xn_size <- as.numeric(gsub('[^0-9.,]', '', format(object.size(Xn), units = "Mb", standard = "legacy")))
  # expect_gte(mem.maxVSize(), Xn_size)
})

test_that('Row Hamming sparse similarity calculation', {
  X <- t(matrix(c(1,1,1,1,0,1,0,1,0,0,0,1), ncol = 3))
  # install.packages('e1071')
  # sim_expected <- 1 - e1071::hamming.distance(X) / ncol(X)
  sim_expected <- matrix(c(0.0, 0.5, 0.25, 0.5, 0.0, 0.75, 0.25, 0.75, 0.0), ncol = 3)
  sim_expected <- methods::as(Matrix::Matrix(sim_expected, sparse = TRUE), "symmetricMatrix")
  sim_expected <- Matrix::drop0(sim_expected)
  
  expect_equal(sim_blocksR(X, metric = 'hamming', include_diag = FALSE), sim_expected)
  expect_equal(sim_blocksR(X, metric = 'hamming', row_blocks = 3, include_diag = FALSE), sim_expected)
  expect_equal(sim_loopR(X, metric = 'hamming', include_diag = FALSE), sim_expected)
  expect_equal(sim_loopR(X, metric = 'hamming', n_cpu = 2, include_diag = FALSE), sim_expected)

  sim_expected[sim_expected < 0.75] <- 0
  sim_expected <- Matrix::drop0(sim_expected)
  sim_expected <- methods::as(sim_expected, "symmetricMatrix")
  expect_equal(sim_blocksR(X, metric = 'hamming', thresh = 0.75, include_diag = FALSE), sim_expected)
  expect_equal(sim_blocksR(X, metric = 'hamming', thresh = 0.75, row_blocks = 3, include_diag = FALSE), sim_expected)
  expect_equal(sim_loopR(X, metric = 'hamming', thresh = 0.75, include_diag = FALSE), sim_expected)
  expect_equal(sim_loopR(X, metric = 'hamming', thresh = 0.75, , n_cpu = 2, include_diag = FALSE), sim_expected)
  
})
