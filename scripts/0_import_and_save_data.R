# Historical weather data for the Twin Cities, Minnesota drawn from the
# Minnesota Department of Natural Resources:
# https://www.dnr.state.mn.us/climate/twin_cities/listings.html

# Script 1: Imports the weather data, stacks it, and saves it in the Data folder
# Only need to run this file if updating weather data - otherwise the stacked
# data should be saved in the data folder

# install.packages("tidyverse")
# install.packages("janitor")
library(tidyverse)

# Functions to import weather data from the DNR files
# Separate functions for files before & after 1900s
source("src/import and import1800s.R")

# This DNR file (2010 to present) should be re-downloaded regularly because it
# updates continually with 2020s data
w2010s <- import("2010 to present")
w2000s <- import("2000s")
w1990s <- import("1990s")
w1980s <- import("1980s")
w1970s <- import("1970s")
w1960s <- import("1960s")
w1950s <- import("1950s")
w1940s <- import("1940s")
w1930s <- import("1930s")
w1920s <- import("1920s")
w1910s <- import("1910s")
w1900s <- import("1900s") |> filter(!is.na(date))
# For some reason there is data for Feb 29, 1900 even though 1900 wasn't a leap
# year. The date comes through as NA, need to delete that record.

# readxl doesn't like dates before 1900 - handle these separately
# Lots of warnings like "expecting numeric, got a date" are fine

w1890s <- import1800s("1890s")
w1880s <- import1800s("1880s")
w1870s <- import1800s("1870s")

weather <- dplyr::bind_rows(
  w2010s,
  w2000s,
  w1990s,
  w1980s,
  w1970s,
  w1960s,
  w1950s,
  w1940s,
  w1930s,
  w1920s,
  w1910s,
  w1900s,
  w1890s,
  w1880s,
  w1870s
)
save(weather, file = "Data/weather.Rdata")
