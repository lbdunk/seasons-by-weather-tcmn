# Historical weather data for the Twin Cities, Minnesota drawn from the
# Minnesota Department of Natural Resources:
# https://www.dnr.state.mn.us/climate/twin_cities/listings.html

# Script 3: Use hottest and coldest dates (calculated in Script 2) to calculate
# start dates for each season
# i.e., the days where the median temperature equals the median yearlong
# temperature will be the "equinoxes"

# Packages ---------------------------------------------------------------------
library(lubridate)
library(tidyverse)

# Trim weather dataset ---------------------------------------------------------

load("data/weather.RData")

# Make a version of the weather dataset that only includes complete years so
# that all dates are represented equally

# First date needs to be January 1
if (lubridate::month(min(weather$date)) == 1 
  & lubridate::day(min(weather$date)) == 1) {
    min_date <- min(weather$date)
  } else {
  min_year <- lubridate::year(min(weather$date) + lubridate::years(1))
  min_date <- lubridate::mdy(glue::glue("1/1/{min_year}"))
  }

# Last date needs to be December 31
if (lubridate::month(max(weather$date)) == 12 
    & lubridate::day(max(weather$date)) == 31) {
  max_date <- max(weather$date)
} else {
  max_year <- lubridate::year(max(weather$date) - lubridate::years(1))
  max_date <- lubridate::mdy(glue::glue("12/31/{max_year}"))
}
