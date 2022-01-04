#' Main function to run all steps on a folder of sound files
#'
#' @description
#' Main function of the package `NocMigR` that allows to analyse a suite of long-term recordings from scratch by executing five distinct steps (see `details` section.).*Under the hood*, this function is calling algorithms of the fabulous R packages \pkg{tuneR}, \pkg{warbleR}, \pkg{seewave} and \pkg{bioacoustics}.
#' **Important note**:
#' Especially for large sets of recordings (e.g., `AudioMoth` deployed for a weak, ~ 60 GB data) R can easily run into memory issues. This can surely be tackled by coding functions more efficiently. For now, the best way to handle this issue is to resume the script after it broke (see output in the console and check \code{steps} argument).
#' @details
#' By default, five consecutive steps (see \code{steps}) are undertaken to analyse recordings. All recordings of a project (i.e., continuous signal or time-expanded if otherwise) need to be saved to a single directory, specified \code{path}  argument:
#'
#' 1.) Rename audio files to `YYYYMMDD_HHMMSS` format, where the date and time at the onset of the recording are coded by the file name. This steps ensures that all downstream algorithms can compute the correct dates and times of events. If files are already formatted correctly (e.g, capture by `AudioMoth`) this steps can be skipped by removing **"1"** from the vector \code{steps} (e.g., \code{steps = 2:5}). *This step utilises the function \code{\link[NocMigR]{rename_recording}}*
#'
#' 2.) Split audio files in chunks of length \code{segment} to reduce the file size prior to calling event detection algorithms. Within the parent folder (\code{path}) a subfolder "split" is created to dump the files. Each file is named with the correct `YYYYMMDD_HHMMSS` string. If files are already formatted correctly (e.g, capture by `AudioMoth`) this steps can be skipped by removing **"2"** from the vector \code{steps} (e.g., \code{steps = 3:5}).*This step utilises the function \code{\link[NocMigR]{split_wave}}*
#'
#' 3.) Queries \code{\link[bioacoustics]{threshold_detection}} to detect events based on signal-to-noise ratios (\code{SNR}). When events are found, a `txt`file is written with labels for `Audacity`. *This step utilises the function \code{\link[NocMigR]{find_events}}*
#' 4.) Extract events from original recordings and writes them to a WAVE file.
#' *This step utilises the function \code{\link[NocMigR]{extract_events}}*
#'#'
#' @param path path to a set of recordings (all same format and continuous time span)
#' @param format format of sound files. Either WAV (default) or mp3
#' @param rename logical. By default renames files using date and time.
#' @param time Controls, if ctime or mtime is used to compute date_time objects.
#' @param segment Null, or numeric value giving segment size for split_wave in seconds.
#' @param mono logical. By default, split_wave coerces stereo to mono prio to event detection.
#' @param recorder currently three templates to ensure correct handling of times
#' @param downsample Null or re-sampling factor used in split_wave.
#' @param species species used as template to specify parameters in event detection by \code{\link[bioacoustics]{threshold_detection}}. See \code{\link[NocMigR]{td_presets}} for parameters and current implementations.
#' @param SNR numeric value (db) giving signal to noise ratio in event detection.
#' @param steps numeric vector, by default steps 1:5 are executed.
#' @param max.events numeric, giving the maximum number of events before a file is skipped. Usually very high detection rates indicate an issue with noise (e.g., wind or rain)
#' @inheritParams extract_events
#' @return data frame with extracted events
#' @export
#'
batch_process <- function(
  path = NULL,
  format = c("WAV", "wav", "mp3", "MP3"),
  recorder = c("AudioMoth", "Olympus LS-3", "Sony PCM-D100"),
  time = c("ctime", "mtime"),
  segment = NULL,
  mono = TRUE,
  downsample = NULL,
  SNR = 8,
  steps = 1:5,
  max.events = 200,
  species = c("Bubo bubo", "Strix aluco", "NocMig", "Glaucidium passerinum",
              "Shot"),
  rename = TRUE,
  buffer = 1) {

  ## Stop the time ...
  ## ---------------------------------------------------------------------------
  t_start <- Sys.time()
  cat("Start processing:\t", as.character(t_start),"\n")

  ## get function arguments
  format <- match.arg(format)
  recorder <- match.arg(recorder)
  time <- match.arg(time)
  species <- match.arg(species)
  if (!is.numeric(SNR)) stop("Specify a numeric value for parameter SNR")
  if (!is.null(segment)) {
    if (!is.numeric(segment)) stop("Specify a numeric value for parameter segment or NULL")
  }
  if (!is.null(downsample)) {
    if (!is.numeric(downsample)) stop("Specify a numeric value for parameter downsample or NULL")
  }
  if (!dir.exists(path)) stop("Specify a valid path to sound files")

  ## 1.) Rename if not AudioMoth
  ## ---------------------------------------------------------------------------
  if (recorder != "AudioMoth" & "1" %in% steps & rename == TRUE) {
    cat("Rename recodings ... \t")
    rename_recording(path = path, recorder = recorder, format = format, time = time)
    cat("done\n")
  }

  ## 2.) Split
  ## ---------------------------------------------------------------------------
  if ("2" %in% steps & !is.null(segment)) {
    cat("Split recordings ... \t")
    wavs <- list.files(path = path, pattern = format)
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
    preset <- td_presets(species = species)
    cat("Search for events using", species, "as template ...\n")

    ## check if asked to perform task on segments instead of full file
    if (!is.null(segment)) {
      if (!dir.exists(file.path(path, "split"))) stop("Folder split not found!")

      TD <- pbapply::pblapply(list.files(file.path(path, "split"), pattern = format, full.names = T),
                              function(x) {
                                find_events(wav.file = x,
                                            overwrite = TRUE,
                                            threshold = SNR,
                                            min_dur = preset$min_dur,
                                            max_dur = preset$max_dur,
                                            HPF = preset$HPF,
                                            LPF = preset$LPF)})
    } else {
      TD <- lapply(list.files(path, pattern = format, full.names = T),
                   function(x) {
                     find_events(wav.file = x,
                                 overwrite = TRUE,
                                 threshold = SNR,
                                 min_dur = preset$min_dur,
                                 max_dur = preset$max_dur,
                                 HPF = preset$HPF,
                                 LPF = preset$LPF)})
    }

    cat("done\n")
  }
  ## 4.) Join audacity marks
  ## ---------------------------------------------------------------------------
  if ("4" %in% steps & dir.exists(file.path(path, "split"))) {
    ## get all of the original wav files
    wavs <- list.files(path = path, full.names = F, pattern = format)
    ## ignore files that do not match the date_time string
    wavs <- has_date_time_name(wavs)
    cat("Join audacity marks ...\t")
    ## load marks of the segmented files
    x <-lapply(wavs, join_audacity,
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

    ## summarise number of events to check if realistic ...
    labels <- lapply(audacity, seewave::read.audacity)
    length <- sapply(labels, nrow)

    if (any(length) > max.events) warning("\nAt least one audio file has more than",  max.events,  "events and will be skipped\n")

    audacity <- audacity[length <= max.events]

    cat("Extract events ... \n")
    output <- lapply(audacity, extract_events,
                     buffer = buffer,
                     format = format,
                     path = path,
                     HPF = preset$HPF,
                     LPF = preset$LPF)
    output <- do.call("rbind", output)
    cat("\ndone\n")
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

  if ("5" %in% steps) cat("In total", nrow(output), "events for template", species, "detected")
  return(output)
}

