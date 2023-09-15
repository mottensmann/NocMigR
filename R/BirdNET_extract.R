#' Extract specific event from BirdNET results file
#'
#' @details
#' Prerequisites:
#' (1) Run analyzer.py (same folder specified for --i and --o!)
#' (2) Reshape output using function BirdNET (this package)
#' (3) Ensure wav files, BirdNET_results.txt and BirdNET.xlsx files share the same path
#'
#'
#' @param path path
#' @param output path to write wav files
#' @param taxon optional. select target taxa
#' @param score minimum confidence score
#' @param nmax maximum number of segments per taxon. default 10
#' @param sec seconds before and after target to extract
#' @param hyperlink optional. Insert hyperlink to audio file in xlsx document. Only if records are not filtered.
#'
#' @export
#'
BirdNET_extract <- function(path = NULL, taxon = NULL, score = NULL, nmax = NULL, sec = 1, output = NULL, hyperlink = F) {
  if (!dir.exists(path)) stop("provide valid path")

  ## 1.) Check for BirdNET.xlsx and load if present
  ## ---------------------------------------------------------------------------
  if (!file.exists(file.path(path, "BirdNET.xlsx"))) stop("BirdNET.xlsx not found")
  xlsx <- readxl::read_xlsx(file.path(path, "BirdNET.xlsx"))

  ## 2.) Optional: Subset results to extract
  ## ---------------------------------------------------------------------------
  if (!is.null(taxon)) {
    Taxon = NA
    if (length(taxon) == 1) {
      xlsx <- dplyr::filter(xlsx, Taxon == taxon)
    } else {
      xlsx <- dplyr::filter(xlsx, Taxon %in% taxon)
    }

  }

  if (!is.null(score)) {
    Score = NA
    xlsx <- dplyr::filter(xlsx, Score >= score)
  }

  if (!is.null(nmax)) {
    xlsx <- lapply(unique(xlsx[["Taxon"]]), function(one_taxon) {
      df <- dplyr::filter(xlsx, Taxon == one_taxon)
      if (nrow(df) > nmax) {
        return(df[sample(1:nrow(df), nmax, F),])
      } else {
        return(df)
      }
    })
    xlsx <- do.call("rbind", xlsx)
  }

  ## create folder per taxon
  ## -------------------------------------------------------------------------
  if (is.null(output)) output <- file.path(path, "extracted")
  if (!dir.exists(output)) dir.create(output)

  silent <- sapply(unique(xlsx[["Taxon"]]), function(one_taxon) {
    if (!dir.exists(file.path(output, one_taxon))) {
      dir.create(file.path(output, one_taxon))
    }})

  ## 3.) Extract ...
  ## ---------------------------------------------------------------------------
  out <- pbapply::pbsapply(1:nrow(xlsx), function(r) {

    ## find wav file
    ##  ------------------------------------------------------------------------
    wav <- stringr::str_replace( xlsx[[r, "File"]], "BirdNET.results.txt", "WAV")
    if (!file.exists(wav)) stop(wav, "not found")

    ##  select event time stamps
    ##  ------------------------------------------------------------------------
    t0 <- xlsx[[r, "T0"]]; t1 <- xlsx[[r, "T1"]]; t2 <- xlsx[[r, "T2"]]

    ## create a suitable file name
    name <- file.path(
      output,
      xlsx[r, "Taxon"],
      paste0(
        xlsx[[r, "Taxon"]], "_",
        trimws(stringr::str_replace_all(
          as.character(t1), c(":" = "", "-" = "", " " = "_"))), ".WAV"))


    ## add buffer around event
    ## -------------------------------------------------------------------------
    from = as.numeric(difftime(t1, t0, units = "secs")) - sec
    if (from < 0) from <- 0
    to = as.numeric(difftime(t2, t0, units = "secs")) + sec
    if (to > t2) to <- t2

    ## extract event
    ##  ------------------------------------------------------------------------
    event <- tuneR::readWave(
      filename = wav,
      from = from,
      to = to,
      units = "seconds")

    ## export audio segments
    ## -------------------------------------------------------------------------
    tuneR::writeWave(
      object = event,
      filename = name)
    return(name)
  })

  ## put hyperlink in excel sheet?
  ## -------------------------------------------------------------------------
  if (isTRUE(hyperlink)) {
    wb <- openxlsx::createWorkbook()
    openxlsx::addWorksheet(wb, 'Hyperlink')
    ## Link to internal file
    wav.link =  openxlsx::makeHyperlinkString(text = out, file = out)
    openxlsx::writeFormula(wb, "Hyperlink", startRow = 1, startCol = 1, x = wav.link)
    openxlsx::saveWorkbook(wb, file.path(path, "BirdNET_Hyperlink.xlsx"), overwrite = TRUE)
  }
}
