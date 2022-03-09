#' Rename recording using a string of the form YYYYMMDD_HHMMSS
#'
#' @description
#' For easier manipulation of data obtained using long-term recordings, vendor-specific file names and exchanged by a string of the form `YYYYMMDD_HHMMSS`, as used by the `AudioMoth` (https://www.openacousticdevices.info/). Date and time information is queried using \code{\link[base]{file.info}}. **Note**, popular recorders (e.g., `Olympus LS` or `Sony PCM` series) differ by having the habit of either saving each file one-by-one (i.e., each file has a unique `ctime`) or in batch mode (i.e, all are saved at once).
#'
#' @param path folder containing files (wav or mp3)
#' @param recorder Type of recorder
#' @param time Either ctime or mtime
#' @param simulate logical. If TRUE only shows data frame of names without touching files
#' @inheritParams batch_process
#' @return data frame listing the modified file names
#' @export
#'
rename_recording <- function(path = NULL,
                             recorder = c("Olympus LS-3", "Sony PCM-D100"),
                             format = c("WAV", "wav", "mp3", "MP3"),
                             time = c("ctime", "mtime"),
                             simulate = FALSE) {
  ## check function call
  recorder <- match.arg(recorder)
  format <- match.arg(format)
  time <- match.arg(time)

  ## list recordings
  records <- list.files(path = path, pattern = format)
  if (length(records) == 0) stop("No ", format, " files found at", path)
  ## get duration of recordings
  seconds <- sapply(file.path(path, records), function(x) {

    ## check format
    if (format == "WAV" | format == "wav") {
      y <- tuneR::readWave(x, header = TRUE)
      y[["samples"]]/y[["sample.rate"]]
    } else if (format == "mp3" | format == "MP3") {
      y <- tuneR::readMP3(x)
      as.numeric(summary(y)[[1]])/y@samp.rate
    }


  })

  if (recorder == "Olympus LS-3") {

    ## create data frame of date_times
    ## if ctime: label in ascending order of file names
    if (time == "ctime") {
      ## get time created of first recording
      meta <- file.info(file.path(path, records[1]))
      df <- data.frame(old.name = records,
                       seconds = seconds,
                       time = meta$ctime)
      if (nrow(df) > 1) {
        ## compute times of recordings 2:N
        for (i in 2:nrow(df)) {
          df[i, "time"] <- df[i - 1, "time"] + df[i - 1, "seconds"]
        }
      }

      ## if mtime: label in descending order of file names
    } else if (time == "mtime") {
      ## get time created of last recording
      meta <- file.info(file.path(path, records[length(records)]))
      df <- data.frame(old.name = records,
                       seconds = seconds,
                       time = meta$mtime)
      # Wed Mar 09 17:15:12 2022 ------------------------------
      # repair a bug, check if correct now!
      df$time <- df$time[nrow(df)] - df$seconds[nrow(df)]

      if (nrow(df) > 1) {
        ## compute times of recordings N-1 : 1
        for (i in (nrow(df) - 1):1) {
          df[i, "time"] <- df[i + 1, "time"] - df[i, "seconds"]
        }
      }

    }


  } else if (recorder == "Sony PCM-D100" ) {
    ## get time created of first recording
    meta <- lapply(file.path(path, records), file.info)
    meta <- do.call("rbind", meta)

    df <- data.frame(old.name = records,
                     seconds = seconds,
                     time = meta$ctime)
  }

  ## create file names based on ctime of recordings
  df[["new.name"]] <- paste0(substr(df[["time"]], 1, 4),
                             substr(df[["time"]], 6, 7),
                             substr(df[["time"]], 9,10),
                             "_",
                             substr(df[["time"]], 12, 13),
                             substr(df[["time"]], 15, 16),
                             substr(df[["time"]], 18, 19),
                             ".", format)

  if (simulate == TRUE) {
    #cat("Only show how file.rename will change files!")
  } else if (simulate == FALSE) {
    ## check:
    if (any(duplicated(df$new.name))) stop("Conflict: Identical file names created. Stop.")

    file.rename(from = file.path(path, records),
                to = file.path(path, df[["new.name"]]))
    utils::write.table(df, file = file.path(path, "rename.audiomoth.info"))
  }

  return(df)

}
