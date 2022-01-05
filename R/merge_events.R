#' Merge output
#'
#' @inheritParams batch_process
#' @importFrom tuneR bind
#' @export
#'
merge_events <- function(path) {
  ## get WAV files and
  waves <- list.files(path, "extracted.WAV", full.names = T)

  ## extract audio --> CHECK OVERLAPPING ISSUES IF ANY
  if (length(waves) == 1) {
    audio <- tuneR::readWave(waves)
  } else{
    audio <- do.call("bind", lapply(waves, tuneR::readWave))
  }

  ## write to file
  ## check file is not too big ...
  size <- format(utils::object.size(audio), units = "GB")
  if (as.numeric(substr(size, 1, (nchar(size) - 3))) >= 1) {
    cat("Try to write merged_events.WAV, file size is ", size, "and might fail\n")
    error_messages <- try(tuneR::writeWave(audio, file.path(path, "merged_events.WAV")))
    if (is.character(error_messages[1])) cat("Try rerun merge_events after restart!\n")
  } else {
    tuneR::writeWave(audio, file.path(path, "merged_events.WAV"))
  }

  ## get audacity labels
  labels <- list.files(path, "extracted.txt", full.names = T)
  audacity <- lapply(labels, seewave::read.audacity, format = "base")


  if (length(audacity) > 1) {
    ## get seconds for individual files
    length_by_file <- sapply(audacity, function(df) max(df$t2))
    ## adjust times ...
    for (i in 2:length(audacity)) {
      audacity[[i]]$t1 <- audacity[[i]]$t1 + length_by_file[i - 1]
      audacity[[i]]$t2 <- audacity[[i]]$t2 + length_by_file[i - 1]

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
