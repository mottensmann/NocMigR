path <- system.file("extdata", "20211220_064253.mp3", package = "NocMigR")

x <- get_DateTime(target.path = stringr::str_remove(path, "20211220_064253.mp3"),
                  target = "20211220_064253.mp3")

test_that("get_DateTime works", {
  expect_equal(as.character(x$start), "2021-12-20 06:42:53")
  expect_equal(as.character(x$end), "2021-12-20 06:47:53")

})
