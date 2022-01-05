#' Compute entire recording length
#'
#' @inheritParams batch_process
#' @keywords internal
#'
total_duration <- function(path, format) {
  waves <- list.files(path = path, pattern = format, full.names = T)
  waves <- waves[!stringr::str_detect(waves, paste0("_extracted.", format,""))]
  waves <- waves[!stringr::str_detect(waves, "merged.events.wav")]

  duration <- sapply(waves, tuneR::readWave, header = T)

  duration <- sum(sapply(waves, function(i) {
    audio <- tuneR::readWave(i, header = TRUE)
    audio$samples/audio$sample.rate
  }))

  sample_rate <- tuneR::readWave(waves[1], header = TRUE)$sample.rate

  data.frame(sample_rate = paste(sample_rate, "Hz"),
             duration = dplyr::case_when(
               duration < 60 ~ paste(round(duration, 2), "seconds"),
               duration > 60 & duration < 3600 ~ paste(round(duration/60, 2), "minutes"),
               duration > 3600 ~ paste(round(duration/3600, 2), "hours")))
}
#
# path <- "I:/NocMig/AudioMoth/Patthorst 20211211 - 20211217/"
# format <- "WAV"
# list.files(path)
