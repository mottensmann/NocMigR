#' Species-specific templates for use of automatised signal detection
#'
#' @description
#' Bundles a few species-specific settings for using \code{\link[bioacoustics]{threshold_detection}} to detect audio signals (*not embarking on identifications*) based on approximate frequency bandwidth and duration of calls.
#' @param species name of specified target
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
#' ## Gunfire ...
#' td_presets("Shot")
#'
#' @export
#'
td_presets <- function(species = c("Bubo bubo", "Strix aluco", "Glaucidium passerinum", "NocMig", "Shot")) {
  species <- match.arg(species)

  if (species == "Bubo bubo") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 300,
      LPF = 800,
      min_dur = 200,
      max_dur = 300
    )
  }

  if (species == "Strix aluco") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 500,
      LPF = 1200,
      min_dur = 200,
      max_dur = 300
    )
  }

  if (species == "Glaucidium passerinum") {
    df <- data.frame(
      HPF = 1000,
      LPF = 5000,
      min_dur = 20,
      max_dur = 300
    )
  }

  if (species == "NocMig") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 2000,
      LPF = 10000,
      min_dur = 200,
      max_dur = 300
    )
  }

  if (species == "Shot") {
    ## duration: median = 260 ms, 90% conf 224 - 289
    ## max amp freq: 512

    df <- data.frame(
      HPF = 0,
      LPF = 1000,
      min_dur = 30,
      max_dur = 600
    )
  }
  return(df)
}
