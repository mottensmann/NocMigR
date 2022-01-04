x <- tempdir()
create_R_script(path = x, open = FALSE)
y <- list.files(x, pattern = "R_code.R")
unlink(x)
test_that("R script is created", {
  expect_equal(length(y), 1)
})
