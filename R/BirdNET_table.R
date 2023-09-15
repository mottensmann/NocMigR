#' Tabulise BirdNET detections
#'
#' @param path path
#' @param plot ggplot
#' @import magrittr
#' @inheritParams BirdNET_results2txt
#' @keywords internal
#'
BirdNET_table <- function(path = NULL, recursive = FALSE) {
  if (!dir.exists(path)) stop("provide valid path")

  ## 0.) Check 'BirdNET.results.txt'
  ## -----------------------------------------------------------------------------
  BirdNET.results.files <- list.files(path = path,
                                      pattern = "BirdNET.labels.txt",
                                      full.names = T,
                                      recursive = recursive)


  if (length(BirdNET.results.files >= 1)) {
    ## read audacity marks
    ## -------------------------------------------------------------------------
    df <- suppressMessages(do.call("rbind",
                                   lapply(BirdNET.results.files,
                                          readr::read_delim,
                                          col_names = c("label", "date", "time", "x1", "score", "x2"))))
    ## retrieve species
    ## -------------------------------------------------------------------------
    df[["species"]] <- sapply(df$label, function(x) {
      x1 <- stringr::str_split(x, pattern = "\t")[[1]]
      x1[length(x1)]
    })
    ## retrieve hour
    ## -------------------------------------------------------------------------
    df[["hour"]] <- lubridate::hour(df$time)

    output <- df

    ## count per day
    ## -------------------------------------------------------------------------
    records.day <- df[,c("species", "date")] %>%
      dplyr::group_by(species, date) %>%
      dplyr::summarise(n = dplyr::n())

    ## count per hour
    ## -------------------------------------------------------------------------
    df <- df[,c("species", "hour")] %>%
      dplyr::group_by(species, hour) %>%
      dplyr::summarise(n = dplyr::n())


    df[["species"]] <- factor(x = df[["species"]],
                              levels = unique(as.character(sort(df$species, decreasing = TRUE))))

    return(list(records.all = output[,c("species", "date", "time")],
                records.day = records.day,
                records.hour = df))

  }
}



