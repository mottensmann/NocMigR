#' Predict number of AudioMoth recording days
#'
#' @description Calculates maximum recording duration in days. Predictions are based on estimated file size and daily energy consumption shown in AudioMoth configuration app.
#'
#' @param MB capacity of micro SD memory card in MB
#' @param MB.d daily file size in MB
#' @param mAH.d Predicted daily energy consumption in mAH
#' @param mAH capacity of installed batteries
#' @return data frame
#' @examples
#' AudioMoth_days()
#' @export
AudioMoth_days <- function(mAH.d = 90, mAH = 2600, MB = 128*1000, MB.d = 3456) {
  cat("Maximum memory:", floor(MB/MB.d), "days\n")
  cat("Maximum capacity:", floor(mAH/mAH.d), "days\n")
  return(data.frame(mAH.d, mAH, MB, MB.d,
                    memory_days = floor(MB/MB.d),
                    capacity_days =  floor(mAH/mAH.d)))
}


