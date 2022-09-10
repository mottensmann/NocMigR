#' Query weather summary using api.brightsky.dev
#'
#' @param lat latitude
#' @param lon longitude
#' @param from start of query as date time
#' @param to end of query as date time
#' @import lubridate
#' @examples
#' ## test
#' get_weather()
#' @export
#'
get_weather <- function(lat = 52.032090,
                        lon = 8.516775,
                        from = lubridate::as_datetime("2022-06-30 05:00:00") ,
                        to = lubridate::as_datetime("2022-06-30 10:00:00")) {

  ## compose URL to query api.brightsky.dev
  ## ---------------------------------------------------------------------------
  URL1 <- paste0(
    'https://api.brightsky.dev/weather?',
    'lat=', lat, '&lon=', lon, '&date=',
    format(from, "%Y-%m-%d"))

  URL2 <- paste0(
    'https://api.brightsky.dev/weather?',
    'lat=', lat, '&lon=', lon, '&date=',
    format(to, "%Y-%m-%d"))

  ## get data and convert to data frame
  ## ---------------------------------------------------------------------------
  df1 <- as.data.frame(jsonlite::fromJSON(URL1)$weather[,c(1:15,17)])
  df2 <- as.data.frame(jsonlite::fromJSON(URL2)$weather[,c(1:15,17)])
  # df1 <- dplyr::filter(jsonlite::fromJSON(URL1)$weather, source_id %in% IDs)
  # df2 <- dplyr::filter(jsonlite::fromJSON(URL2)$weather, source_id %in% IDs)

  ## merge data frames
  ## ---------------------------------------------------------------------------
  df <- unique.data.frame(rbind(df1, df2))

  ## translate timestamp to datime
  ## ---------------------------------------------------------------------------
  df$date <- lubridate::make_datetime(
    year = as.numeric(substr(df$timestamp, 1, 4)),
    month = as.numeric(substr(df$timestamp, 6, 7)),
    day = as.numeric(substr(df$timestamp, 9, 10)),
    hour = as.numeric(substr(df$timestamp, 12, 13)),
    min = 0,
    sec = 0,
    tz = "CET")

  ## select time window of interest
  ## ---------------------------------------------------------------------------
  df_selection <- dplyr::filter(df,
                                date >= lubridate::round_date(from, "h"),
                                date <= lubridate::round_date(to, "h"))
  ## prepare output
  ## ---------------------------------------------------------------------------
  getmode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]}

  ##  Convert wind directions
  ## ---------------------------------------------------------------------------
  rose_breaks <- c(0, 360/32, (1/32 + (1:15 / 16)) * 360, 360)
  rose_labs <- c(
    "N", "NNE", "NE", "ENE",
    "E", "ESE", "SE", "SSE",
    "S", "SSW", "SW", "WSW",
    "W", "WNW", "NW", "NNW",
    "N")

  out1 <- data.frame(
    icon = dplyr::case_when(
      getmode(df_selection$icon) == "rain" ~ "regnerisch",
      getmode(df_selection$icon) == "cloudy" ~ "bedeckt",
      getmode(df_selection$icon) == "clear-night" ~ "klar",
      getmode(df_selection$icon) == "clear" ~ "klar",
      getmode(df_selection$icon) == "partly-cloudy-night" ~ "beils bedeckt",
      TRUE ~ getmode(df_selection$icon)),
    cond = dplyr::case_when(
      getmode(df_selection$condition) == "rain" ~ "regnerisch",
      getmode(df_selection$condition) == "dry" ~ "trocken",
      TRUE ~ getmode(df_selection$condition)),
    temp = round(mean(df_selection$temperature, na.rm = T),0),
    wind_dir =
      cut(mean(df_selection$wind_direction, na.rm = T),
          breaks = rose_breaks,
          labels = rose_labs,
          right = FALSE,
          include.lowest = TRUE
      ),
    wind_speed = round(mean(df_selection$wind_speed, na.rm = T),0))


  ## output strings
  ## -----------------------------------------------------------------------------
  part1 <- paste0(out1$icon, "-",
                  out1$cond, ", ",
                  out1$temp, "°C", ", ",
                  out1$wind_dir, ", ",
                  out1$wind_speed, " km/h")
  if (stringr::str_detect(part1, "regnerisch-regnerisch")) {
    stringr::str_replace(part1, "regnerisch-regnerisch", "regnerisch")
  }
  cat(part1,"\n")
}
