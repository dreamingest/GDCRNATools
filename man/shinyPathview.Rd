% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gdcShinyPlot.R
\name{shinyPathview}
\alias{shinyPathview}
\title{Shiny pathview}
\usage{
shinyPathview(gene, pathways, directory = ".")
}
\arguments{
\item{gene}{a vector of numeric values (eg. fold change on log2 scale) with names are Ensembl gene ids}

\item{pathways}{a vector of KEGG pathway ids}

\item{directory}{the folder to save pathway figures. Default is the working directory}
}
\value{
a local webpage for visualization of KEGG maps
}
\description{
A simple \pkg{shiny} app to show pathways genetrated by \pkg{pathview} package on local web browser
}
\author{
Ruidong Li and Han Qu
}
