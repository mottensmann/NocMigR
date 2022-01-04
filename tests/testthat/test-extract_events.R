path <- system.file("extdata", "20211220_064253.mp3", package = "NocMigR")
x <- find_events(wav.file = path,
                 threshold = 2,
                 min_dur = 20,
                 max_dur = 300,
                 LPF = 5000,
                 HPF = 1000)

df <- extract_events(
  threshold_detection = x,
  path = stringr::str_remove(path, "20211220_064253.mp3"),
  format = "mp3",
  LPF = 4000,
  HPF = 1000,
  buffer = 1)

unlink(list.files(stringr::str_remove(path, "20211220_064253.mp3")
, pattern = "WAV", full.names = T))
unlink(list.files(stringr::str_remove(path, "20211220_064253.mp3")
, pattern = "txt", full.names = T))

test_that("extract events works", {
  expect_equal(round(sum(df$event), 3), 216.06)
})
