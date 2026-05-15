# Analysing data in RStudio. 

For our workshop today, we'll be modelling a workflow for R analyses on HPC. We'll begin by developing and debugging our script on RStudio using a subset of the data before submitting an anlaysis of the full dataset as a batch job on the cluster through our shell. 

Begin by navigating back to your interactive RStudio session in JupyterHub in your browser. 

We're going to start by setting up our working directory, before loading in our libraries. We want to be working inside the `R` directory. To check if you're already working there, run `getwd()`. If you are not yet inside the `R` directory, you can set it by running `setwd('path/to/R')` like so: 

```R
setwd('./R')
getwd()
```
Next, you'll want to create folders for your modigied data and for the tables and figures you'll produce. This is not necessary but is part of creating a neat working space and clean workflow. 

```R
dir.create('data_output')
dir.create('fig_output')
dir.create('table_output')
```

If not all your new folders show up when you run the lines, try refreshing the `Files` pane. 

Next, our analyses will require the following packages; `tidyverse`, `stats`, `broom`, and `naniar`. For today's session, the packages we need are already downloaded in a shared directory. To direct R to that directory, you'll need to include the following line of code in your script:
```R
.libPaths("/project/def-sponsor00/common/lib/R")
```
Once you've run that, load the required packages like so:
```R
library(tidyverse)
library(broom)
library(naniar)
library(stats)
```
Now that we have our RStudio set up, we need to upload our data. The data we're using in today's session is saved in a shared directory, so we can read it in like so:

```R
wvs_data <- read.csv("/project/def-sponsor00/common/wvs_subset.csv")
```
This is the subset of data that we used in part one of the workshop, and includes the modifications (new variables created) that we made. It is a subset of 500 rows from the World Values Survey Wave 7 data on Canada. You can read more about it at the top of the [Inspecting data](./inspecting.md) page. 

We're going to use this data to continue exploring the relationship between life satisfaction and various sociodemographic facors. **Specifically, we will test the impact of age on life satisfaction, controlling for sex, education, full time employment, and marital status.** We're going to test this relations with a linear regression using the `lm()` function in the `stats` package. 

???note "Other ways to upload data"

  1. Data can be moved into the cluster using [Globus](https://docs.alliancecan.ca/wiki/Globus/en). Here's a [video explaining how](https://www.youtube.com/watch?v=0JJaFV4PEhk).
  2. You can import data directly into JupyterHub in your broswer. After launching a server, with the JupyterLab user interface, select the [upload files button](./content/upload_file_jupyter.png) and open the desired file in your finder. 
  3. Using a secure copy protocol, or `scp`. The `scp` command follows the structure `scp <file start location> <file end location>` whether you are moving data on to the remote server from your computer, or from the remote server on to your computer. When the file location is on the remote server, it must start with `<username>@<remote server address>:` and then the file location on the server. 

## Cleaning the data

Before we can run our analyses, we need to clean our data. Specifically, we need to create our dummy variable controls and properly deal with missing data. 

Remember that missing data in R should be represented by `NA`. In our current dataset, missing data is represented by strings such as 'not applicable' and 'don't know'. Before we do any more analyses, we'll need to replace those with `NA` values. To do this, we will use functions from the `naniar` package.

Let's check what missing data is labelled as in the `education` variable using the `unique()` function:

```R
unique(wvs_data$education)
```

What values would we consider to be missing data? 

Let's now replace them with `NA` using the `replace_with_na` function in `naniar`. We will need to supply the function with arguments that specify the variable to be edited and the values to be replaced. Let's also assign this modified data to a new object, in order to preserve the original data. 

```R
wvs_data2 <- wvs_data %>% replace_with_na(replace = list(education = "Don't know"))
unique(wvs_data2$education)
```
Run `unique()` again and observe what happened to the 'Don't know' values in education. 

!!!note Note
  The `naniar` package also has a function that allows us to replace a particular value with `NA` across an entire data frame:

  ```R
  data2 <- data %>% replace_with_na_all(condition = ~.x == missing)
  ```

  In this code, we use the function `replace_with_na_all` and supply it with the conditional argument replacing any variable's (represented by ~.x) specified missing value with `NA`. We then assign it into a modified data frame. 

We're now going further recode the `education` variable to create a dummy for university degree. Remember that we can do this using the `mutate` and `case_when()` or `recode` functions in `dplyr`. 

```R
wvs_data2 <- wvs_data2 %>% 
  mutate(uni_degree = case_when(
    education == "Bachelor or equivalent (ISCED 6)" ~ 1,
    education == "Master or equivalent (ISCED 7)" ~ 1,
    education == "Doctoral or equivalent (ISCED 8)" ~ 1,
    TRUE ~ 0
  ))
```
We will also need to create a dummy variable for being married (from `marital_status`). Let's treat being married and living together as married as the same in our analyses. Remember that we already created variables for `age`, `employed`, and `female` in part one of this workshop.
```R
wvs_data2 <- wvs_data2 %>% 
  mutate(married = case_when(
    marital_status == "Living together as married" ~ 1,
    marital_status == 'Married' ~ 1, 
    TRUE ~ 0 
    
  ))

```

## Testing statistical relationships

Now that our data is ready, let's start thinking about the relationship between our independent and dependet variables - that is, between age and life satisfaction. We can first run a correlation, using the `cor()` function and supplying arguments for our `x` and `y` variables, like so: 

```R
cor(wvs_data2$age, wvs_data2$life_satis)
```
This should produce a correlation coefficient of around 0.246 in your console. That represents a weak positive correlation between age and life satisfaction, meaning that older folks are slightly more satisfied with the lives than younger ones.

Luckily, our data on age and life satisfaction is complete, or else our `cor()` function would return `NA`. If we had any missing data, we would need to include the argument `use='complete.obs'` within the parantheses to tell the function to ignore incomplete cases. Remember that you can also go to the "Help" tab in RStudio to learn more about individual packages or functions. 

Taking this another step further, let's now run a linear regression of life satisfaction on age to test the statistical significant of the relationship. We do this with the `lm()` function in the `stats` package. The basic structure of a linear regression in R is `model <- lm(x ~ y, data=data)`. 

Let's run this model, assiging it to an object named `model.1`. Run the `summary()` function on the model afterwards to print the regression results to your console. 

```R
model.1 <- lm(life_satis ~ age, data=wvs_data2)
summary(model.1)
```
What do the results tell us about the relationship between age and life satisfaction? Note that now that we're using inferential methods, we can speak about the population in general, not just about our sample. 

Obviously, the relationship between these things is more complicated. So, let's try adding some control variables to see how that influences the slight, positive, relationship between age and life satisfaction. We can build on the basic linear model structure in R by adding control variables behind the independent variable with `+` signs.

```R 
model.2 <- lm(life_satis ~ age + female + uni_degree + employed + married, data = wvs_data2)
summary(model.2)
```

What does this regression tell us about the sociodemographic factors influencing life satisfaction among Canadians? 

Unfortunately, the way R naturally displays regression output is quite messy. We can produce a much nicer output using the `tidy` function from the `broom` package. Let's call `tidy` on our second model, and then save that output as a csv file to our data output folder.

```R
tidy_model <- tidy(model.2)
tidy_model

write.csv(tidy_model, "./table_output/tidy_lm_model.csv")
```
Now that we've created a script that cleans our data and runs our analyses, we'll need to modify it to work as a batch job on the cluster. But first, save your modified data and your R script. You can save your script in the browser window, and run the following to save your data:

```R
write.csv(wvs_data2, "./data_output/modified_wvs_subset.csv")
```
