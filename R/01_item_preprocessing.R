# Purpose: Prepare and create the dataset used for imputation.
# Data: User-provided dataset (not included in repository)

# Load packages ###############################################
library(tidyverse)
library(tidyr)
library(stringr)
library(naniar)


# Import data ##################################################
# Replace with your local path when running
scoreVotes_clean_long <- read.csv("path/to/scoreVotes_clean_long.csv")
item_metadata <- read.csv("path/to/scoreMetadata.csv")
employees <- read.csv("path/to/employee_factor_model_v2.csv")


# Separate eNPS from other items ###############################
eNPS <- scoreVotes_clean_long %>%
  filter(question == "On a scale from 1 to 10, how likely are you to recommend *|COMPANY_NAME|* as good place to work?")

Items_Long <- scoreVotes_clean_long %>%
  filter(question != "On a scale from 1 to 10, how likely are you to recommend *|COMPANY_NAME|* as good place to work?")


# Create wide item-level dataset ###############################
Items_Wide <- Items_Long %>%
  group_by(employee_id, companyId, departmentId, questionId) %>%
  summarise(scoreVote = mean(scoreVote, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = questionId, values_from = scoreVote)


# Compute eNPS per employee ####################################
eNPS_by_employee_date <- eNPS %>%
  group_by(employee_id, date) %>%
  summarise(eNPS_score = mean(scoreVote, na.rm = TRUE), .groups = "drop")

eNPS_employee <- eNPS_by_employee_date %>%
  group_by(employee_id) %>%
  summarise(eNPS_score = mean(eNPS_score, na.rm = TRUE), .groups = "drop")


# Filter items to employees with eNPS data #####################
Items_filtered <- Items_Wide %>%
  filter(employee_id %in% eNPS_employee$employee_id)


# Count answered questions #####################################
Items_filtered <- Items_filtered %>%
  mutate(answered_questions = rowSums(!is.na(across(4:last_col()))))


# Create item lookup table #####################################
item_lookup <- item_metadata %>%
  filter(questionId != "5bfff05de6caa5000429c543") %>%   # remove problematic item
  select(questionId, factor, question) %>%
  mutate(item_name = paste0(str_to_lower(str_replace_all(factor, " ", "_")), "_", row_number()))

rename_vector <- setNames(item_lookup$item_name, item_lookup$questionId)

Items_filtered <- Items_filtered %>%
  rename(!!!rename_vector)


# Add completion metric ########################################
Items_filtered <- Items_filtered %>%
  mutate(completion = rowMeans(!is.na(across(4:last_col()))))


# Prepare employee demographic data ############################
employee_demo <- employees %>%
  select(
    employee_id,
    gender,
    age_yrs,
    tenure_yrs,
    deleted,
    avg_happiness,
    enps_score,
    Continent,
    City,
    industry
  )


# Merge items with employee demographics ########################
MICE_data <- Items_filtered %>%
  left_join(employee_demo, by = "employee_id")

MICE_data_original <- MICE_data

# Prepare MICE input dataset ####################################
MICE_input <- MICE_data %>%
  select(-employee_id) %>%
  mutate(
    companyId = factor(companyId),
    departmentId = factor(departmentId),
    gender = factor(gender),
    deleted = factor(deleted),
    Continent = factor(Continent),
    City = factor(City),
    industry = factor(industry)
  )


# Create final dataset for imputation ###########################
item_vars <- names(Items_filtered)[4:57]

mice_data <- Items_filtered %>%
  select(employee_id, companyId, departmentId, all_of(item_vars)) %>%
  left_join(
    employees %>%
      select(
        employee_id,
        gender,
        age_yrs,
        tenure_yrs,
        avg_happiness,
        enps_score,
        deleted,
        completion,
        Continent,
        City,
        industry
      ),
    by = "employee_id"
  )


# Inspect missingness ###########################################
vis_miss(mice_data)
