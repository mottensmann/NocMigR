#' Get date and time from file name of the form `YYYYMMDD_HHMMSS`
#'
#' @param target original recording
#' @param target.path original recording path
#' @return data frame
#' @export
#'
get_DateTime <- function(target, target.path) {

  ext <- tools::file_ext(target)

  if (ext %in% c("WAV", "wav")) {
    info <- tuneR::readWave(file.path(target.path, target), header = TRUE)
    sec <- info$samples/info$sample.rate
  } else if (ext %in% c("MP3", "mp3")) {
    info <- tuneR::readMP3(file.path(target.path, target))
    sec <- as.numeric(summary(info)[[1]])/info@samp.rate
  }
  start <- lubridate::make_datetime(
    year = substr(target, 1, 4),
    month = substr(target, 5, 6),
    day = substr(target, 7, 8),
    hour = substr(target, 10, 11),
    min =  substr(target, 12, 13),
    sec = substr(target, 14, 15))

  return(data.frame(file = target,
             path = target.path,
             txt = paste0(substr(target, 1, 15),".txt"),
             start = start,
             end = start + sec,
             sec = sec))
}
