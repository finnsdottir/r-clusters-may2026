# Using R in the Shell

Next, we're going to run the same analysis on income and education in R but as a job on the clusters rather than in an interactive RStudio session. Running an R job requires writing two scripts: an R script with our analysis, and then a job script describing our batch job needs. 

Let's start by navigating the terminal, and making sure that we're still connected to the cluster. If your connection has timed out, reconnect with ssh. 

!!!note "R packages"
    Just like when we used RStudio, we cannot install any R packages in batch jobs on the clusters. So, any packages we will call as libraries in our script must be already installed through an interactive session, just like we did before. 

    As a quick reminder, the steps are:
    
    1. Log into the cluster with SSH
    2. Start an R session
    3. Install your required packages with `install.packages()` 
    4. Answer yes when it prompts you to save locally


Once in the cluster, navigate to the R folder, where our data is saved. 

```shell
[finnsdot94@login1 ~]$ cd R
[finnsdot94@login1 R]$
```

Call the `ls` command. We should see our `nlsc_data.csv` file, the three folders we created in R studio, and the script that we saved there. We're now going to create our new R script in this same directory. To do that, use the command `nano` to open a text editor in the terminal application. We will write our code directory in this window. 

## Coding for the cluster.

It is crucial to include checkpoints in your script when sending in jobs to a cluster. There is a certain amount of guess work in choosing the amount of memory and compute you need, and so, if you guess wrong and your jobs ends before your analyses are done, you don't want to have to repeat work, wasting valuable compute. 

We're going to build checkpoints in by (1) saving our work after every major step, (2) checking whether the file already exists before starting work. Building in these checkpoints has the added bonus of not needing to update our script every time we run it. To do this, we'll be using the `file.exists()` function from base R. We can also add print statements after the major steps that we can use to debug if needed. 

We'll need to start, like always, with loading out libraries. Afterwards, we'll check if our modified dataset is available, and, if not, we'll create it like we did in RStudio. (Feel free to copy and paste this code, rather than typing it all out in the nano text editor).

```shell 
library(tidyverse)
library(naniar)
library(ggplot2)
library(stats)
library(coefplot)
library(broom)

if (file.exists("./data_output/modified_nlsc_data.csv")){
  data <- read.csv("./data_output/modified_nlsc_data.csv")
} else {
    data <- read.csv("../nlsc_data.csv")
    data <- data %>% replace_with_na_all(condition = ~.x %in% c(-2,-4))
    data <- data %>%
        mutate(white = case_when(
        race == 1 ~ 1,
        TRUE ~ 0))
    data <- data %>%
        mutate(married = case_when(
        marital == 1 ~ 1,
        marital == 2 ~ 1,
        TRUE ~ 0))
    data <- data %>%
        mutate(rural = case_when(
        residence == 8 ~ 1,
        TRUE ~ 0))
    data <- data %>%
        mutate(child5 = case_when(
        children >= 5 ~ 1,
        TRUE ~ 0))
    write.csv(data, "./data_output/modified_nlsc_data.csv")
}

print("data cleaning complete.")
```

In the above codeblock, we start by checking if our `modified_nlsc_data.csv` file exists in the `./data_output/` folder. If it does, it gets read in to our `data` data frame. If it does not, then the program moves down to the code cleaning the data and saving it. This means that, if our data does not exist already, it will be created just like we want it, but if it does already exist, then we won't waste any time or compute re-running the data cleaning code.

Next, let's run our simple linear regression model, where we test the effect of educational attainment on income without any control variables. Let's also add a `Sys.sleep()` function to slow our script down and give us time to check it later on. 

```shell
if (! file.exists("./table_output/simple_lm.csv")){
    model.1 <- lm(income ~ highest_grade, data = data)
    tidy_model.1 <- tidy(model.1)
    write.csv(tidy_model.1, "./table_output/simple_lm.csv")
}

print("model 1 complete.")

Sys.sleep(120)
```

You'll notice that we're not using the `file.exists()` function in a slightly different way this time. This is because we don't need to read the file in if it exists. So, instead we've added a NOT operator to the function (!), so that the code block only runs if the file does not exist. 

Finally, let's run our full linear regression model (the one with the control variables) and produce a coefficient plot based on that model. 

```shell 
if (file.exists("./table_output/full_lm.csv")){
    model.2 <- read.csv("./table_output/full_lm.csv")
} else {
    model.2 <- lm(income ~ highest_grade + age + married + white + rural + child5, data=data)
    tidy_model.2 <- tidy(model.2)
    write.csv(tidy_model.2, "./table_output/full_lm.csv")
}

print("model 2 complete.")

if (! file.exists("./fig_output/shell_coefplot.png")){
    coef_plot <- coefplot(model.2, intercept = FALSE)
    ggsave("./fig_output/shell_coefplot.png", plot=coef_plot)
}

print("plot complete.")
```

Here, we check if the full model already exists, and if it does, we read it in to use it for the coefficient plot. If it does not, we run it and save it in our table output folder.

You can save your script by first pressing ++cmd+o++ (on mac) ++ctrl+o++ (on windows) (the letter, not the number), which will prompt you to give the file a name and write it out, and then ++cmd+x++ (on mac) or ++ctrl+x++ (on windows) to close the window. I've called my script `shell_script.R`. You must use the `.R` ending to indicate that this is an R script. 

Should you need to edit your script, you can call it back by running `nano` followed by the file name. 

!!!note "Important things to remember!"
    When running a job on a remote server/cluster, make sure that:

    - All your file paths are relative
    - All your data is already in the cluster
    - All your R packages are already installed
    - You have checkpoints throughout your script


