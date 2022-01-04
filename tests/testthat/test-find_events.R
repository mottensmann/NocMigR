path <- system.file("extdata", "20211220_064253.mp3", package = "NocMigR")

x <- find_events(wav.file = path,
                 threshold = 2,
                 min_dur = 20,
                 max_dur = 300,
                 LPF = 5000,
                 HPF = 1000)
unlink(stringr::str_replace(path, "mp3", "txt"))

test_that("find_events works", {
  expect_equal(length(x), 2)
  expect_equal(nrow(x$data$event_data), 8)
})
