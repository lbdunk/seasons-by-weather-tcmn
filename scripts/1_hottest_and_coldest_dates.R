# Historical weather data for the Twin Cities, Minnesota drawn from the
# Minnesota Department of Natural Resources:
# https://www.dnr.state.mn.us/climate/twin_cities/listings.html

# Script 2: Clean data and find average hottest and coldest dates, then display
# daily high temps in a line graph with hottest and coldest dates highlighted

# Packages ---------------------------------------------------------------------
# install.packages("tidyverse")
library(tidyverse)

# Clean data and add lag/lead dates --------------------------------------------
load("data/weather.Rdata")

weather2 <- weather |>
  dplyr::mutate(
    # Parse date into day, month, and year
    # Later we'll group by month and day
    day = lubridate::day(date),
    month = lubridate::month(date),
    year = lubridate::year(date),
    # Turn Ts (for "trace amounts") into numeric 0.01
    precip = as.numeric(stringr::str_replace(precip_T, "T", "0.01")),
    snowfall = as.numeric(stringr::str_replace(snowfall_T, "T", "0.01")),
    snow_depth = as.numeric(stringr::str_replace(
      snow_depth_T,
      "T",
      "0.01"
    )),
    # Convert date to lubridate date type
    date2 = lubridate::as_date(date)
  ) |>
  # Exclude leap day data - not enough
  dplyr::filter(
    !(month == 2 & day == 29),
    !is.na(max_temp)
  ) |>
  # Calculate lead and lag dates 1, 2, and 3 days behind/ahead
  # Will be used later for rolling averages
  dplyr::mutate(
    date2_lag = date2 - lubridate::days(1),
    date2_lag2 = date2 - lubridate::days(2),
    date2_lag3 = date2 - lubridate::days(3),
    date2_lead = date2 + lubridate::days(1),
    date2_lead2 = date2 + lubridate::days(2),
    date2_lead3 = date2 + lubridate::days(3)
  ) |>
  # Sort by date
  dplyr::arrange(date2)

# Merge in rolling temps -------------------------------------------------------

# Create datasets for 1, 2, and 3 days behind/ahead to merge rolling
# temps into main dataset
# Lag 1
weather_lag <- weather2 |>
  dplyr::select(date2, max_temp) |>
  dplyr::rename(max_temp_lag = max_temp)
# Lag 2
weather_lag2 <- weather2 |>
  dplyr::select(date2, max_temp) |>
  dplyr::rename(max_temp_lag2 = max_temp)
# Lag 3
weather_lag3 <- weather2 |>
  dplyr::select(date2, max_temp) |>
  dplyr::rename(max_temp_lag3 = max_temp)
# Lead 1
weather_lead <- weather2 |>
  dplyr::select(date2, max_temp) |>
  dplyr::rename(max_temp_lead = max_temp)
# Lead 2
weather_lead2 <- weather2 |>
  dplyr::select(date2, max_temp) |>
  dplyr::rename(max_temp_lead2 = max_temp)
# Lead 3
weather_lead3 <- weather2 |>
  dplyr::select(date2, max_temp) |>
  dplyr::rename(max_temp_lead3 = max_temp)

# Merge in lag and lead temps so that each date has high temp for 3 days before
# and 3 days after
weather3 <- weather2 |>
  dplyr::inner_join(
    y = weather_lag,
    by = dplyr::join_by(date2_lag == date2)
  ) |>
  dplyr::inner_join(
    y = weather_lag2,
    by = dplyr::join_by(date2_lag2 == date2)
  ) |>
  dplyr::inner_join(
    y = weather_lag3,
    by = dplyr::join_by(date2_lag3 == date2)
  ) |>
  dplyr::inner_join(
    y = weather_lead,
    by = dplyr::join_by(date2_lead == date2)
  ) |>
  dplyr::inner_join(
    y = weather_lead2,
    by = dplyr::join_by(date2_lead2 == date2)
  ) |>
  dplyr::inner_join(
    y = weather_lead3,
    by = dplyr::join_by(date2_lead3 == date2)
  ) |>
  # Group by month and date to calculate median rolling temp by day in the next
  # step
  dplyr::group_by(month, day)

# Calculate rolling medians ----------------------------------------------------

# Combine high temps together in a vector for 3, 5, and 7-day range
# summarize() only does this if I use a list() function outside the c(), and
# unlist it in the next step - not sure why
weather4 <- weather3 |>
  dplyr::summarize(
    max_temps_3d = list(c(
      max_temp_lag,
      max_temp,
      max_temp_lead
    )),
    max_temps_5d = list(c(
      max_temp_lag2,
      max_temp_lag,
      max_temp,
      max_temp_lead,
      max_temp_lead2
    )),
    max_temps_7d = list(c(
      max_temp_lag3,
      max_temp_lag2,
      max_temp_lag,
      max_temp,
      max_temp_lead,
      max_temp_lead2,
      max_temp_lead3
    )),
    .groups = "keep"
  ) |>
  # Take the median of each vector to get the rolling median
  dplyr::mutate(
    med_max_temps_3d = median(unlist(max_temps_3d)),
    med_max_temps_5d = median(unlist(max_temps_5d)),
    med_max_temps_7d = median(unlist(max_temps_7d)),
    fake_date = lubridate::mdy(glue::glue("{month}/{day}/2023"))
  ) |>
  ungroup()

