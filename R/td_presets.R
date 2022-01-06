#' target-specific templates for use of automatised signal detection
#'
#' @description
#' Bundles a few target-specific settings for using \code{\link[bioacoustics]{threshold_detection}} to detect audio signals (*not embarking on identifications*) based on approximate frequency bandwidth and duration of calls.
#' @param target name of specified target
#' @return data frame with specified parameters values for use with \code{\link{find_events}} or \code{\link[bioacoustics]{threshold_detection}}
#' @examples
#' ## Eagle owl Bubo bubo
#' td_presets("Bubo bubo")
#'
#' ## Tawny owl Strix aluco
#' td_presets("Strix aluco")
#'
#' ## Pygmy owl Glaucidium passerinum
#' td_presets("Glaucidium passerinum")
#'
#' ## NocMig setting
#' td_presets("NocMig")
#'
#'
#' @export
#'
td_presets <- function(target = c("Bubo bubo", "Strix aluco", "Glaucidium passerinum", "NocMig")) {
  target <- match.arg(target)

  if (target == "Bubo bubo") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 300,
      LPF = 800,
      min_dur = 200,
      max_dur = 300
    )
  }

  if (target == "Strix aluco") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 500,
      LPF = 1200,
      min_dur = 200,
      max_dur = 300
    )
  }

  if (target == "Glaucidium passerinum") {
    df <- data.frame(
      HPF = 1000,
      LPF = 5000,
      min_dur = 20,
      max_dur = 300
    )
  }

  if (target == "NocMig") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 2000,
      LPF = 10000,
      min_dur = 10,
      max_dur = 400
    )
  }

  # if (target == "Shot") {
  #   ## duration: median = 260 ms, 90% conf 224 - 289
  #   ## max amp freq: 512
  #
  #   df <- data.frame(
  #     HPF = 0,
  #     LPF = 1000,
  #     min_dur = 30,
  #     max_dur = 600
  #   )
  # }
  return(df)
}
