library(tidyverse)
library(palmerpenguins)
library(ggthemes)


glimpse(penguins)
summary(penguins)

#plots a blank canvas
ggplot(data = penguins)

#plots a blank canvas with axes, but no data
#NOTE: mapping argument shall ALWAYS be got from an aes() function
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g)
       )

#plots data without color
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

#plots data, making each species  with different color
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()

#plots data, making each species  with different color and adds a smoothing line
#Here there is a smoothin line for each class
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() + 
  geom_smooth(method = "lm")

#This changes how the smoothing line appears, only one line for all data points.
# All the mapping defined in the ggplot() is set as "GLOBAL" variables and are
# passed down to the other geom_* functions. However, mapping can also be set locally
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) + 
  geom_smooth(method = "lm")


#axes can be changes through labs()
ggplot(data = penguins,
       mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) + 
  geom_smooth(method = "lm") +
  labs(title = "Body mass and flipper length",
       subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
       x = "Flipper length (mm)", y = "Body mass (g)",
       color = "Species", shape = "Species")


# 1.2.5 - Exercises
#1 - How many rows are in penguins? How many columns?
dim(penguins)

#2 - What does the bill_depth_mm variable in the penguins data frame describe? Read the help for ?penguins to find out.
?penguins
#bill_depth_mm
#a number denoting bill depth (millimeters)

#3 - Make a scatterplot of bill_depth_mm vs. bill_length_mm. That is, make a scatterplot with bill_depth_mm on the y-axis
# and bill_length_mm on the x-axis. Describe the relationship between these two variables.
ggplot(data = penguins, 
       mapping = aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
  geom_point()

#4 - What happens if you make a scatterplot of species vs. bill_depth_mm? What might be a better choice of geom?
ggplot(data = penguins,
       mapping = aes(x = species, y = bill_depth_mm)) +
  geom_point()
# best geom option
ggplot(data = penguins,
       mapping = aes(x = species, y = bill_depth_mm)) +
  geom_boxplot()

#5 - Why does the following give an error and how would you fix it?

ggplot(data = penguins) + 
geom_point()
# misses aesthetics / aes()

# 6 What does the na.rm argument do in geom_point()? What is the default value of the argument? 
# Create a scatterplot where you successfully use this argument set to TRUE.

ggplot(data = penguins, 
       mapping = aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
  geom_point(na.rm= TRUE)

# 7 - Add the following caption to the plot you made in the previous exercise: “Data come from
# the palmerpenguins package.” Hint: Take a look at the documentation for labs().

ggplot(data = penguins, 
       mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(mapping = aes(color = bill_depth_mm)) + 
  geom_smooth(method = "loess")
  


#########################################
# Arguments of a function can be passed implicitly as per below
# no "data" or "mapping" words here

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()
#or even
penguins |> ggplot(aes(x = flipper_length_mm, y = body_mass_g)) + 
                      geom_point()

#it makes the declaration more concise
ggplot(mpg, aes(x = class)) +
  geom_bar()
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point()
ggsave("mpg-plot.png")
