#' creates 'R_code.R' as a template within given path
#'
#' @param path path used for analysing recordings
#' @param open by default opens the R Script
#' @return Writes and open script file
#' @export
#'
create_R_script <- function(path, open = TRUE) {
  sink(file = file.path(path, "R_code.R"), append = FALSE)
  cat('library(NocMigR)\n')
  cat(paste0('
  df <- batch_process(path = "', path,'",
                      format = "WAV",
                      recorder = "AudioMoth",
                      target = td_presets("NocMig"),
                      SNR = 6,
                      steps = 1:6,
                      max.events = 400)
      '))
  cat(paste0('cleanup_batch_process(path = "', path,'")'))
  sink()
  if(open == TRUE) file.show(file.path(path, "R_code.R"))
}
