% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plate_map_onto_plate.R
\name{filter_merged}
\alias{filter_merged}
\title{filter_merged}
\usage{
filter_merged(plates_merged, condition = NULL, virus = NULL)
}
\arguments{
\item{plates_merged}{the dataframe of the merged normalised plates}

\item{condition}{The inidividual or test condition you want to filter by, can be a single string, or a list. "AZ12"}

\item{virus}{The virus that you want to filter by. Can be a single string, or a list. e.g. c("Virus1","VIrus2")}
}
\value{
A filtered dataframe of normalised values.
}
\description{
Filters the dataframe by conditions or virus
}
