# Purpose: impute and export datasets.
# Load packages ###############################################
library(tidyverse)
library(mice)
library(naniar)

# Import item-level dataset ####################################
# Replace with your local path when running
Items_Model <- read.csv("path/to/Items_Model.csv")

# Prepare imputation dataset ###################################
MI_data <- Items_Model %>%
  select(
    companyId,
    gender,
    age_yrs,
    tenure_yrs,
    deleted,
    avg_happiness,
    enps_score,
    autonomy_10:confidence_9
  ) %>%
  mutate(
    companyId = factor(companyId),
    gender = factor(na_if(gender, "")),
    deleted = factor(deleted)
  )


# Filter companies with sufficient sample size #################
company_counts <- MI_data %>%
  count(companyId)

MI_data <- MI_data %>%
  filter(companyId %in% company_counts$companyId[company_counts$n >= 35]) %>%
  droplevels()


# Inspect missingness ##########################################
vis_miss(MI_data)
md.pattern(MI_data)


# Initialize MICE ##############################################
init <- mice(MI_data, maxit = 0)
meth <- init$method
pred <- init$predictorMatrix


# Configure predictor matrix ###################################
# companyId should predict others but not be predicted itself
pred["companyId", ] <- 0
pred[, "companyId"] <- 1

# Configure methods ############################################
# These variables should not be imputed
meth[c(
  "companyId",
  "deleted",
  "avg_happiness",
  "enps_score"
)] <- ""

# Run multiple imputation ######################################
imp <- mice(
  MI_data,
  m = 20,
  maxit = 20,
  seed = 2026,
  method = meth,
  predictorMatrix = pred
)

plot(imp)
stripplot(imp)

# Export imputed dataset #######################################
saveRDS(imp, file = "path/to/items_imputed.rds")
