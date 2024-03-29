% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/join_audacity.R
\name{join_audacity}
\alias{join_audacity}
\title{Join output of segmented files belonging to the same original audio and creates file with audacity labels}
\usage{
join_audacity(target, target.path, split.path)
}
\arguments{
\item{target}{original recording}

\item{target.path}{original recording path}

\item{split.path}{path to split recordings}
}
\value{
none
}
\description{
Loops through segmented audio files to match audacity marks to the original recording and creates a new file with audacity labels.
}
