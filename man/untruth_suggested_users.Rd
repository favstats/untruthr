% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{untruth_suggested_users}
\alias{untruth_suggested_users}
\title{Get suggested users from Truth Social}
\usage{
untruth_suggested_users(
  maximum = 20,
  monitor = FALSE,
  switch_token = NULL,
  ...
)
}
\arguments{
\item{maximum}{Maximum number of suggestions to return}

\item{monitor}{If \code{TRUE}, show detailed output of the rate limit status}

\item{switch_token}{If \code{TRUE}, use the \code{switch_token} function to switch to a new token if rate limits are reached}
}
\value{
A data frame of suggested users
}
\description{
Get suggested users from Truth Social
}
