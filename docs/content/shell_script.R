library(tidyverse)
library(naniar)
library(ggplot2)
library(stats)
library(coefplot)
library(broom)

#this if-else conditional code block checks whether our modified data exists, and if not it cleans and saves it.
#this is useful if our job fails sometime after the data cleaning - in that case it will allow us to pick up from where we stopped without repeating any work.

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

#we'll use the same if file.exists() block to make sure that we don't unneccessarily repeat any of our analyses.

if (! file.exists("./table_output/simple_lm.csv")){
    model.1 <- lm(income ~ highest_grade, data = data)
    tidy_model.1 <- tidy(model.1)
    write.csv(tidy_model.1, "./table_output/simple_lm.csv")
}

print("model 1 complete.")

Sys.sleep(120)

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