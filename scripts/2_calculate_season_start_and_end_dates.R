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
load("data/weather4.RData")
load("data/max_temp_date.RData")
load("data/min_temp_date.RData")
midsummer <- max_temp_date
midwinter <- min_temp_date

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

# Find dates where daily avg matches yearly avg --------------------------------
median_temp <- median(weather$max_temp, na.rm = TRUE)
med_temp_dates <- weather4 |>
  dplyr::select(fake_date, med_max_temps_7d) |>
  dplyr::filter(med_max_temps_7d == median_temp)

# Dates between midwinter and midsummer are possible midspring dates
midspring_dates <- med_temp_dates |>
  dplyr::filter(midwinter < fake_date, fake_date < midsummer)
# Take the median of those dates
midspring <- median(midspring_dates$fake_date)

# Dates between midsummer and midwinter the next year are possible midfall dates
midfall_dates <- med_temp_dates |>
  dplyr::filter(midsummer < fake_date,
                fake_date < midwinter + lubridate::years(1))
# Take the median of those dates
midfall <- median(midfall_dates$fake_date)

# Use midpoints to find season start dates -------------------------------------

spring_interval <- lubridate::interval(midwinter, midspring)
spring_start <- midwinter + lubridate::as.duration(spring_interval) / 2