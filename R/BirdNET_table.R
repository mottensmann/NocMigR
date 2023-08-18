#' Tabulise BirdNET detections
#'
#' @param path path
#' @import ggplot2 magrittr
#' @export
#'
BirdNET_table <- function(path = NULL) {
  if (!dir.exists(path)) stop("provide valid path")

  ## 0.) Check 'BirdNET.results.txt'
  ## -----------------------------------------------------------------------------
  BirdNET.results.files <- list.files(path = path, pattern = "BirdNET.results.txt", full.names = T)


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

    ## count per hour
    ## -------------------------------------------------------------------------
    df <- df[,c("species", "hour")] %>%
      dplyr::group_by(species, hour) %>%
      dplyr::summarise(n = dplyr::n())

    df[["species"]] <- factor(x = df[["species"]],
                              levels = unique(as.character(sort(df$species, decreasing = TRUE))))


   (plot <- ggplot(df, aes(x = hour, y = species, fill =  n)) +
      geom_tile(color = "transparent", linewidth = 0.01, na.rm = TRUE) +
      geom_text(aes(label = n), col = "white") +
      theme_minimal() +
      theme(
        axis.text = element_text(colour = "black", size = 10),
        axis.title.y = element_blank(),
        legend.position = "none") +
      labs(title = "BirdNET Ergebnisse", x = "Stunde") +
      scale_x_continuous(limits = c(0,24), expand = c(0,0), breaks = seq(0,24,3)) +
      scale_fill_binned(type = "viridis"))
    return(list(table = output[,c("species", "date", "time")], summary = df, plot = plot))
  }
}



