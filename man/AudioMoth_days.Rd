% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AudioMoth_days.R
\name{AudioMoth_days}
\alias{AudioMoth_days}
\title{Predict number of AudioMoth recording days}
\usage{
AudioMoth_days(mAH.d = 90, mAH = 2600, MB = 128 * 1000, MB.d = 3456)
}
\arguments{
\item{mAH.d}{Predicted daily energy consumption in mAH}

\item{mAH}{capacity of installed batteries}

\item{MB}{capacity of micro SD memory card in MB}

\item{MB.d}{daily file size in MB}
}
\value{
data frame
}
\description{
Calculates maximum recording duration in days. Predictions are based on estimated file size and daily energy consumption shown in AudioMoth configuration app.
}
\examples{
AudioMoth_days()
}
