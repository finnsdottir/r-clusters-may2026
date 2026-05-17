library(tidyverse)

#read in the original WVS data

wvs_data <- wvs_data(select(c(A_YEAR,
                              N_REGION_ISO,
                              Q47,
                              Q49,
                              Q207,
                              Q260,
                              Q261,
                              Q263,
                              Q273,
                              Q275,
                              Q279,
                              Q284,
                              Q287
                              ))

wvs_data <- wvs_data %>% 
  rename(year=A_YEAR,
         province = N_REGION_ISO,
         health = Q47,
         life_satis = Q49,
         social_media = Q207,
         sex = Q260,
         birth_year = Q261,
         immigrant = Q263,
         marital_status = Q273,
         education = Q275,
         emp_status = Q279,
         sector = Q284,
         social_class = Q287)

wvs_data <- wvs_data %>% 
  mutate(life_satis = recode(life_satis,
                             "Completely dissatisfied"=1,
                             '2'=2,
                             "3"=3,
                             "4"=4,
                             "5"=5,
                             "6"=6,
                             "7"=7,
                             "8"=8,
                             "9"=9,
                             "Completely satisfied"=10))

wvs_subset <- wvs_data[sample(nrow(wvs_data), 500), ]

write.csv(wvs_data, './Downloads/full_wvs_canada_data.csv')
write.csv(wvs_subset, './Downloads/wvs_subset.csv')




