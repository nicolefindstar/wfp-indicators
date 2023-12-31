library(tidyverse)
library(labelled)
library(expss)

#import dataset
data <- read_csv("~/GitHub/RAMResourcesScripts/Static/ABI_Sample_Survey.csv")

#assign variable and value labels 
var_label(data$HHFFAPart) <- "Have you or any of your household member participated in the asset creation activities and received a food assistance transfer?"
var_label(data$HHAssetProtect) <- "Do you think that the assets that were built or rehabilitated in your community are better protecting your household, its belongings and its production capacities (fields, equipment, etc.) from floods / drought / landslides / mudslides?"
var_label(data$HHAssetProduct) <- "Do you think that the assets that were built or rehabilitated in your community have allowed your household to increase or diversify its production (agriculture / livestock / other)?"
var_label(data$HHAssetDecHardship) <- "Do you think that the assets that were built or rehabilitated in your community have decreased the day-to-day hardship and released time for any of your family members (including women and children)?"
var_label(data$HHAssetAccess) <- "Do you think that the assets that were built or rehabilitated in your community have improved the ability of any of your household member to access markets and/or basic services (water, sanitation, health, education, etc)?"
var_label(data$HHTrainingAsset) <- "Do you think that the trainings and other support provided in your community have improved your household’s ability to manage and maintain assets?"
var_label(data$HHAssetEnv) <- "Do you think that the assets that were built or rehabilitated in your community have improved your natural environment (for example more vegetal cover, water table increased, less erosion, etc.)?"
var_label(data$HHWorkAsset) <- "Do you think that the works undertaken in your community have restored your ability to access and/or use basic asset functionalities?"

data <- data %>%
  mutate(across(c(HHAssetProtect,HHAssetProduct,HHAssetDecHardship,HHAssetAccess,HHTrainingAsset,HHAssetEnv,HHWorkAsset), ~labelled(., labels = c(
    "No" = 0,
    "Yes" = 1,
    "Not applicable" = 9999
  ))))

val_lab(data$HHFFAPart) = num_lab("
             0 No
             1 Yes
")

#recode 999 to 0
data <- data %>%
  mutate(across(HHAssetProtect:HHWorkAsset, ~ dplyr::recode(.x, "0" = 0, "1" = 1, "9999" = 0)))


#sum ABI rows
data <- data %>% 
  mutate(ABIScore = rowSums(across(c(HHAssetProtect:HHWorkAsset))))

#create denominator of questions asked 
data <- data %>% mutate(ABIdenom = case_when(
  ADMIN5Name == "Community A" ~ 5,
  ADMIN5Name == "Community B" ~ 6
))

#create % ABI for each respondent
data <- data %>% mutate(ABIperc = round((ABIScore/ABIdenom)*100))

#create table comparing ABI % of participants and non-participants by village 
ABIperc_particp_ADMIN5Name <- data %>% mutate(HHFFAPart_lab = to_character(HHFFAPart)) %>% group_by(ADMIN5Name, HHFFAPart_lab) %>% summarize(ABIperc = mean(ABIperc))

#create table presenting ABI % participants vs non-particpants (average across villages)
ABIperc_particp <- data %>% mutate(HHFFAPart_lab = to_character(HHFFAPart)) %>% group_by(HHFFAPart_lab) %>% summarize(ABIperc = mean(ABIperc))

#calculate the ABI across using weight value of 2 for non-participants which accounts for sampling imbalance between nonparticipants and participants
#if ratio of participants/vs non-participants is not 2/1 then a more sophisticated method for creating weights should be used.
ABIperc_total <- ABIperc_particp %>% mutate(ABIperc_wtd = case_when(HHFFAPart_lab == "No" ~ ABIperc *2, TRUE ~ ABIperc))  %>% ungroup() %>% summarize(ABIperc_total = sum(ABIperc_wtd)/3)
  
                                            
                                            
                                            
                                         