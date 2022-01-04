# path <- system.file("extdata", "20211220_064253.mp3", package = "NocMigR")
# target.path <- stringr::str_remove(path, "20211220_064253.mp3")
# bioacoustics::mp3_to_wav(path, delete = F)
# target <- "20211220_064253.wav"
#
# split_wave(file = target,
#            path = target.path,
#            segment = 30,
#            downsample = 1600)
#
# ## show files
# x <- list.files(file.path(target.path, "split"))
# ## delete folder
# unlink(file.path(target.path, "split"), recursive = TRUE)
# unlink(file.path(target.path, target))
#
#
# test_that("Split works", {
#   expect_equal(x[7], "20211220_064553.WAV")
# })
