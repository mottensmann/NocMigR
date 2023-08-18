#' RecreateDateTime from file name
#'
#' @param head character
#' @export
#'
RecreateDateTime <- function(head) {
  if (any(nchar(head) < 15)) stop("head is too short")
  return(
    lubridate::make_datetime(
      year = as.numeric(substr(head, 1, 4)),
      month = as.numeric(substr(head, 5, 6)),
      day = as.numeric(substr(head, 7, 8)),
      hour = as.numeric(substr(head, 10, 11)),
      min = as.numeric(substr(head, 12, 13)),
      sec = as.numeric(substr(head, 14, 15))))
}
