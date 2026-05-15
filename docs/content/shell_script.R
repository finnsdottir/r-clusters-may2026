setwd('R')

.libPaths("/project/def-sponsor00/common/lib/R")

library(tidyverse)
library(stats)
library(naniar)
library(broom)

#first checkpoint block - modifying the full data set and saving it for future use
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

if (! file.exists("./table_output/full_tidy_model.csv")){
  model <- lm(life_satis ~ age + female + uni_degree + employed + married, data = wvs_data)
  tidy.model <- tidy(model)
  write.csv(tidy.model, "./table_output/full_tidy_model.csv")
}
