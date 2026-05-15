# Data Visualisation

There are many ways to create visualizations in R, including and beyond the plots in `base` R. While `base` R is great for simple and quick visualizations (like the distribution of genres plot we created earlier), there are other packages that are better for creating complex and customizable ones - including `ggplot2`. `ggplot2`, like `dplyr`, is included in the `tidyverse` package. 

`ggplot2` makes it simple to create complex plots from data stored in a data frame. It provides a programmatic interface for specifying what variables to plot, how they are displayed, and general visual properties. Therefore, we only need minimal changes if the underlying data change or if we decide to change from a bar plot to a scatterplot. This helps in creating publication quality plots with minimal amounts of adjustments and tweaking.

## Building plots

ggplot graphics are built step by step by adding new elements. Each chart built with `ggplot2` must include the following:

- Data
- Aesthetic mapping (aes)
    - Describes how variables are mapped onto graphical attributes
    - Visual attribute of data including x-y axes, color, fill, shape, and alpha
- Geometric objects (geom)
    - Determines how values are rendered graphically, as with bars (geom_bar), a scatterplot (geom_point), a line (geom_line), etc.

Thus, the template for graphic in  `ggplot2` is:
```R
<DATA> %>%
    ggplot(aes(<MAPPINGS>)) +
    <GEOM_FUNCTION>()
```

Using this template, let's make a ggplot plotting the relationship between age and life satisfaction. Let's use a scatterplot to visualize this relationship, using `geom_point()`. 

```R
wvs_data2 %>%
  ggplot(aes(x=age, y=life_satis))+geom_point()
```
This should produce a plot similar to this one, in the bottom right pane of your RStudio window. 

<figure markdown="span">
    ![plot](./content/age_satis_scatter.jpeg){width=800}
    <figcaption></figcaption>
</figure>

What do you think of this plot? Does it do a good job communicating the relationship between age and life satisfaction? 

## Customizing plots

`ggplot2` offers a variety of options for customization. You can add customize the transparency of the points in your plots by using a `alpha` argument in your `geom_point()` function. You can use `geom_jitter()` to include jitter in your plots. 

You can also use a `aes(color)` arugment inside the geom_function to customize the colour of your data points. For this, you can use either a set colour, or assign colours based on another variable. Let's try customizing the plot we made for age and life satisfaction by adding jitter and assigning colour based on sex. 

```R
colourful_plot <- wvs_data2 %>% 
  ggplot(aes(x=age, y=life_satis)) + geom_jitter(aes(color=sex), alpha=0.5)

#you will likely need to run a line with just the name of the plot to have it show up in the plots pane
colourful_plot
```
<figure markdown="span">
    ![plot](./content/colourful_jitter.jpeg){width=800}
    <figcaption></figcaption>
</figure>

As you see above, we can also assign plots to objects. We don't need to do this to see them, but it can be useful for keeping track of our graph, and for saving them. Use the following code to save your plot. 

```R
ggsave("./fig_output/colourful_jitterplot.png", plot=colourful_plot)
```

Feel free to play around with the colours, transparency, jitter, and style. For more on the customization options, check out the [ggplot2 documentation](https://ggplot2.tidyverse.org/reference/index.html) and the [ggplot2 cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/data-visualization.pdf).

!!!note
    You do not need to include the `plot` argument in your `ggsave()` function. If you leave it blank, it will simply save the most recent plot. 

There are other, better, options for plotting categorical data. The type of plot being produced is dtermined by the geom function - the second piece of the ggplot formula. In addition to `geom_point` and `geom_jitter`, which we have already seen, you can also use `geom_boxplot` to make box plots, or `geom_bar` to make barplots. 

**Practice.** Now, let's try making a boxplot to visualize the relationship between self-identified social class and life satisfaction. Remember that you use `geom_boxplot()` to create a boxplot. You can add colours to boxplots using the `aes(fill)` argument inside the geom_function. 

???note "Solution"
    ```R
    wvs_data2 %>%
    ggplot(aes(x=social_class, y=life_satis)) +
    geom_boxplot(aes(fill=social_class))
    ```

We can also add custom titles to our plots using different arguments within a `labs()` function, including a `title`, `subtitle` and `caption`. You can also customize the x-axis and y-axis labels within the `labs()` function by using the `x` or `y` arguments. The `labs()` function is added to the end of the ggplot formula with a `+`.

Let's modify our boxplot to make it more readable and prettier! Update the code above to include the title "Life satisfaction across social classes,' and to include the `social_class` variable as the colour fill. Finally, add the following to the end of your codeblock with a `+` to clean up the genre labels on the x-axis: `theme(axis.text.x = element_blank())`. Be sure to save your plot afterwards. 

```R
wvs_data2 %>%
    ggplot(aes(x=social_class, y=life_satis)) +
    geom_boxplot(aes(fill=social_class)) +
    labs(title="Life satisfaction across social classes", x="Social class", y="Life satisfaction") +
    theme(axis.text.x = element_blank())

ggsave("./fig_output/colourful_boxplot.png")
```

You should end up with a plot similar to this one. What does it tell us about the relationship between social class and life satisfaction? 

<figure markdown="span">
    ![plot](./content/colourful_boxplot.jpeg){width=800}
    <figcaption></figcaption>
</figure>



