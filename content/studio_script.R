#checking my working directory
getwd()

#setting it to be the R folder and checking to make sure it worked
setwd('./R')
getwd()

#setting up folders
dir.create('data_output')
dir.create('fig_output')
dir.create('table_output')

#We need to set our library path to the common folder that already has our packages installed. Normally you would just install the packages you needed through the terminal and not include a code line like this
.libPaths("/project/def-sponsor00/common/lib/R")

library(tidyverse)
library(broom)
library(naniar)
library(stats)

#We're going to load our data in from the shared folder 
wvs_data <- read.csv("/project/def-sponsor00/common/wvs_subset.csv")

#cleaning data - checking for missing data 
unique(wvs_data$education)

wvs_data2 <- wvs_data %>% replace_with_na(replace = list(education = "Don't know"))
unique(wvs_data2$education)

#cleaning data - creating dummy controls
wvs_data2 <- wvs_data2 %>% 
  mutate(uni_degree = case_when(
    education == "Bachelor or equivalent (ISCED 6)" ~ 1,
    education == "Master or equivalent (ISCED 7)" ~ 1,
    education == "Doctoral or equivalent (ISCED 8)" ~ 1,
    TRUE ~ 0
  ))

wvs_data2 <- wvs_data2 %>% 
  mutate(married = case_when(
    marital_status == "Living together as married" ~ 1,
    marital_status == 'Married' ~ 1, 
    TRUE ~ 0 
  ))

#testing the correlation
cor(wvs_data2$age, wvs_data2$life_satis, use='complete.obs')

#running a simple linear model
model.1 <- lm(life_satis ~ age, data=wvs_data2)
summary(model.1)

#running a linear model with controls for sex, immigrant status, education, full time employment, and marital status.
model.2 <- lm(life_satis ~ age + female + uni_degree + employed + married, data = wvs_data2)
summary(model.2)

#creating a tidy model
tidy.model <- tidy(model.2)
tidy.model

write.csv(tidy.model, "./table_output/tidy_lm_model.csv")

#save the modified data 
write.csv(wvs_data2, "./data_output/modified_wvs_subset.csv")