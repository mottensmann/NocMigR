df <- AudioMoth_days()
test_that("Audiomoth days are correct", {
  expect_equal(df$memory_days, 37)
})

