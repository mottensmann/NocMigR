#' creates 'R_code.R' as a template within given path
#'
#' @param path path used for analysing recordings
#' @param open by default opens the R Script
#' @return Writes and open script file
#' @export
#'
create_R_script2 <- function(path, open = TRUE) {
  sink(file = file.path(path, "R_code.R"), append = FALSE)
  cat('library(NocMigR)\n')
  cat(paste0('
df <- batch_process(path = "', path,'",
                    format = "WAV",
                    recorder = "Olympus LS-3",
                    target = data.frame(
                    HPF = 300,
                    LPF = 12000,
                    min_dur = 10,
                    max_dur = 800),
                    SNR = 6,
                    downsample = NULL,
                    mono = TRUE,
                    rename = TRUE,
                    steps = 1:3,
                    max.events = 9999)
     '))
cat(paste0('cleanup_batch_process(path = "', path,'")'))
  sink()
  if (open == TRUE) file.show(file.path(path, "R_code.R"))
}
