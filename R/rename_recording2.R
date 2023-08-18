#' Rename audio file captured using Olympus LS-3 with date_time string
#'
#' @description
#' Renames individual files based on mtime (which gives endtime of recording using Olypus LS-3).. See \code{\link{rename_recording}} for handling continuous recordings and more details.

#' @inheritParams rename_recording
#' @param file a single recording file
#' @return data frame summarising the modofication to the file name
#' @export
#'
rename_OlyLs3 <- function(file = NULL,
                          simulate = FALSE) {
  ##  Check file format
  ##  --------------------------------------------------------------------------
  format <- substr(file, nchar(file) - 2 , nchar(file))
  if (!format %in% c("WAV", "wav", "mp3", "MP3")) {
    stop("File format '", format, "' is not supported. Change to WAV or MP3")
  }

  ## Get recording length in seconds
  ##  --------------------------------------------------------------------------
  if (format == "WAV" | format == "wav") {
    y <- tuneR::readWave(file, header = TRUE)
    seconds <- y[["samples"]]/y[["sample.rate"]]
  } else if (format == "mp3" | format == "MP3") {
    y <- tuneR::readMP3(file)
    seconds <- as.numeric(summary(y)[[1]])/y@samp.rate
  }

  ## obtain meta data, including mtime and ctime etc.
  ##  --------------------------------------------------------------------------
  meta <- file.info(file)

  ## get time created of  recording
  df <- data.frame(old.name = file,
                   seconds = seconds,
                   time = meta$mtime - seconds)

## create file names based on ctime of recordings
df[["new.name"]] <- paste0(substr(df[["time"]], 1, 4),
                           substr(df[["time"]], 6, 7),
                           substr(df[["time"]], 9,10),
                           "_",
                           substr(df[["time"]], 12, 13),
                           substr(df[["time"]], 15, 16),
                           substr(df[["time"]], 18, 19),
                           ".", format)

x <- stringr::str_split(df$old.name, "/")[[1]]
x <- x[length(x)]
df[["new.name"]] <- stringr::str_replace(df[["old.name"]], x, df[["new.name"]])


if (simulate == TRUE) {
  #cat("Only show how file.rename will change files!")
} else if (simulate == FALSE) {
  ## check:
  file.rename(from = df$old.name,
              to = df$new.name)
}

return(df)

}
