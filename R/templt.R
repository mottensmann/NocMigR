#' Make template
#'
#' @param wave sound file
#' @param channel channel. Default 1
#' @param start start in seconds
#' @param end stop in seconds
#' @source https://marce10.github.io/2020/06/15/Automatic_signal_detection-_a_case_study.html
#'
#'
templt <- function(wave = NULL, channel = 1, start = NULL, end = NULL) {
  templt <- data.frame(
    sound.files = wave,
    selec = 2,
    channel = channel,
    start = start,
    end = end,
    stringsAsFactors = FALSE)
  return(templt)
}


