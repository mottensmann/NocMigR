#' Remove output created while processing audio files
#'
#' @description
#' Removes folder 'split' and all files with extension 'extracted' within the main folder. Wont touch original files and only works in interactive mode by requesting user input
#'
#' @param path path
#' @return none.
#' @export
#'
cleanup_batch_process <- function(path = NULL) {

  ## check if subdir split exist
  if (dir.exists(file.path(path, "split"))) {
    user_response <- readline(prompt = paste("Delete", file.path(path, "split"), "and all content [y/n]?\n"))
    if (user_response == "y") unlink(file.path(path, "split"), recursive = TRUE)
  }

  ## check if subdir split exist
  if (dir.exists(file.path(path, "temp"))) {
    user_response <- readline(prompt = paste("Delete", file.path(path, "temp"), "and all content [y/n]?\n"))
    if (user_response == "y") unlink(file.path(path, "temp"), recursive = TRUE)
  }

  ## check if extracted files were written
  #extracted <- list.files(path, pattern = "_extracted.")
  extracted_path <- list.files(path, pattern = "_extracted.", full.names = T)

  if (length(extracted_path) > 0 ) {
    user_response <- readline(prompt = "Delete extracted files [y/n]?\n")
    if (user_response == "y") unlink(extracted_path)
  }

  # check if merged_events files were written
  #merged <- list.files(path, pattern = "merged.events")
  merged_path <- list.files(path, pattern = "merged.events", full.names = T)

  if (length(merged_path) > 0 ) {
    user_response <- readline(prompt = "Delete merged.event files [y/n]?\n")
    if (user_response == "y") unlink(merged_path)
  }

  ## audacity text files
  audacity <- list.files(path, pattern = ".txt", full.names = T)
  if (length(audacity) > 0) {
    user_response <- readline(prompt = "Delete audacity (.txt) files [y/n]?\n")
    if (user_response == "y") unlink(audacity)

  }


}
