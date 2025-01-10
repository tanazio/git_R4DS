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

# There are a number of helper functions you can use within select():
  
# starts_with("abc"): matches names that begin with “abc”.
# ends_with("xyz"): matches names that end with “xyz”.
# contains("ijk"): matches names that contain “ijk”.
# num_range("x", 1:3): matches x1, x2 and x3.

# You can rename variables as you select() them by using =. The new 
# name appears on the left-hand side of the =, and the old variable 
# appears on the right-hand side:'

flights |> 
  select(tail_num = tailnum)


# rename() keep all the existing variables and rename a few columns at once.
# better to use instead on selct() for multiple columns
  
flights |> 
  rename(tail_num = tailnum)

# similar to the previous verb, relocate() keep all the existing variables
# and relocate a few columns at once.
# Default setting will send columns to the left of the tibble, but it is 
# possible to use .after and .before arguments, just like in mutate()

flights |> 
  relocate()


# So far we learned about functions that work with rows and columns. 
# dplyr gets even more powerful when you add in the ability to work with 
# groups. In this section, we’ll focus on the most important functions: 
# group_by(), summarize(), and the slice family of functions.


# group_by() doesn’t change the data but, if you look closely at the 
# output, you’ll notice that the output indicates that it is “grouped by”
# month (Groups: month [12]). This means subsequent operations will now 
# work “by month”. group_by() adds this grouped feature (referred to as 
# class) to the data frame, which changes the behavior of the subsequent
# verbs applied to the data.
flights |> 
  group_by(month)


# The most important grouped operation is a summary, which, if being used
# to calculate a single summary statistic, reduces the data frame to have
# a single row for each group. In dplyr, this operation is performed by 
# summarize(), as shown by the following example, which computes the 
# average departure delay by month:

flights |> 
  group_by(month) |> 
  summarize()

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

# We can create any number of summaries in a single call to summarize(). 
# We’ll learn various useful summaries in the upcoming chapters, but one 
# very useful summary is n(), which returns the number of rows in each 
# group:

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  )


# There are five handy functions that allow you to extract specific rows 
# within each group:
  
# df |> slice_head(n = 1) takes the first row from each group.
# df |> slice_tail(n = 1) takes the last row in each group.
# df |> slice_min(x, n = 1) takes the row with the smallest value of column x.
# df |> slice_max(x, n = 1) takes the row with the largest value of column x.
# df |> slice_sample(n = 1) takes one random row.

# You can vary n to select more than one row, or instead of n =, you can 
# use prop = 0.1 to select (e.g.) 10% of the rows in each group. For 
# example, the following code finds the flights that are most delayed 
# upon arrival at each destination:





