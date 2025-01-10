library(nycflights13)
library(tidyverse)

summary(flights)
glimpse(flights)

class(flights)
view(flights)

# "flights" is a tibble, a special type of data frame used by
# the tidyverse to avoid some common gotchas. The most important
# difference between tibbles and data frames is the way tibbles
# print; they are designed for large datasets, so they only show
# the first few rows and only the columns that fit on one screen.

head(flights)


# DPLYR verbs (functions):
# 1 - The first argument is always a data frame.
# 2 - The subsequent arguments typically describe which columns to operate on using the variable names (without quotes).
# 3 - The output is always a new data frame.

# in order to combine several verbs, we use the pipe " |> "

flights |> 
  filter(dest == "IAH") |> 
  glimpse()


flights |> 
  filter(dest == "IAH") |> 
  group_by(year, month, day) |> 
  glimpse()

flights |> 
  filter(dest == "IAH") |>
  group_by(year, month, day) |> 
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  ) |> 
  glimpse()

# dplyr’s verbs are organized into four groups based on what 
# they operate on: rows, columns, groups, or tables.



# The most important verbs that operate on rows of a dataset
# are filter(), which changes which rows are present without
# changing their order, and arrange(), which changes the order
# of the rows without changing which are present.

# Rows : filter, arrange, distinct()

flights |> 
  filter(dep_delay > 120)

# flights that departed on january 1st
flights |> 
  filter(month == 1 & day == 1)

# flights that departed in january and february
flights |> 
  filter(month == 1 | month == 2)

#There's a useful shortcut when combining | and == : %in%
flights |> 
  filter(month %in% c(1,2))




# arrange() changes the order of the rows based on the value
# of the columns. It takes a data frame and a set of column 
# names (or more complicated expressions) to order by. If you
# provide more than one column name, each additional column
# will be used to break ties in the values of the preceding 
# columns.

flights |> 
  arrange(year, month, day, dep_time)

flights |> 
  arrange(desc(dep_delay))

# Note that the number of rows has not changed – we’re only
# arranging the data, we’re not filtering it.




# distinct() finds all the unique rows in a dataset, so technically,
# it primarily operates on the rows. Most of the time, however, 
# you’ll want the distinct combination of some variables, so 
# you can also optionally supply column names.

# Remove duplicate rows, if any
flights  |>  distinct()

# Find all unique origin and destination pairs
flights |> 
  distinct(origin, dest)

# to keep other columns when filtering for unique rows,
# you can use the .keep_all = TRUE option.
flights |> 
  distinct(origin, dest, .keep_all = TRUE)



# 3.2.5 - Exercises
# 1 - In a single pipeline for each condition, find all flights that 
# meet the condition:

# Had an arrival delay of two or more hours
flights |> 
  filter(arr_delay > 120)

# Flew to Houston (IAH or HOU)
flights |> 
  filter(dest %in% c("IAH", "HOU")) |> 
  glimpse

# Were operated by United, American, or Delta
flights |> 
  filter(carrier %in% c("UA", "AA", "DL")) |> 
  glimpse()

# Departed in summer
flights |> 
  filter(month %in% c(7, 8, 9)) |> 
  glimpse()

# Arrived more than two hours late but didn’t leave late
flights |> 
  filter(dep_delay <= 0 & arr_delay >= 120) |> 
  glimpse()

# Were delayed by at least an hour, but made up over 
# 30 minutes in flight
flights |> 
  filter(dep_delay >= 60 & arr_delay <= 30) |> 
  glimpse()




# 2 - Sort flights to find the flights with the longest departure
# delays. Find the flights that left earliest in the morning.

flights |> 
  arrange(desc(dep_delay)) |> 
  arrange(hour, minute) |> 
  glimpse()

# COLUMNS: mutate, select, rename, relocate

# The job of mutate() is to add new columns that are calculated
# from the existing columns. 


flights |>
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time*60
  )

# By default, mutate() adds new columns on the right-hand side of 
# your dataset, which makes it difficult to see what’s happening here. 
# We can use the .before argument to instead add the variables to the 
# left-hand side:

flights |>
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time*60,
    .before = 1
  )

flights |>
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time*60,
    .after = day
  )


flights |>
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time/60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )

# select() allows you to rapidly zoom in on a useful columns subset 
# using operations based on the names of the variables


flights |> 
  select(year, month, day)

flights |> 
  select(year:day)

flights |> 
  select(!year:day)

flights |> 
  select(where(is.character))
