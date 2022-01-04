## Some internal functions
## #############################################################################

#' convert start_time to seconds
#' @param t character vector
#' @keywords internal
#'
starting_time2seconds <- function(t) {
  (as.numeric(substr(t, 1,2)) * 60 * 60) +
    (as.numeric(substr(t, 4,5)) * 60) +
    as.numeric(substr(t, 7,12))
}

#' check if file name is composed of date and time string
#' @param files character vector
#'
has_date_time_name <- function(files) {
  ## check for expected nchar --> expect 15 without file extension
  file_extensions <- tools::file_ext(files)
  files_temp <- stringr::str_remove(files, paste0(".", file_extensions))
  l <- sapply(files_temp, nchar)
  files <- files[l == 15]

  ## check content date
  checks_date <- sapply(files, function(x) is.numeric(as.numeric(substr(x, 1, 8))))
  files <- files[checks_date == TRUE]
  checks_time <- sapply(files, function(x) is.numeric(as.numeric(substr(x, 10, 15))))
  files <- files[checks_time == TRUE]
  return(files)
}

#' condense output of find_events
#' @param threshold_detection
#' object of class threshold_detection (see \code{\link[bioacoustics]{threshold_detection}})
#'
inspect_events <- function(threshold_detection = NULL) {
  threshold_detection[["data"]][["event_data"]][,c("filename", "starting_time", "duration", "freq_max_amp", "snr")]
}

#' Update events: Create threshold_detection from audacity labels
#'
#' @param txt audacity labels
#'
update_events <- function(txt = NULL) {
  df <- seewave::read.audacity(file = txt, format = "base")

  ## transform times to HH:MM:SS.SSS
  ## ask if file has had date_time header
  head <- stringr::str_remove(df$file, ".txt")

  if (all(nchar(head) == 15) &
      is.numeric(as.numeric(substr(head, 1, 8))) &
      is.numeric(as.numeric(substr(head, 10, 15)))) {
    origin <- lubridate::make_datetime(
      year = substr(head, 1, 4),
      month = substr(head, 5, 6),
      day = substr(head, 7, 8),
      hour = substr(head, 10, 11),
      min =  substr(head, 12, 13),
      sec = substr(head, 14, 15))
  } else {
    origin <- lubridate::make_datetime(2000, 01, 01, 0, 0, 0)
  }

  data.frame(filename = df$file,
             starting_time = origin + df$t1,
             duration = df$t2 - df$t1,
             freq_max_amp = df$f2,
             snr = NA,
             event = df$t1)
}

#' Check for and handle overlapping selections
#' @description Detects overlapping selections and merges them using \code{\link[warbleR]{overlapping_sels}}
#' @param df data frame with event data created by \code{\link[bioacoustics]{threshold_detection}}
#'
non_overlapping <- function(df) {
  ## mimic selec_table of warbler package
  df.warbler <- data.frame(sound.files = df$filename,
                           channel = 1,
                           selec = 1:nrow(df),
                           start = df$from,
                           end = df$to,
                           bottom.freq = NA,
                           top.freq = NA)
  out <- warbleR::overlapping_sels(df.warbler)
  ## any overlap?
  if (any(!is.na(out$ovlp.sels))) {
    df.new <- do.call("rbind", lapply(stats::na.omit(unique(out$ovlp.sels)), function(x) {
      ## (binding global variables to please R CMD check)
      ovlp.sels <- NULL
      subset <- dplyr::filter(out, ovlp.sels == x)
      subset$start <- min(subset$start)
      subset$end <- max(subset$end)
      subset[1,]
    }))
    ## (binding global variables to please R CMD check)
    ovlp.sels <- NULL
    df.new <- rbind(df.new, dplyr::filter(out, is.na(ovlp.sels)))
    out <- df.new[order(df.new$start),]
  }
  ## format as input again
  df.new <- data.frame(filename = out$sound.files,
                       from = out$start,
                       to = out$end)
  df.new <- dplyr::left_join(df.new, df[,c("starting_time", "event", "from")], by = "from")
}

