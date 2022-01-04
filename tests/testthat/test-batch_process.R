path <- stringr::str_remove(system.file(
  "extdata", "20211220_064253.mp3", package = "NocMigR"),
  "20211220_064253.mp3")

check <- batch_process(
  path = path,
  format = "mp3",
  segment = NULL,
  downsample = NULL,
  SNR = 8,
  target = td_presets("Glaucidium passerinum"),
  rename = FALSE)

check2 <- batch_process(
  path = path,
  format = "mp3",
  segment = NULL,
  downsample = NULL,
  SNR = 8,
  steps = "find_events",
  target = td_presets("Glaucidium passerinum"),
  rename = FALSE)

check3 <- batch_process(
  path = path,
  format = "mp3",
  segment = NULL,
  downsample = NULL,
  SNR = 8,
  steps = "split_wave",
  target = td_presets("Glaucidium passerinum"),
  rename = FALSE)


unlink(list.files(path, pattern = "WAV", full.names = T))
unlink(list.files(path, pattern = "txt", full.names = T))

test_that("Test batch on a single mp3 file", {
  expect_equal(round(sum(check$event), 2), 200.01)
})