save(weather4, file = "data/weather4.RData")

# Calculate hottest and coldest dates ------------------------------------------

# Calculate overall highest and lowest median rolling temp
min_temp_year <- min(weather4$med_max_temps_7d)
max_temp_year <- max(weather4$med_max_temps_7d)

# Find all dates that meet the max temp
max_temp_dates <- weather4 |>
  dplyr::select(fake_date, med_max_temps_7d) |>
  dplyr::filter(med_max_temps_7d == max_temp_year)

# Calculate the first and last date that meets the max temp
min_max_temp_date <- min(max_temp_dates$fake_date)
max_max_temp_date <- max(max_temp_dates$fake_date)

# Find the middle date
max_temp_interval <- lubridate::interval(min_max_temp_date, max_max_temp_date)
max_temp_date <- lubridate::date(
  min_max_temp_date +
    lubridate::seconds(lubridate::int_length(max_temp_interval) / 2)
)
save(max_temp_date, file = "data/max_temp_date.RData")
# Change to character for point label
max_temp_date_char <- lubridate::stamp("December 31",
  orders = "%B %d",
  exact = TRUE,
  quiet = TRUE
)(max_temp_date)
# Repeat with min temperature
min_temp_dates <- weather4 |>
  dplyr::select(fake_date, med_max_temps_7d) |>
  dplyr::filter(med_max_temps_7d == min_temp_year)

min_min_temp_date <- min(min_temp_dates$fake_date)
max_min_temp_date <- max(min_temp_dates$fake_date)

min_temp_interval <- lubridate::interval(min_min_temp_date, max_min_temp_date)
min_temp_date <- lubridate::date(
  min_min_temp_date +
    lubridate::seconds(lubridate::int_length(min_temp_interval) / 2)
)
save(min_temp_date, file = "data/min_temp_date.RData")
# Change to character for point label
min_temp_date_char <- lubridate::stamp("December 31",
  orders = "%B %d",
  exact = TRUE,
  quiet = TRUE
)(min_temp_date)

# Plot graph of temperatures and hottest/coldest dates -------------------------
ggplot(weather4, aes(x = fake_date, y = med_max_temps_7d)) +
  # y axis: 20 degrees to 90 degrees by 10
  scale_y_continuous(
    breaks = seq(20, 90, 10),
    minor_breaks = NULL,
    limits = c(20, 90),
    expand = c(0, 0)
  ) +
  # x axis: Jan 1 to Dec 31 by month
  scale_x_continuous(
    minor_breaks = NULL,
    expand = c(0, 0),
    labels = c(
      "Jan 1st",
      "Feb 1st",
      "Mar 1st",
      "Apr 1st",
      "May 1st",
      "Jun 1st",
      "Jul 1st",
      "Aug 1st",
      "Sep 1st",
      "Oct 1st",
      "Nov 1st",
      "Dec 1st"
    ),
    breaks = c(
      lubridate::mdy("1/1/23"),
      lubridate::mdy("2/1/23"),
      lubridate::mdy("3/1/23"),
      lubridate::mdy("4/1/23"),
      lubridate::mdy("5/1/23"),
      lubridate::mdy("6/1/23"),
      lubridate::mdy("7/1/23"),
      lubridate::mdy("8/1/23"),
      lubridate::mdy("9/1/23"),
      lubridate::mdy("10/1/23"),
      lubridate::mdy("11/1/23"),
      lubridate::mdy("12/1/23")
    )
  ) +
  # Make a line graph
  geom_line() +
  # Axis labels
  labs(x = "Date", y = "Rolling 7-day median high temperature (°F)") +
  # Max temp refline with label
  geom_hline(yintercept = max_temp_year) +
  geom_text(
    aes(
      x = lubridate::mdy("12/17/23"),
      y = max_temp_year,
      label = glue::glue("Max: {max_temp_year}°"),
      vjust = -0.5,
      hjust = 0.6
    ),
    check_overlap = TRUE
  ) +
  # Min temp refline with label
  geom_hline(yintercept = min_temp_year) +
  geom_text(
    aes(
      x = lubridate::mdy("12/17/23"),
      y = min_temp_year,
      label = glue::glue("Min: {min_temp_year}°"),
      vjust = 1.2,
      hjust = 0.6
    ),
    check_overlap = TRUE
  ) +
  # Max temp point with label
  geom_point(x = max_temp_date, y = max_temp_year) +
  geom_text(
    aes(
      x = max_temp_date,
      y = max_temp_year,
      label = max_temp_date_char,
      vjust = -0.5
    ),
    check_overlap = TRUE
  ) +
  # Min temp point with label
  geom_point(x = min_temp_date, y = min_temp_year) +
  geom_text(
    aes(
      x = min_temp_date,
      y = min_temp_year,
      label = min_temp_date_char,
      vjust = 1.2,
      hjust = 0.4
    ),
    check_overlap = TRUE
  )

# Save graph as a PNG

ggplot2::ggsave(
  filename = "Hottest and coldest dates.png",
  device = "png",
  path = "output",
  dpi = 150,
  width = 1000,
  height = 800,
  units = "px"
)
