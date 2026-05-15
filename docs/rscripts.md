# Using R in the Shell

Next, we're going to run the same analysis of age and life satisfaction in R but as a batch job on the clusters rather than in an interactive session. We'll also be running it using the full dataset of 4108 cases, instead of our subset. 

Running an R job requires writing two scripts: an R script with our analysis, and then a job script describing our batch job needs. 

## Coding for the cluster

Before we close our interactive session, let's update our R script to be appropriate for a batch job. We need a script that will clean our data, create the control variables we need, run our full regression model, and save our output. We also need to include checkpoints at every step of the way.  

It is crucial to include checkpoints in your script when sending in jobs to a cluster. There is a certain amount of guess work in choosing the amount of memory and compute you need, and so, if you guess wrong and your jobs ends before your analyses are done, you don't want to have to repeat work, wasting valuable compute. 

We're going to build checkpoints in by (1) saving our work after every major step, (2) checking whether the file already exists before starting work. Building in these checkpoints has the added bonus of not needing to update our script every time we run it. To do this, we'll be using the `file.exists()` function from base R. We can also add print statements after the major steps that we can use to debug if needed. 

Open a new script file in your RStudio browser session. Save this one as `shell_script.R`. Let's start by setting our working directory, setting our library path and loading our libraries, just like before. Since we're not running our analyses in RStudio this time (we're just writing our script), you don't need to run your code after typing it. 

```R
setwd('R')

.libPaths("/project/def-sponsor00/common/lib/R")

library(tidyverse)
library(stats)
library(naniar)
library(broom)
```

Next step is the data cleaning and variable recoding. This part will need to be adapted slightly. The basic idea is that, if our job fails half way through, after already cleaning that data, we don't want to redo that data cleaning work. To avoid that happening, we need to include code that saves the modified data after cleaning, and also checks if the modified data exists before starting the cleaning. 

```R
if (file.exists("./data_output/modified_full_wvs_data.csv")){
  data <- read.csv("./data_output/modified_full_wvs_data.csv")
  } else {
    wvs_data <- read.csv("/project/def-sponsor00/common/full_wvs_canada_data.csv")
    wvs_data <- wvs_data %>% replace_with_na(replace = list(education = "Don't know"))
    wvs_data <- wvs_data %>% 
      mutate(uni_degree = case_when(
        education == "Bachelor or equivalent (ISCED 6)" ~ 1,
        education == "Master or equivalent (ISCED 7)" ~ 1,
        education == "Doctoral or equivalent (ISCED 8)" ~ 1,
        TRUE ~ 0))
    wvs_data <- wvs_data %>% 
      mutate(married = case_when(
        marital_status == "Living together as married" ~ 1,
        marital_status == 'Married' ~ 1, 
        TRUE ~ 0))
    write.csv(wvs_data, "./data_output/modified_full_wvs_data.csv")
  }

print("data cleaning complete.")
```
Let's go through the codeblock above, line by line:

1. We check if our modified data exists, and if it does we read it in as `wvs_data`
2. If our modified data does not exist, we read in the full dataset from the shared directory where it is stored (notice that this is not the subset we were using earlier)
3. We run the `mutate()` + `case_when()` recode functions to create our dummy variables for `uni_degree` and `married`
4. We save the modified data so that, if we need to rerun our job, this work does not need to be repeated
5. We ask it to print a checkpoint statement letting us know that this codeblock is complete

Remember - do not run the code you're writing! 

Next, we're going to run our linear regression model with controls, tidy it with the `broom` package, and save the model as a csv file. We'll also add an `if (file.exists())` function to the codeblock, but modifed with a `!` to check if the model does **not** exist. Since we don't need to read it in if it's been created already, we don't need the same if/else structure as above. We'll also include a printed checkpoint statement.

Let's also add a `Sys.sleep()` function to slow our script down and give us time to check it later on. 

```R
Sys.sleep(120)

if (! file.exists("./table_output/full_tidy_model.csv")){
  model <- lm(life_satis ~ age + female + uni_degree + employed + married, data = wvs_data)
  tidy.model <- tidy(model)
  write.csv(tidy.model, "./table_output/full_tidy_model.csv")
}

print("regression model complete.")
```

You can now save your script and close your RStudio browser window. 

## Scripting on the cluster

Next, let's navigate to the terminal, and check that we're still connected to the cluster. If your connection has timed out, reconnect with ssh, like so: 

```shell
ssh user_id@remote_system_url
```

!!!note "R packages"
    Just like when we used RStudio, we cannot install any R packages in batch jobs on the clusters. So, any packages we will call as libraries in our script must be already installed through an interactive session, just like we did before. 

    As a quick reminder, the steps are:
    
    1. Log into the cluster with SSH
    2. Start an R session
    3. Install your required packages with `install.packages()` 
    4. Answer yes when it prompts you to save locally

Once in the cluster, navigate to the R folder, and call the `ls` command. You should see your R scripts saved there, as well as the folders we created in RStudio to keep our working directory tidy. 

```shell
cd R
ls
```
While writing your script in RStudio is much easier, you can also script and edit directly in the terminal. To do that, you can use the `nano` command to open a text editor in the terminal. Typing just `nano` will open a blank text editor window, and typing `nano` followed by the file name will open that file in the text editor. So, for example, if we needed to edit our `shell_script.R` we would type:

```shell
nano shell_script.R
```

You can save any changes to your your script by first pressing ++cmd+o++ (on mac) ++ctrl+o++ (on windows) (the letter, not the number), which will prompt you to give the file a name and write it out, and then ++cmd+x++ (on mac) or ++ctrl+x++ (on windows) to close the window. If you were to fully write your R script in the terminal text editor, you would need to give it a name ending in `.R` to signal to the computer that it is, in fact, an R script (RStudio does this automatically). 

!!!note "Important things to remember!"
    When running a job on a remote server/cluster, make sure that:

    - All your file paths are relative
    - All your data is already in the cluster
    - All your R packages are already installed
    - You have checkpoints throughout your script


