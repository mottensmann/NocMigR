#' Main function to run all steps on a folder of sound files
#'
#' @description
#' Main function of the package `NocMigR` that allows to analyse a suite of long-term recordings from scratch by executing five distinct steps (see `details` section.).*Under the hood*, this function is calling algorithms of the fabulous R packages \pkg{tuneR}, \pkg{warbleR}, \pkg{seewave} and \pkg{bioacoustics}.
#' **Important note**:
#' Especially for large sets of recordings (e.g., `AudioMoth` deployed for a weak, ~ 60 GB data) R can easily run into memory issues. This can surely be tackled by coding functions more efficiently. For now, the best way to handle this issue is to resume the script after it broke (see output in the console and check \code{steps} argument).
#' @details
#' By default, runs all steps (currently five, see \code{steps}) of the analysis workflow consecutively. Recordings of a project (i.e., usually continuous signal or time-expanded if otherwise) need to be saved to a single directory, specified as \code{path} argument:
#'
#' \bold{1.) If steps = 1 or 'rename_audio':}
#' Attempts to rename audio files to YYYYMMDD_HHMMSS format, where the date and time at the onset of the recording are coded in the file name. This steps ensures that all downstream algorithms can compute the correct dates and times of events. If files are already formatted correctly (e.g, capture by AudioMoth) this steps can be skipped (default behaviour) by either setting \code{rename = FALSE} and/or excluding '1' from \code{steps}. Internally, calls the function \code{\link{rename_recording}}.
#'
#' \bold{2.) If steps = 2 or 'split_wave':}
#' Attempts to split large audio files in chunks controlled by \code{segment} to reduce the file size prior to calling event detection algorithms. Within the parent folder (\code{path}) a sub folder "split" is created to dump the files. Each file is named with the correct `YYYYMMDD_HHMMSS` string. If files are already formatted correctly (e.g, capture by `AudioMoth`) this steps can be skipped by removing '2" from the vector \code{steps}. Internally, calls the function \code{\link{split_wave}}.
#'
#' \bold{3.) If steps = 3 or 'find_events':}
#' Queries bioacoustics::\code{\link[bioacoustics]{threshold_detection}} to detect events based on signal-to-noise ratios (\code{SNR}). When events are found, a `txt`file based on the file name of the recording is created with labels for reviewing in `Audacity`. Internally, calls the function \code{\link{find_events}}.
#'
#' \bold{4.) If steps = 4 or ''join_audacity':}
#' If event detection is based on segmented files (i.e., sub folder 'split' exists), loops through text file containing Audacity labels and merges with respect to the original file (as matched by date and time overlap).
#'
#' \bold{5.) If steps = 5 or 'extract_events':}
#' Extract events from (full-length recordings) and writes them to a a new wave file with extension 'extracted.wav'. Additionally, creates file with Audacity labels (extension extracted.txt).
#'
#' \bold{6.) If steps = 6 or 'merge_events':}
#' Concatenates files holding extracted events along with their labels to merge the output of a project.
#'
#' @param path Path to a set of recordings (all same format and continuous time span). Important note: File are expected to be named using a YYYYMMDD_HHMMSS string or set \code{reaname = TRUE} to allow renaming. Files including the extensions "_extracted.WAV" or "merged_events.WAV" are reserved to write output files and ignored as inputs.
#'
#' @param format Format of sound files (default and suggested is to use WAV).
#'
#' @param steps Numeric or character vector, by default steps 1:5 are executed. (1 = \code{\link{rename_recording}}, 2 = \code{\link{split_wave}}, 3 = \code{\link{find_events}}, 4 = \code{\link{join_audacity}} & 5 = \code{\link{extract_events}}).
#' @param rename Logical, allows to rename recordings (default FALSE).
#' @param segment Null, or numeric value giving segment size for \code{\link{split_wave}} in seconds. (default NULL)
#' @param mono Logical. By default, \code{\link{split_wave}} coerces stereo files to mono prior to event detection (default TRUE). If kept as stereo file the left channel will used in \code{\link{find_events}}.
#' @param downsample Null or re-sampling factor used in \code{\link{split_wave}} (default NULL).
#' @param SNR Numeric value (dB)  specifying signal to noise ratio for \code{\link{find_events}} (default 8).
#' @param max.events Numeric, giving the maximum number of events before a file is skipped (default 999). Usually very high detection rates indicate an issue with noise (e.g., wind or rain).
#' @param target data frame specifying parameter values used by \code{\link[bioacoustics]{threshold_detection}} to detect events. Values are parsed on as they are. Default is a call to \code{\link{td_presets}}.
#' @param recorder Currently three templates to ensure correct handling of times. \bold{Only relevant if \code{rename = TRUE}!}.
#' @param time Controls, if ctime or mtime is used to compute date_time objects. \bold{Only relevant if \code{rename = TRUE}!}
#' @param .onsplit Logical. by default searches for sub folder split and bases analyses on segmented files if found. Also switched to TRUE if segment is not NULL.

