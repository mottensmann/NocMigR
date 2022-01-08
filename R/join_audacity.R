#' Join output of segmented files belonging to the same original audio and creates file with audacity labels
#'
#' @description
#' Loops through segmented audio files to match audacity marks to the original recording and creates a new file with audacity labels.
#'
#' @param target original recording
#' @param target.path original recording path
#' @param split.path path to split recordings
#' @return none
#' @export
#'
join_audacity <- function(target, target.path, split.path) {

  target.info <- get_DateTime(target, target.path)

  ## loop through folder
  childs.info <- do.call(
    "rbind",
    lapply(list.files(split.path, full.names = F, pattern = "WAV"), get_DateTime, target.path = split.path))

  ## select child of parent based on start and end time, truncated to exclude
  ## variatio beyond the second
  ## (binding global variables to please R CMD check)
  start <- end <- NULL
  childs <- dplyr::filter(childs.info,  trunc.POSIXt(start) >= target.info$start, trunc.POSIXt(end) <= target.info$end)
  childs$order <- 1:nrow(childs)

  ## read all audacity marks
  audacity <- list.files(split.path, full.names = F, pattern = "txt")
  ## Prompt error if empty vector (i.e., no events to join)
  if (length(audacity) == 0) stop("\nNo audacity files in ", split.path, " detected!\n")

  ## select the ones that are within the time period covered by the parent file
  wanted <- stringr::str_replace(childs$file, "WAV", "txt")
  audacity <- wanted[which(wanted %in% audacity)]
  audacity <- lapply(file.path(split.path, audacity), seewave::read.audacity, format = "base")

  if (length(audacity) > 0) {
    df <- do.call("rbind", lapply(audacity, function(x) {
      tmp <- dplyr::left_join(x, childs, by = c("file" = "txt"))
      tmp$t1 <- tmp$t1 + ((tmp$order - 1) * tmp$sec)
      tmp$t2 <- tmp$t2 + ((tmp$order - 1) * tmp$sec)
      return(tmp[,c("label", "t1", "t2", "f1", "f2")])
    }))

    seewave::write.audacity(df,
                            filename = file.path(target.info$path, target.info$txt))

  }
}

