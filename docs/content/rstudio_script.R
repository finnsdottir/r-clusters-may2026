#setting our working directory to the R folder
getwd()
setwd('R')
getwd()

#setting up folders 
dir.create('data_output')
dir.create('table_output')
dir.create('fig_output')

#loading our libraries
library(tidyverse)
library(naniar)
library(ggplot2)
library(stats)
library(coefplot)
library(broom)

#loading our data - you may need to update the file path
data <- read.csv("../nlsc_data.csv")
str(data)
head(data)

#we can replace the missing values in the income variable with NAs using the naniar package's replace_with_na function
data2 <- data %>% replace_with_na(replace = list(income = c(-2,-4)))

#We can also replace -4 with NA in our entire dataset by using replace_with_na_all and ~.x to refer to all variables
data2  <- data2  %>% replace_with_na_all(condition = ~.x == -4)

#Now, let's make a scatterplot to visually assess the relationship between education and income and save it
data2 %>%
  ggplot(aes(x=highest_grade, y=income))+geom_point()

ggsave("./fig_output/educ_inc_plot.png")

#We can find the correlation between the two variables using the cor() function
cor(data2$income, data2$highest_grade) #why doesn't this work?
cor(data2$income, data2$highest_grade, use='complete.obs') #uses casewise deletion

#Now, let's run a simple regression of income on education
#basic structre is ModelName <- lm(x ~ y, data)
model.1 <- lm(income ~ highest_grade, data=data2)
summary(model.1) #what does this tell us about the relationship between education and income?

#Now, we can add controls - once we turn them into dummy variables 
#we're going to use mutate to preserve the original variables - trying out both recodes and case_when
data2 <- data2 %>%
  mutate(white = recode(race,
                        1==1,
                        2==0,
                        3==0))

data2 <- data2 %>%
  mutate(married = recode(marital,
                          1==1,
                          2==1,
                          3==0,
                          4==0,
                          5==0, 
                          6==0))

data2 <- data2 %>%
  mutate(rural = case_when(
    residence == 8 ~ 1,
    TRUE ~ 0))

data2 <- data2 %>%
  mutate(child5 = case_when(
    children >= 5 ~ 1,
    TRUE ~ 0))

#now let's put these in the model 
model.2 <- lm(income ~ highest_grade + age + married + white + rural + child5, data=data2)
summary(model.2)

coefplot(model.2, intercept=FALSE)
#can save this one using the export function

#let's make a nice table with our results
tidy_model <- tidy(model.2)
write.csv(tidy_model, "./table_output/tidy_lm_model.csv")

#save our modified data
write.csv(data2, "./data_output/modified_nlsc_data.csv")
