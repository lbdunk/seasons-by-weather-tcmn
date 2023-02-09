---
title: "Minneapolis Weather and Seasons Analysis"
author: Lily Dunk
date: February 9, 2023
editor_options: 
  markdown: 
    wrap: 80
output: github_document
---

## Current status

In progress!

## Background

This project is inspired by FiveThirtyEight's survey about when the four seasons
begin:
<https://fivethirtyeight.com/features/our-very-unscientific-poll-on-when-each-season-starts/>

I thought that many of the markers they suggest to start the seasons don't
really work for Minnesota, especially for winter.

For example, they suggested "When the first snow falls" or "When the first snow
sticks to the ground" as markers for the start of winter. Obviously, in
Minnesota, the first true snowfall is frequently in late October. Anyone who
remembers the Halloween Blizzard of 1991 will enthusiastically tell you about
it.

They also suggest March 1 as a start date for spring. We all know that March 1
is, for all intents and purposes, still winter. Traditionally, the Anishinaabe
(aka Ojibwe or Chippewa) in Minnesota refer to March on the lunar calendar as
"Snow Crust Moon"[^1], because the piles of snow repeatedly melt and
freeze over with ice (I assume!).

[^1]: Northern Michigan University Center for Native American Studies, "Moons of
    the Anishinaabeg":
    <https://nmu.edu/nativeamericanstudies/moons-anishinaabeg-0>

I decided to calculate the start and end of each season based on historical
weather data for the Twin Cities area - that's the metropolitan region of
Minneapolis and St. Paul, Minnesota.

## Data

Historical weather data for the Twin Cities comes from the Minnesota Department
of Natural Resources. It is publicly available here:
<https://www.dnr.state.mn.us/climate/twin_cities/listings.html>

The Excel .xlsx files are downloaded and saved in the data folder. Below is a
brief codebook:

| Column name                     | Format                                                |
|------------------------------|--------------------------------------------------|
| Date                            | YYYY-MM-DD                                            |
| Maximum Temperature degrees (F) | "M" = missing; "T" = trace amounts; otherwise numeric |
| Minimum Temperature degrees (F) | "M" = missing; "T" = trace amounts; otherwise numeric |
| Precipitation (inches)          | "M" = missing; "T" = trace amounts; otherwise numeric |
| Snow (inches)                   | "M" = missing; "T" = trace amounts; otherwise numeric |
| Snow Depth (inches)             | "M" = missing; "T" = trace amounts; otherwise numeric |

## Methods

My first method is to use the average high temperature, and compute a 7-day rolling median high temperature for each day of the year. The day of the year with the highest average temperature will represent the middle of summer, and the day of the year with the lowest average
temperature will represent the middle of winter. The fall and spring dates that match the median overall temperature will be the midpoints of fall and spring. The start and end of each
season will be calculated based on those dates.

Future possibilities include similar calculations as above, but with median snowfall. I may also adjust how "average" temperature is calculated, as a 7-day rolling median is very smooth but not very intuitive.
