#' Wrapper to call bioacoustics::threshold_detection
#'
#' @description
#' Queries bioacoustics::\code{\link[bioacoustics]{threshold_detection}} to detect events in a audio file and exports labels to explore the file in audacity
#'
#' @param wav.file Audio file. Currently supported are WAV or MP3 files.
#' @param overwrite logical
#' @param ... Not yet implemented! optional arguments passed on to \code{\link[bioacoustics]{threshold_detection}}.
#' @inheritParams bioacoustics::threshold_detection
#' @return list (see \code{\link[bioacoustics]{threshold_detection}})
#' @export
#'
find_events <- function(wav.file = NULL,
                        overwrite = TRUE,
                        threshold = 10,
                        min_dur = 10,
                        max_dur = 5000,
                        min_TBE = 40,
                        max_TBE = Inf,
                        LPF = 15000,
                        HPF = 80,
                        FFT_size = 1024,
                        start_thr = 20,
                        end_thr = 48,
                        SNR_thr = 4,
                        angle_thr = 125,
                        NWS = 1500,
                        time_scale = 2,
                        ...) {

  ## get optional arguments in any
  ## ---------------------------------------------------------------------------
  #mcall = as.list(match.call())[-1L]
  ## check for optional arguments in the function call, take defaults, if missing
  #arg_list <- list()
 #do.call(FUN, args = c(list(x = x,y = y), mcall, list(...)))

  ## get file extension
  ## ---------------------------------------------------------------------------
  file_format <- tools::file_ext(wav.file)

  ## check if execution is needed
  ## ---------------------------------------------------------------------------
  check <- TRUE

  if (overwrite == FALSE) {
    txt <- paste0(substr(wav.file, 1, nchar(wav.file) - nchar(tools::file_ext(wav.file))),"txt")
    if (file.exists(txt)) {
      cat(txt, "already exists. Skip recording\n")
      check <- FALSE
    }
  }

  if (check == TRUE) {
    TD <- suppressWarnings(suppressMessages(bioacoustics::threshold_detection(
      wave = wav.file,
      threshold = threshold,
      min_dur = min_dur,
      max_dur = max_dur,
      min_TBE = min_TBE,
      max_TBE = max_TBE,
      time_exp = 1,
      LPF = LPF,
      HPF = HPF,
      start_thr = start_thr,
      end_thr = end_thr,
      SNR_thr = SNR_thr,
      angle_thr = angle_thr,
      #duration_thr = duration_thr,
      NWS = NWS,
      settings = TRUE,
      acoustic_feat = TRUE,
      metadata = FALSE,
      spectro_dir = NULL,
      time_scale = 2,
      ticks = TRUE)))

    if (!is.null(TD$data)) {
      ## write audacity marks based on events: times in seconds
      ## -----------------------------------------------------------------------------

      ## ask if file has had date_time header for pretty labels
      head <- stringr::str_remove(TD$data$event_data$filename, paste0(".", file_format))

      if (all(nchar(head) == 15) &
          is.numeric(as.numeric(substr(head, 1, 8))) &
          is.numeric(as.numeric(substr(head, 10, 15)))) {
        origin <- lubridate::make_datetime(
          year = as.numeric(substr(head, 1, 4)),
          month = as.numeric(substr(head, 5, 6)),
          day = as.numeric(substr(head, 7, 8)),
          hour = as.numeric(substr(head, 10, 11)),
          min = as.numeric(substr(head, 12, 13)),
          sec = as.numeric(substr(head, 14, 15)))
      } else {
        origin <- lubridate::make_datetime(2000, 01, 01, 0, 0, 0)
      }

      ##
      t <- TD$data$event_data$starting_time
      t1 <-
        (as.numeric(substr(t, 1,2)) * 60 * 60) +
        (as.numeric(substr(t, 4,5)) * 60) +
        as.numeric(substr(t, 7,12))
      t2 <- t1 + (TD$data$event_data$duration / 1000)
      f1 <- TD$data$event_data$freq_center
      f2 <- TD$data$event_data$freq_max_amp
      label <- origin + t1
      dff <- data.frame(label, t1, t2, f1, f2)
      seewave::write.audacity(
        dff,
        filename = paste0(substr(
          wav.file, 1, nchar(wav.file) - nchar(tools::file_ext(wav.file))),"txt"))
    }
    ## try to free memory
    x <- gc(verbose = FALSE); rm(x)
    return(TD)
  }
}
