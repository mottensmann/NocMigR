#' Metadata
#'
#' @description
#' Add metadata to recording summary. Including
#' (1) Recording location and parameters
#' (2) BirdNET analysis settings
#'
#' @param Lat latitude
#' @param Lon longitude
#' @param Location location name
#' @param Device recording device
#' @param Micro external microphone
#' @param Min_conf min_conf
#' @param Overlap overlap
#' @param Sensitivity sensitivity
#' @param Slist slist
#'
#' @export
#'
AudioMeta <- function(
    Location = NULL,
    Lat = NULL,
    Lon = NULL,
    Device = c("AudioMoth", "Olympus LS-3", "Olympus LS-11"),
    Micro = c("none", "Primo EM-172", "Dodotronics HiSound"),
    Min_conf = 0.7,
    Overlap = 0.25,
    Sensitivity = 1.25,
    Slist = "E:/BirdNET/species_list.txt") {

  Device <- match.arg(Device)
  Micro <- match.arg(Micro)

  data.frame(Location, Lat, Lon, From = NA, To = NA, Duration = NA, Device, Micro, Min_conf, Overlap, Sensitivity, Slist)

}



