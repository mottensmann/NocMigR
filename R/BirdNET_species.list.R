#' Create custom species list
#' @param out path
#' @param names character vector
#' @export
#'
BirdNET_species.list <- function(names = NULL, out = NULL) {
  ## read species list
  ## ---------------------------------------------------------------------------
  path_de <- system.file("extdata", "BirdNET_GLOBAL_6K_V2.4_Labels_de.txt", package = "NocMigR")
  path_en <- system.file("extdata", "BirdNET_GLOBAL_6K_V2.4_Labels.txt", package = "NocMigR")

  species_list_de <- suppressMessages(readr::read_delim(path_de, delim = "_", col_names = c("scientific_name", "german_name")))
  species_list_en <- suppressMessages(readr::read_delim(path_en, delim = "_", col_names = c("scientific_name", "englisch_name")))

  ## subset species list
  ## ---------------------------------------------------------------------------
  df_de <- dplyr::filter(species_list_de, german_name %in% names)
  df_en <- dplyr::filter(species_list_en, scientific_name %in% df_de$scientific_name)

  ## write to file
  ## ---------------------------------------------------------------------------
  readr::write_delim(x = df_en, delim = "_", col_names = FALSE, file = out)
  df_en
}
