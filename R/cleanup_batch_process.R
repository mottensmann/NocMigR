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
    user_response <- readline(prompt = paste("Delete", file.path(path, "split"), "and all content [y/n]?"))
    if (user_response == "y") unlink(file.path(path, "split"), recursive = TRUE)
  }

  ## check if extracted files were written
  extracted <- list.files(path, pattern = "extracted")
  extracted_path <- list.files(path, pattern = "extracted", full.names = T)

  if (length(extracted) > 0 ) {
    user_response <- readline(prompt = "Delete extracted files [y/n]?")
    if (user_response == "y") unlink(extracted_path)
  }

}
