% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_ave_plot_data.R
\name{create_ave_plot_data}
\alias{create_ave_plot_data}
\title{create_ave_plot_data}
\usage{
create_ave_plot_data(x, y_true, y_pred = NULL, w = NULL, rescale = FALSE)
}
\arguments{
\item{x}{A vector that contains the dimension that you want to aggregate by}

\item{y_true}{A vector that contains the target variable (think OBS in emblem)}

\item{y_pred}{A vector that contains the fitted value from a model (think CA in emblem). Defaults to NULL}

\item{w}{A vector that contains row level weights (e.g. exposure). Defaults to NULL}

\item{rescale}{A logical indicating whether you want to the resulting series scaled about the largest level}
}
\description{
This function creates a data.table containing average actual & fitted performance over a specified dimension
}
\examples{

}
\keyword{ave}
