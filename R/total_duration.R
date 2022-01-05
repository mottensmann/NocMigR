#' Compute entire recording length
#'
#' @inheritParams batch_process
#' @keywords internal
#'
total_duration <- function(path, format) {
  waves <- list.files(path = path, pattern = format, full.names = T)
  waves <- waves[!stringr::str_detect(waves, "extracted.wav")]
  duration <- sapply(waves, tuneR::readWave, header = T)

  duration <- sum(sapply(waves, function(i) {
    audio <- tuneR::readWave(i, header = TRUE)
    audio$samples/audio$sample.rate
  }))

  sample_rate <- tuneR::readWave(waves[1], header = TRUE)$sample.rate

data.frame(
  sample_rate = sample_rate,
  secounds = duration,
  hours = duration/3600)

}
#
# path <- "I:/NocMig/AudioMoth/Patthorst 20211211 - 20211217/"
# format <- "WAV"
# list.files(path)
