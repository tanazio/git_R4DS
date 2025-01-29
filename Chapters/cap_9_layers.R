library(tidyverse)

?mpg
glimpse(mpg)


ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy, color = class)) +
  geom_point()

# These 2 other plots produce Warning as it's mapping non-ordered
# variable (class, as <char>) to alpha or size
ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy, alpha = class)) +
  geom_point()

ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy, size = class)) +
  geom_point()


# Excise 1 - scatterplot of hwy vs displ with pink filled in triangles

ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy,)) +
  geom_point(
    color = "black", 
    shape = 24, # triangle with fill
    fill = "pink")

# Excise 2 - why the plot is not blue?
# Answer: color should be set outside of the aesthetic mapping
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy, color = "blue"))


# Excise 2 - what does the stroke do?
# Answer: itchanges the outline width
ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy,)) +
  geom_point(
    color = "black", 
    shape = 24, # triangle with fill
    fill = "pink",
    stroke = 2)


# Every geom function in ggplot2 takes a mapping argument, either
# defined locally in the geom layer or globally in the ggplot() 
# layer. However, not every aesthetic works with every geom. You 
# could set the shape of a point, but you couldn’t set the “shape”
# of a line. If you try, ggplot2 will silently ignore that 
# aesthetic mapping.


# f you place mappings in a geom function, ggplot2 will treat 
# them as local mappings for the layer. It will use these mappings
# to extend or overwrite the global mappings for that layer only. 
# This makes it possible to display different aesthetics in 
# different layers.

ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(aes(color = class)) + 
  geom_smooth()

# You can use the same idea to specify different data for each 
# layer. Here, we use red points as well as open circles to 
# highlight two-seater cars. The local data argument in 
# geom_point() overrides the global data argument in ggplot() 
# for that layer only.

ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point() +
  geom_point(
    data = mpg |> filter(class == "2seater"),
    color =  "red"
  ) +
  geom_point(
    data = mpg |> filter(class == "2seater"),
    shape = "circle open", size = 3, color = "red"
    
  )


# Geoms are the fundamental building blocks of ggplot2. You can 
# completely transform the look of your plot by changing its geom, 
# and different geoms can reveal different features of your data. 
# 
# For example, the histogram and density plot below reveal that 
# the distribution of highway mileage is bimodal and right skewed 
# while the boxplot reveals two potential outliers.

ggplot(mpg, aes(x = hwy))+
  geom_histogram(binwidth = 2)

ggplot(mpg, aes(x = hwy))+
  geom_density()

ggplot(mpg, aes(x = hwy))+
  geom_boxplot()

# Note it's also possible to combine these different geoms again
ggplot(mpg, aes(x = hwy))+
  geom_density() +
  geom_boxplot(alpha = 0.4)


# ggplot2 provides more than 40 geoms but these don’t cover all 
# possible plots one could make. If you need a different geom, 
# we recommend looking into extension packages first to see if 
# someone else has already implemented it 
# (see https://exts.ggplot2.tidyverse.org/gallery/ for a sampling).

#Example, ridgeline plots
library(ggridges)

ggplot(mpg, aes(x = hwy, y = drv, fill = drv, color = drv)) + 
  geom_density_ridges(alpha = 0.5, show.legend = FALSE)

# Exercise 4

# top left chart
ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(size = 2) +
  geom_smooth(se = FALSE)

# top right chart
ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(size = 2) +
  geom_smooth(aes(group = drv), se = FALSE)

# middle left chart
ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(
    aes(color = drv), 
    size = 2
    ) +
  geom_smooth(
    aes(color = drv), 
    se = FALSE
    )

# middle right chart
ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(
    aes(color = drv), 
    size = 2
  ) +
  geom_smooth(se = FALSE)

# bottom left chart
ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(
    aes(color = drv), 
    size = 2
  ) +
  geom_smooth(
    aes(linetype = drv),
    se = FALSE
    )

# bottom right chart (THE ORDER OF GEOMS ALSO MATTER !!!)
ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(
    shape = "circle open", 
    size = 3, 
    color = "white", 
    stroke = 2
  ) +
  geom_point(
    aes(color = drv), 
    size = 2
  )


# Facets

ggplot(mpg, aes(displ, hwy))+
  geom_point()+ 
  facet_wrap(~cyl)

ggplot(mpg, aes(displ, hwy))+
  geom_point()+ 
  facet_grid(drv~cyl)


# In the first plot, with facet_grid(drv ~ .), the period means 
# “don’t facet across columns”. In the second plot, with 
# facet_grid(. ~ drv), the period means “don’t facet across rows”. 
# In general, the period means “keep everything together”.

ggplot(mpg, aes(displ, hwy))+
  geom_point()+ 
  facet_grid(drv~.)

ggplot(mpg, aes(displ, hwy))+
  geom_point()+ 
  facet_grid(.~cyl)




ggplot(diamonds, aes(x = cut, y = after_stat(prop))) + 
  geom_bar()
ggplot(diamonds, aes(x = cut, fill = color, y = after_stat(prop))) + 
  geom_bar()
ggplot(diamonds, aes(x = cut, y = after_stat(prop), group = 1)) + 
  geom_bar()

ggplot(diamonds) + 
  stat_summary(
    aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )


# POSITION ADJUSTMENTS
# There’s one more piece of magic associated with bar charts. You can color a 
# bar chart using either the color aesthetic, or, more usefully, the fill aesthetic:
ggplot(mpg, aes(x = drv, color = drv)) + 
  geom_bar()

ggplot(mpg, aes(x = drv, fill = drv)) + 
  geom_bar()


# When we do this, the classes are stacked inside the same bar
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar()

# The stacking is performed automatically using the position adjustment specified
# by the position argument. If you don’t want a stacked bar chart, you can use 
# one of three other options: "identity", "dodge" or "fill".

# position = "identity" will place each object exactly where it falls in the 
# context of the graph. This is not very useful for bars, because it overlaps 
# them. To see that overlapping we either need to make the bars slightly 
# transparent by setting alpha to a small value, or completely transparent 
# by setting fill = NA.
ggplot(mpg, aes(x = drv, fill = class)) +
  geom_bar(alpha = 1/5, position = "identity")

ggplot(mpg, aes(x = drv, colour = class)) +
  geom_bar(fill = NA, position = "identity")

# The identity position adjustment is more useful for 2d geoms, like points, 
# where it is the default.

# position = "fill" works like stacking, but makes each set of stacked bars 
# the same height. This makes it easier to compare proportions across groups.

# position = "dodge" places overlapping objects directly beside one another. 
# This makes it easier to compare individual values.

ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "fill")

ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "dodge")

# there is geom_point(position = "jitter") and geom_jitter()
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(position = "jitter")


# Coordinates -------------------------------------------------------------

bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = clarity, fill = clarity), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1)

bar + coord_flip()
bar + coord_polar()



# OVERALL FRAMWORK FOR GGPLOT2 --------------------------------------------

# The seven parameters in the template compose the grammar of graphics, a formal
# system for building plots. The grammar of graphics is based on the insight 
# that you can uniquely describe any plot as a combination of a dataset, a geom,
# a set of mappings, a stat, a position adjustment, a coordinate system, a 
# faceting scheme, and a theme.

ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(
    mapping = aes(<MAPPINGS>),
    stat = <STAT>, 
    position = <POSITION>
  ) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION>
