path <- system.file("extdata", "20211220_064253.mp3", package = "NocMigR")
path <- stringr::str_remove(path, "20211220_064253.mp3")

df <-rename_recording(
  path = path,
  format = "mp3",
  simulate = TRUE)

test_that("multiplication works", {
  expect_equal(round(sum(df$seconds),2), 300.07)
})
