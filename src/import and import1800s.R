# Custom import functions to import weather data from the MN DNR website:
# https://www.dnr.state.mn.us/climate/twin_cities/listings.html

library(tidyverse)
library(janitor)

# import
# For data files 1900-onward

import <- function(filename) {
  readxl::read_xlsx(glue::glue("Data/{filename}.xlsx"),
                    na = "M", # Missing is coded as M
                    skip = 2, # First row is header, second is column names
                    # Use custom column names
                    col_names = c("date",
                                  "max_temp",
                                  "min_temp",
                                  "precip_T",
                                  "snowfall_T",
                                  "snow_depth_T"),
                    # Specify column types
                    col_types = c("date",
                                  "numeric",
                                  "numeric",
                                  "text",
                                  "text",
                                  "text"))
  # These last 3 rows contain "T" to indicate "trace" amounts of snow, so they
  # can't be imported as numeric
}

# import1800s
# Similar, but need to import Date as numeric and convert to date afterwards
# because read_xlsx will not automatically convert dates before 1900

import1800s <- function(filename) {
  readxl::read_xlsx(glue::glue("Data/{filename}.xlsx"),
                    na = "M",
                    skip = 2,
                    col_names = c("date_num",
                                  "max_temp",
                                  "min_temp",
                                  "precip_T",
                                  "snowfall_T",
                                  "snow_depth_T"),
                    col_types = c("numeric",
                                  "numeric",
                                  "numeric",
                                  "text",
                                  "text",
                                  "text")) |>
    mutate(date = janitor::excel_numeric_to_date(date_num))
}