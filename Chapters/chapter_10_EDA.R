# EDA is an iterative cycle. You:
  
# 1 - Generate questions about your data.
# 2 - Search for answers by visualizing, transforming, and modelling your data.
# 3 - Use what you learn to refine your questions and/or generate new questions.

library(tidyverse)
library(nycflights13)

# There is no rule about which questions you should ask to guide your research.
# However, two types of questions will always be useful for making discoveries 
# within your data. You can loosely word these questions as:

# 1 - What type of variation occurs within my variables?
# 2 - What type of covariation occurs between my variables?

ggplot(diamonds, aes(x = carat)) + 
  geom_histogram(binwidth = 0.5)

smaller <- diamonds |> 
  filter(carat < 3)

ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

# This histogram suggests several interesting questions:
# - Why are there more diamonds at whole carats and common fractions of carats?
# - Why are there more diamonds slightly to the right of each peak than there 
#     are slightly to the left of each peak?

# Visualizations can also reveal clusters, which suggest that subgroups exist in
# your data. To understand the subgroups, ask:

# - How are the observations within each subgroup similar to each other?
# - How are the observations in separate clusters different from each other?
# - How can you explain or describe the clusters?
# - Why might the appearance of clusters be misleading?

ggplot(diamonds, aes(x = y)) +
  geom_histogram(binwidth = 0.5)

# There are so many observations in the common bins that the rare bins are very
# short, making it very difficult to see them (although maybe if you stare 
# intently at 0 you’ll spot something). To make it easy to see the unusual 
# values, we need to zoom to small values of the y-axis with coord_cartesian():

ggplot(diamonds, aes(x = y)) +
  geom_histogram(binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

# coord_cartesian() also has an xlim() argument for when you need to zoom into
# the x-axis. ggplot2 also has xlim() and ylim() functions that work slightly 
# differently: they throw away the data outside the limits.

unusual <- diamonds |> 
  filter(y < 3 | y > 20) |> 
  select(price, x, y, z) |> 
  arrange(y)
 
unusual

# It’s good practice to repeat your analysis with and without the outliers. 
# If they have minimal effect on the results, and you can’t figure out why 
# they’re there, it’s reasonable to omit them, and move on. However, if they 
# have a substantial effect on your results, you shouldn’t drop them without 
# justification. You’ll need to figure out what caused them (e.g., a data 
# entry error) and disclose that you removed them in your write-up.



# Handling Unusual Values -------------------------------------------------
# If you’ve encountered unusual values in your dataset, and simply want to move 
# on to the rest of your analysis, you have two options.

# 1 - Drop the entire row with the strange values:

diamonds2 <- diamonds |> 
  filter(between(y, 3, 20))
# Not recommended as there may be good data being discarded, and reduces the 
# samples quantity

diamonds2 <- diamonds |> 
  mutate(y = if_else(y < 3 | y > 20, NA, y))
# Recommended, but will required the na.rm() argument on function when 
# manipulating data. Ggplot will always ignore NA values

ggplot(diamonds2, aes(x = x, y = y)) + 
  geom_point() # implicitly removes NA with warning

ggplot(diamonds2, aes(x = x, y = y)) + 
  geom_point(na.rm = T) # no warning

nycflights13::flights |> 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) |> 
  ggplot(aes(x = sched_dep_time)) +
  geom_freqpoly(aes(color = cancelled), binwidth = 1/4)

# However this plot isn’t great because there are many more non-cancelled 
# flights than cancelled flights. In the next section we’ll explore some 
# techniques for improving this comparison.


# Covariation -------------------------------------------------------------

# If variation describes the behavior within a variable, covariation describes 
# the behavior between variables. Covariation is the tendency for the values of
# two or more variables to vary together in a related way. The best way to spot 
# covariation is to visualize the relationship between two or more variables.



# Covartion between categorical and numeric variable
ggplot(diamonds, aes(x = price)) +
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

ggplot(diamonds, aes(x = price, y = after_stat(density))) +
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_boxplot()


#plotting a box plot with a non-ordered factor
ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()

# To make the trend easier to see, we can reorder class based on 
# the median value of hwy using fct_reorder()

ggplot(mpg, aes(x = fct_reorder(class, hwy, median), y = hwy)) +
  geom_boxplot()

# For long variable names, flip the boxplot by 90º

ggplot(mpg, aes(x = hwy, y = fct_reorder(class, hwy, median))) +
  geom_boxplot()


# Covariation between 2 categorial variables

ggplot(diamonds, aes(x = cut, y = color)) +
  geom_count()


diamonds |> 
  count(color, cut) |>  
  ggplot(aes(x = color, y = cut)) +
  geom_tile(aes(fill = n))


# Covariation between 2 numerical variables: use line or scatter plot

ggplot(smaller, aes(x = carat, y = price)) +
  geom_point()

# Scatterplots become less useful as the size of your dataset grows, because 
# points begin to overplot, and pile up into areas of uniform black, making it
# hard to judge differences in the density of the data across the 2-dimensional
# space as well as making it hard to spot the trend. You’ve already seen one way
# to fix the problem: using the alpha aesthetic to add transparency.

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_point(alpha = 1 / 100)

# But using transparency can be challenging for very large datasets. Another 
# solution is to use bin. Previously you used geom_histogram() and 
# geom_freqpoly() to bin in one dimension. Now you’ll learn how to use 
# geom_bin2d() and geom_hex() to bin in two dimensions.

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_bin2d()

# install.packages("hexbin")
# library("hexbin")

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_hex()

# Another option is to bin one continuous variable so it acts like a categorical
# variable. Then you can use one of the techniques for visualizing the 
# combination of a categorical and a continuous variable that you learned 
# about. For example, you could bin carat and then for each group, display 
# a boxplot:

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_boxplot(aes(group = cut_width(carat, 0.1)))

# cut_width(x, width), as used above, divides x into bins of width width. 
# By default, boxplots look roughly the same (apart from number of outliers) 
# regardless of how many observations there are, so it’s difficult to tell 
# that each boxplot summarizes a different number of points. One way to show
# that is to make the width of the boxplot proportional to the number of points
# with varwidth = TRUE.
ggplot(smaller, aes(x = carat, y = price)) + 
  geom_boxplot(aes(group = cut_width(carat, 0.1)),
               varwidth = TRUE)


