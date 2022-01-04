#' Create a dynamic sonagram as video clip using dynaSpec
#' @description Implements dynamic sonagrams as .mp4 files as explained in much detail here (here)[https://marce10.github.io/dynaSpec/] Only works if (FFMPEG)[https://ffmpeg.org/download.html] is installed (see (wikihow tutorial)[https://www.wikihow.com/Install-FFmpeg-on-Windows] to get help)
#' @param wave path to a .mp3 or .wav audio file.
#' @param res res
#' @param t.range x-axis width in seconds
#' @param ymin min frequency
#' @param ymax max frequency
#' @param out output file name
#' @param scalecexlab scalecexlab
#' @param scalefontlab scalefontlab
#' @param cexlab cexlab
#' @param cexaxis cexaxis
#' @param tlab name of time (x) axis
#' @param flab name of frequency (y) axis
#' @inheritParams dynaSpec::scrolling_spectro
#' @references https://marce10.github.io/dynaSpec/
#'
sona.vid <- function(wave = NULL,
                     res = 120,
                     wl =  1024,
                     ymin = 0,
                     ymax = 9,
                     loop = 1,
                     scalecexlab = 0.5,
                     scalefontlab = 0.5,
                     cexlab = .5,
                     cexaxis = .5,
                     t.range = 10,
                     tlab = "",
                     flab = "kHz",
                     colbg = c("black", "white"),
                     fix.time = F,
                     out = "default") {

  colbg <- match.arg(colbg)
  if (is.null(wave)) stop("Specify audio file in .wav or .mp3 format")
  ## check type
  if (stringr::str_detect(wave, ".wav")) {
    sound <- tuneR::readWave(filename = wave)
  } else if (stringr::str_detect(wave, ".mp3")) {
    sound <- tuneR::readMP3(filename = wave)
  } else {
    stop("Wrong file extension. Requires .mp3 or .wav")
  }

  ## make dynamic spectrum
  dynaSpec::scrolling_spectro(
    wave = sound,
    wl = wl,
    t.display = t.range,
    pal = viridis::viridis,
    grid = FALSE,
    flim = c(ymin, ymax),
    width = 1000,
    height = 500,
    res = res,
    fix.time = fix.time,
    colbg = colbg,
    parallel = parallel::detectCores(),
    loop = loop,
    tlab = tlab,
    flab = flab,
    scalecexlab = scalecexlab,
    scalefontlab = scalefontlab,
    cexlab = cexlab,
    cexaxis = cexaxis,
    file.name = paste0(out, ".mp4"))
}