#' @inheritParams extract_events
#' @return Data frame with extracted events if \code{\link{extract_events}} was queried.
#' @export
#'
batch_process <- function(
  path = NULL,
  format = c("WAV", "wav", "mp3", "MP3"),
  steps = 1:6,
  rename = TRUE,
  segment = NULL,
  mono = TRUE,
  downsample = NULL,
  rescale = NULL,
  SNR = 8,
  buffer = 1,
  max.events = 999,
  target = td_presets("Bubo bubo"),
  recorder = c("AudioMoth", "Olympus LS-3", "Sony PCM-D100"),
  time = c("ctime", "mtime"),
  .onsplit = TRUE) {

  ## Print start time and info
  ## ---------------------------------------------------------------------------
  t_start <- Sys.time()

  if (format %in% c("WAV", "wav")) {
    ## get total duration and sampling frequency of the data to process
    audio_summary <- total_duration(path, format)
    cat("Start processing:\t", as.character(t_start),"\t", "[Input audio",
        audio_summary$duration, "@", audio_summary$sample_rate, "]\n")
  } else {
    cat("Start processing:\t", as.character(t_start),"\n")
  }



  ## get function arguments
  format <- match.arg(format)
  recorder <- match.arg(recorder)
  time <- match.arg(time)
  #target <- match.arg(target)
  if (!is.numeric(SNR)) stop("Specify a numeric value for parameter SNR")
  if (!is.null(segment)) {
    if (!is.numeric(segment)) stop("Specify a numeric value for parameter segment or NULL")
  }
  if (!is.null(downsample)) {
    if (!is.numeric(downsample)) stop("Specify a numeric value for parameter downsample or NULL")
  }
  if (!dir.exists(path)) stop("Specify a valid path to sound files")
  ## translate characters in steps to numeric (if any)
  if (any(is.character(steps))) {
    steps[steps == "rename_recording"] <- 1
    steps[steps == "split_wave"] <- 2
    steps[steps == "find_events"] <- 3
    steps[steps == "join_audacity"] <- 4
    steps[steps == "extract_events"] <- 5
    steps[steps == "merge_events"] <- 6

  }

  ## define a flag to interrupt processing if no events are found
  ## Will be updated if find_events fails
  ## ---------------------------------------------------------------------------
  stop_processing <- FALSE

  ## 1.) Rename if not AudioMoth
  ## ---------------------------------------------------------------------------
  if ("1" %in% steps & rename == TRUE) {
    cat("Rename recodings ... \t")
    rename_recording(path = path, recorder = recorder, format = format, time = time)
    cat("done\n")
  }

  ## 2.) Split
  ## ---------------------------------------------------------------------------
  if ("2" %in% steps & !is.null(segment)) {
    if (format %in% c("MP3", "mp3")) stop("only wav supported. convert data!\n")
    cat("Split recordings ... \t")
    wavs <- list.files(path = path, pattern = format)
    ## avoid files of previous run!
    wavs <- wavs[!stringr::str_detect(wavs, "_extracted.WAV")]
    wavs <- wavs[!stringr::str_detect(wavs, "merged_events.WAV")]

    for (i in wavs) {
      split_wave(file = i, path = path,
                 segment = segment, mono = mono, downsample = downsample)
    }
    ## check for temp folder
    if (dir.exists(file.path(path, "temp"))) unlink(file.path(path, "temp"), recursive = TRUE)
    cat("done\n")
  }

  ## 3.) Perform event detection
  ## ---------------------------------------------------------------------------
  if ("3" %in% steps) {
    cat("Search for events ...\n")

    ## check if asked to perform task on segments instead of full file
    if (.onsplit == FALSE & !is.null(segment)) .onsplit <- TRUE
    if (.onsplit == TRUE & dir.exists(file.path(path, "split"))) {
      #if (!dir.exists(file.path(path, "split"))) stop("Folder split not found!")

      TD <- pbapply::pblapply(list.files(file.path(path, "split"), pattern = format, full.names = T),
                              function(x) {
                                find_events(wav.file = x,
                                            overwrite = TRUE,
                                            threshold = SNR,
                                            min_dur = target$min_dur,
                                            max_dur = target$max_dur,
                                            HPF = target$HPF,
                                            LPF = target$LPF)})
    } else {
      TD <- lapply(list.files(path, pattern = format, full.names = T),
                   function(x) {
                     find_events(wav.file = x,
                                 overwrite = TRUE,
                                 threshold = SNR,
                                 min_dur = target$min_dur,
                                 max_dur = target$max_dur,
                                 HPF = target$HPF,
                                 LPF = target$LPF)})
    }
    ## check if number of events is zero
    TD_data <- do.call("rbind", lapply(TD, function(x) x$data$event_data))
    cat("done\n")
    ## Check  for option of no events found, print warning and stop
    if (length(TD_data) == 0) {
      cat("No events found!\n")
      stop_processing <- TRUE
    }
  }


  if (stop_processing == FALSE) {

    ## 4.) Join audacity marks
    ## ---------------------------------------------------------------------------
    if ("4" %in% steps & dir.exists(file.path(path, "split"))) {
      ## get all of the original wav files
      wavs <- list.files(path = path, full.names = F, pattern = format)
      ## avoid files of previous run!
      wavs <- wavs[!stringr::str_detect(wavs, "_extracted.WAV")]
      wavs <- wavs[!stringr::str_detect(wavs, "merged_events.WAV")]

      ## ignore files that do not match the date_time string
      wavs <- has_date_time_name(wavs)
      cat("Join audacity marks ...\t")
      ## load marks of the segmented files
      x <- lapply(wavs, join_audacity,
                 target.path = path,
                 split.path = file.path(path, "split"))
      cat("done\n")
    }

    ## 5.) extract events based on audacity marks
    ## ---------------------------------------------------------------------------
    if ("5" %in% steps) {
      audacity <- list.files(path = path, full.names = T, pattern = "txt")
      ## kick out _extracted.txt if present
      audacity <- audacity[!stringr::str_detect(audacity, "_extracted.txt")]
      audacity <- audacity[!stringr::str_detect(audacity, "merged_events.txt")]


      ## Read audacity marks
      labels <- lapply(audacity, seewave::read.audacity)
      ## Prompt error if none found
      if (length(labels) == 0) stop("\nNo audacity files in", path, " detected!\n")


      ## summarise number of events to check if realistic ...
      length <- sapply(labels, nrow)

      if (any(length) > max.events) warning("\nAt least one audio file has more than",  max.events,  "events and will be skipped\n")

      audacity <- audacity[length <= max.events]

      cat("Extract events ... \n")
      output <- lapply(audacity, extract_events,
                       buffer = buffer,
                       format = format,
                       path = path,
                       HPF = target$HPF,
                       LPF = target$LPF,
                       mono = mono,
                       downsample = downsample,
                       rescale = rescale)
      output_length <- length(output)
      output <- do.call("rbind", output)
      cat("\nIn total", output_length, "events detected\n")
    }

    if ("6" %in% steps) {
      cat("Merge events and write audio", file.path(path, "merged_events.WAV\n"))
      merge_events(path = path)
    }
  }

  t_finish <- Sys.time()
  cat("Finished processing:\t", as.character(t_finish),"\n")

  took <- data.frame(
    secs = as.numeric(t_finish - t_start, units = "secs"),
    mins = as.numeric(t_finish - t_start, units = "mins"),
    hours = as.numeric(t_finish - t_start, units = "hours")
  )

  if (took$secs < 60) {
    cat("\tRun time:\t", round(took$secs, 2), "seconds\n")
  } else if (took$mins < 60) {
    cat("\tRun time:\t", round(took$mins, 2), "minutes\n")
  } else {
    cat("\tRun time:\t", round(took$hours, 2), "hours\n")
  }

  if (exists("output")) return(output)
}

