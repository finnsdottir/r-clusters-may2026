#Basic syntax

#Assingment operators
day <- 3
month = 10

#Arithmetic operators
4+2
4/2

#Logical operators
c(TRUE,TRUE,FALSE) & c(TRUE,FALSE,FALSE) #the single & operator represents an element-wise logical AND. It will return TRUE if both corresponding elements are true.

#Vectors
chris_vector <- c('pratt','hemsworth')
chris_age_vector <- c(44,46,42,45)

length(chris_age_vector)
str(chris_age_vector)
typeof(chris_vector)

chris_vector <-c(chris_vector, "pine")
chris_vector <-c("evans",chris_vector)

name_age_vector <- c("evans", 44, "pratt", 46)

#Functions
mean(chris_age_vector) #calculating the mean chris age

#Packages - installing and loading tidyverse
install.packages('tidyverse') #notice we use quotation marks when installing, but not when loading
library(tidyverse)

#Missing data
chris_age_vector <- c(NA, chris_age_vector)
mean(chris_age_vector)

#After creating your project, check that you are in the right working directory. If not, set it to be wvs_canada_2020
getwd()
#setwd('./Documents/wvs_canada_2020')

#Set up folder for a clean working directory
dir.create('data')
dir.create('data_output')
dir.create('fig_output')
dir.create('scripts')

#Read in our World Values Survey data subset
wvs_data <- read.csv("./Downloads/wvs_subset.csv")

#Inspect the data
View(wvs_data)

names(wvs_data)

dim(wvs_data) #will return a vector with the dimensions of the table (number of rows, and number of columns)

str(wvs_data) #will return information on the structure of the object (a data frame in this case) and on the class, length, and content of each column

head(wvs_data) #will show the first six rows of the data frame
tail(wvs_data) #will show the last six rows of the data frame

#Subsetting the data
wvs_data[2,2]
wvs_data[2,1:5]
wvs_data[ ,2]
wvs_data[2,-1]

#Creating a data frame of the first 100 rows and then save it 
wvs_first100 <- wvs_data[1:100, ]
write.csv(wvs_first100, "./data_output/wvs_canada_first100.csv")

#Creating a factor for employment sector and then modifying it
emp_sector <- factor(wvs_data$sector)
levels(emp_sector)

emp_sector <- fct_recode(emp_sector, Private="Private non-profit organization")
emp_sector <- fct_recode(emp_sector, Private="Private business or industry")
levels(emp_sector)

#Creating an ordered factor
sm_news <- factor(wvs_data$social_media, 
                  ordered=TRUE,
                  levels = c("Daily","Weekly","Monthly","Less than monthly","Never"))

plot(sm_news) #plotting our ordered factor

#Selecting and filtering data
select(wvs_data, sex, birth_year, immigrant, marital_status)

select(wvs_data, sex:marital_status)

filter(wvs_data, sex=='Male')

filter(wvs_data, sex=='Male',
       birth_year>=1980)

# Practice - You should filter the data by sex and social media use for news
filter(wvs_data,
       sex=='Female',
       social_media=='Daily')

#Pipes
wvs_data %>%
  filter(sex=='Male') %>%
  select(marital_status, education)

wvs_men <- wvs_data %>%
  filter(sex=='Male') %>%
  select(marital_status, education)

#PRACTICE - Your code should look like this: 
married_data <- wvs_data %>% 
  filter(marital_status=="Married") %>% 
  select(birth_year, province, employed)

#Mutate
wvs_data %>% 
  mutate(age = (year-birth_year))

#PRACTICE 
wvs_data2 <- wvs_data %>% 
  mutate(age = (year-birth_year))

#Using mutate with recode() and case_when()

wvs_data2 <- wvs_data2 %>% 
  mutate(female = recode(sex,
                         'Male'=0,
                         'Female'=1))

wvs_data2 <- wvs_data %>%
  mutate(employed = case_when(
    emp_status == 'Full time (30 hours a week or more)' ~ 1,
    TRUE ~ 0 
  ))

#Split-apply-combine
wvs_data2 %>%
  group_by(marital_status) %>%
  summarize(mean_satisfaction = mean(life_satis))%>%
  ungroup()

wvs_data2 %>%
  group_by(marital_status) %>%
  summarize(mean_satisfaction = mean(life_satis))%>%
  arrange(mean_satisfaction)%>%
  ungroup()

#PRACTICE - use arrange(desc()) and save the object
ave_life_satis <- wvs_data2 %>%
  group_by(marital_status) %>%
  summarize(mean_satisfaction = mean(life_satis))%>%
  arrange(desc(mean_satisfaction))%>%
  ungroup()

#Counting

wvs_data2 %>% 
  count(education)

wvs_data2 %>% 
  count(education, sort=TRUE)


