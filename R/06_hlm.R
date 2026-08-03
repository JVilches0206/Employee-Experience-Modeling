# Fit HLM for eNPS and Happiness 
# pool fixed effects
# compute ICC and R-Squared
# extract random intercepts export model outputs

# Load packages ###############################################
library(tidyverse)
library(lme4)
library(lmerTest)
library(mice)
library(performance)
library(broom.mixed)

# Import imputed dataset ######################################
items_imputed <- readRDS("path/to/items_imputed.rds")

# Helper: Construct factors and domains ########################
construct_domains <- function(data) {

  stress_._health_41_r <- 11 - data$stress_._health_41

  Managers <- rowMeans(cbind(data$magers_1, data$magers_2, data$magers_3))
  Peers <- rowMeans(cbind(data$peers_4, data$peers_5, data$peers_6))
  Confidence <- rowMeans(cbind(data$confidence_7, data$confidence_8, data$confidence_9))

  Autonomy <- rowMeans(cbind(data$autonomy_10, data$autonomy_11, data$autonomy_12))
  Mastery <- rowMeans(cbind(data$mastery_13, data$mastery_14, data$mastery_15, data$mastery_16))
  Purpose <- rowMeans(cbind(data$purpose_17, data$purpose_18, data$purpose_19))

  Freedom_Opinion <- rowMeans(cbind(data$freedom_of_opinion_20, data$freedom_of_opinion_21, data$freedom_of_opinion_22))
  Quality_Freq <- rowMeans(cbind(data$quality_._frequency_23, data$quality_._frequency_24, data$quality_._frequency_25))
  Active_Listen <- rowMeans(cbind(data$active_listening_26, data$active_listening_27, data$active_listening_28))

  Values_Ethics <- rowMeans(cbind(data$values_._ethics_29, data$values_._ethics_30, data$values_._ethics_31))
  Goals_Roles <- rowMeans(cbind(data$goals_._role_32, data$goals_._role_33, data$goals_._role_34))
  Trust_Vision <- rowMeans(cbind(data$trust_._vision_35, data$trust_._vision_36, data$trust_._vision_37, data$trust_._vision_38))

  Stress_Health <- rowMeans(cbind(data$stress_._health_39, data$stress_._health_40, stress_._health_41_r))
  Diverse_Equal <- rowMeans(cbind(data$diversity_._equality_42, data$diversity_._equality_43, data$diversity_._equality_44))
  Environment <- rowMeans(cbind(data$environment_45, data$environment_46, data$environment_47))

  Compensation <- rowMeans(cbind(data$compensation_48, data$compensation_49, data$compensation_50))
  Recognition <- rowMeans(cbind(data$recognition_51, data$recognition_52, data$recognition_53))
  Benefits <- data$benefits_54

  tibble(
    Relationships = rowMeans(cbind(Managers, Peers, Confidence)),
    Intrinsic_Motivation = rowMeans(cbind(Autonomy, Mastery, Purpose)),
    Feedback = rowMeans(cbind(Freedom_Opinion, Quality_Freq, Active_Listen)),
    Alignment = rowMeans(cbind(Values_Ethics, Goals_Roles, Trust_Vision)),
    Wellbeing = rowMeans(cbind(Stress_Health, Diverse_Equal, Environment)),
    Rewards = rowMeans(cbind(Compensation, Recognition, Benefits)),
    tenure_yrs = data$tenure_yrs,
    enps_score = data$enps_score,
    avg_happiness = data$avg_happiness,
    deleted = data$deleted,
    companyId = data$companyId
  )
}


# Construct domains for each imputed dataset ###################
domain_list <- lapply(items_imputed$analyses, construct_domains)


# Fit HLM models ###############################################
fit_eNPS <- with(items_imputed, {
  domains <- construct_domains(data)
  lmer(enps_score ~ Relationships + Intrinsic_Motivation + Feedback +
         Alignment + Wellbeing + Rewards + tenure_yrs +
         (1 | companyId), data = domains)
})

fit_happy <- with(items_imputed, {
  domains <- construct_domains(data)
  lmer(avg_happiness ~ Relationships + Intrinsic_Motivation + Feedback +
         Alignment + Wellbeing + Rewards + tenure_yrs +
         (1 | companyId), data = domains)
})

# Pool fixed effects ###########################################
eNPS_summary <- summary(pool(fit_eNPS), conf.int = TRUE)
happy_summary <- summary(pool(fit_happy), conf.int = TRUE)


# Compute R² ####################################################
eNPS_R2 <- fit_eNPS$analyses %>%
  map(performance::r2) %>%
  map_dfr(as.data.frame)

happy_R2 <- fit_happy$analyses %>%
  map(performance::r2) %>%
  map_dfr(as.data.frame)

# Extract random intercepts ####################################
extract_re <- function(model_list) {
  map_dfr(
    model_list,
    ~{
      re <- ranef(.x)$companyId
      tibble(companyId = rownames(re), random_intercept = re[,1])
    },
    .id = "imputation"
  ) %>%
    group_by(companyId) %>%
    summarise(
      mean_company_effect = mean(random_intercept),
      sd_company_effect = sd(random_intercept)
    )
}

company_effects_eNPS <- extract_re(fit_eNPS$analyses)
company_effects_happy <- extract_re(fit_happy$analyses)

# Export results ###############################################
write.csv(eNPS_summary, "Outputs/HLM/hlm_fixed_effects_eNPS.csv")
write.csv(happy_summary, "Outputs/HLM/hlm_fixed_effects_happy.csv")

write.csv(eNPS_R2, "Outputs/HLM/hlm_r2_eNPS.csv")
write.csv(happy_R2, "Outputs/HLM/hlm_r2_happy.csv")

write.csv(company_effects_eNPS, "Outputs/HLM/hlm_random_effects_eNPS.csv")
write.csv(company_effects_happy, "Outputs/HLM/hlm_random_effects_happy.csv")