#' Merge output
#'
#' @description Loops through folder and merges files with extension "extracted.wav" into a new file 'merged.events.wav' (and the same with audacity labels). Optionally, rescales to a new bit rate (e.g., "8" or "16") to avoid memory issues. If file size is to large, automatically tries to downsample to 32 kHz.
#'
#' @inheritParams batch_process
#' @inheritParams split_wave
#' @importFrom tuneR bind
#' @export
#'
merge_events <- function(path, rescale = NULL) {
  ## list wav files
  waves <- list.files(path, "extracted.WAV", full.names = T)
  ## check for exsisting output and drop warning
  merge.events <- list.files(path, "merged_events.WAV", full.names = T)
  if (length(merge.events) > 0) cat("\nExisting files merged_events.WAV  will be overwritten!\n")

  ## extract audio --> CHECK OVERLAPPING ISSUES IF ANY
  if (length(waves) == 1) {
    audio <- tuneR::readWave(waves)
    if (!is.null(rescale)) audio <- tuneR::normalize(audio, unit = as.character(rescale))
  } else{
    audio <- do.call("bind", lapply(waves, function(x) {
      audio.x <- tuneR::readWave(x)
      if (!is.null(rescale)) audio.x <- tuneR::normalize(audio.x, unit = as.character(rescale))
      return(audio.x)
    }))
  }

  ## write to file
  ## check file is not too big ...
  size <- format(utils::object.size(audio), units = "GB")
  if (as.numeric(substr(size, 1, (nchar(size) - 3))) >= 0.5) {
    cat("Try to write merged_events.WAV, file size is ", size, "and might fail\n")
    error_messages <- try(tuneR::writeWave(audio, file.path(path, "merged_events.WAV")))
    gc()
    ## try with down-sampling
    if (is.character(error_messages[1])) {
      cat("Try rerun with downsampling to 32 kHz!\n")
      audio <- tuneR::downsample(audio, 32000)
      error_messages <- try(tuneR::writeWave(audio, file.path(path, "merged_events.WAV")))
      gc()
    }

    if (is.character(error_messages[1])) {
      cat("Try rerun with downsampling to 22.05 kHz!\n")
      audio <- tuneR::downsample(audio, 22050)
      error_messages <- try(tuneR::writeWave(audio, file.path(path, "merged_events.WAV")))
    }

    if (is.character(error_messages[1])) cat("Try rerun merge_events after restart!\n")

  } else {
    error_messages <- try(tuneR::writeWave(audio, file.path(path, "merged_events.WAV")))
  }

  ## try to free unused memory
  gc()
  ## Load Audacity labels (sort to force to chronological order)
  labels <- sort(list.files(path, "extracted.txt", full.names = T))
  audacity <- lapply(labels, seewave::read.audacity, format = "base")


  ## If there are several files, t1 and t2 need updating
  if (length(audacity) > 1) {
    ## get duration of individual audio files in seconds,
    ## here defined as the maximum t2 values
    ## (last event of the corresponding wav file)
    length_by_file <- sapply(audacity, function(df) max(df$t2))
    length_offset <- cumsum(length_by_file)

    ## adjust times by adding the duration of the previous file
    ## to both t1 and t2
    for (i in 2:length(audacity)) {
      audacity[[i]]$t1 <- audacity[[i]]$t1 + length_offset[i - 1]
      audacity[[i]]$t2 <- audacity[[i]]$t2 + length_offset[i - 1]
    }
  }
  audacity <- do.call("rbind", audacity)

  ## for some reason, read.audacity skips first character of labels ...
  ## repair by adding a first character of file name ..
  if (all(nchar(audacity$label)) < 19) {
    audacity$label <- paste0(substr(audacity$file, 1, 1), audacity$label, "")
  }
  ## export labels
  seewave::write.audacity(audacity[,c("label", "t1", "t2")],
                          file.path(path, "merged_events.txt"))
  ## try to free memory
  x <- gc(verbose = FALSE); rm(x)
}
