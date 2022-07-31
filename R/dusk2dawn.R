#' Compose dusk-to-dawn string based on date and location
#' @param date Date. Default Sys.Date()
#' @param lat latitude
#' @param lon longitude
#' @param tz timezone. Default UTC
#' @export
#'
dusk2dawn <- function(date = Sys.Date(), lat = 52.032, lon = 8.517, tz = "CET") {
  d1 <- suppressWarnings(suncalc::getSunlightTimes(
    date = date, lat = lat, lon = lon, tz = tz, keep = "dusk"))
  d2 <- suppressWarnings(suncalc::getSunlightTimes(
    date = date + 1, lat = lat, lon = lon, tz = tz, keep = "dawn"))
  return(data.frame(
    dusk = d1$dusk,
    dawn = d2$dawn,
    string = paste0(lubridate::day(d1$date), ".", lubridate::month(d1$date), "-",
                    lubridate::day(d2$date), ".", lubridate::month(d2$date), ".", lubridate::year(d2$date), ", ",
                    substr(as.character(d1$dusk), 12, 16), "-", substr(as.character(d2$dawn), 12, 16)
    )
  ))

}




