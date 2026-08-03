#Run higher-order PLS-SEM models across imputed datasets and pool results.
# Load packages ##################################################
library(tidyverse)
library(mice)
library(seminr)
library(seminrExtras)

# Scoring function ###############################################
score_items <- function(dat){
  dat$stress_._health_41_r <- 11 - dat$stress_._health_41
  dat
}

# Load imputations & score each dataset ##########################
items_imputed <- readRDS("path/to/items_imputed.rds")

scored_data <- lapply(1:20, function(i){
  score_items(complete(items_imputed, i))
})


# Define item list ###############################################
item_vars <- c(
  "magers_1","magers_2","magers_3",
  "peers_4","peers_5","peers_6",
  "confidence_7","confidence_8","confidence_9",
  "autonomy_10","autonomy_11","autonomy_12",
  "mastery_13","mastery_14","mastery_15","mastery_16",
  "purpose_17","purpose_18","purpose_19",
  "freedom_of_opinion_20","freedom_of_opinion_21","freedom_of_opinion_22",
  "quality_._frequency_23","quality_._frequency_24","quality_._frequency_25",
  "active_listening_26","active_listening_27","active_listening_28",
  "values_._ethics_29","values_._ethics_30","values_._ethics_31",
  "goals_._role_32","goals_._role_33","goals_._role_34",
  "trust_._vision_35","trust_._vision_36","trust_._vision_37","trust_._vision_38",
  "stress_._health_39","stress_._health_40",
  "diversity_._equality_42","diversity_._equality_43","diversity_._equality_44",
  "environment_45","environment_46","environment_47",
  "compensation_48","compensation_49","compensation_50",
  "recognition_51","recognition_52","recognition_53",
  "benefits_54"
)


# Measurement models #############################################
MM_HO_eNPS <- constructs(
  reflective("Managers",           multi_items("magers_", 1:3)),
  reflective("Peers",              multi_items("peers_", 4:6)),
  reflective("Confidence",         multi_items("confidence_", 7:9)),
  reflective("Autonomy",           multi_items("autonomy_", 10:12)),
  reflective("Mastery",            multi_items("mastery_", 13:16)),
  reflective("Purpose",            multi_items("purpose_", 17:19)),
  reflective("FreedomOpinion",     multi_items("freedom_of_opinion_", 20:22)),
  reflective("QualityFrequency",   multi_items("quality_._frequency_", 23:25)),
  reflective("ActiveListening",    multi_items("active_listening_", 26:28)),
  reflective("ValuesEthics",       multi_items("values_._ethics_", 29:31)),
  reflective("GoalsRole",          multi_items("goals_._role_", 32:34)),
  reflective("TrustVision",        multi_items("trust_._vision_", 35:38)),
  reflective("StressHealth",       c("stress_._health_39","stress_._health_40")),
  reflective("DiversityEquality",  multi_items("diversity_._equality_", 42:44)),
  reflective("Environment",        multi_items("environment_", 45:47)),
  reflective("Compensation",       multi_items("compensation_", 48:50)),
  reflective("Recognition",        multi_items("recognition_", 51:53)),
  reflective("Benefits",           "benefits_54"),
  higher_composite("Relationships",
                   c("Managers", "Peers", "Confidence"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Intrinsic_Motivation",
                   c("Autonomy", "Mastery", "Purpose"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Feedback",
                   c("FreedomOpinion", "QualityFrequency", "ActiveListening"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Alignment",
                   c("ValuesEthics", "GoalsRole", "TrustVision"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Wellbeing",
                   c("StressHealth", "DiversityEquality", "Environment"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Rewards",
                   c("Compensation", "Recognition", "Benefits"),
                   method  = two_stage,
                   weights = mode_A),
  reflective("eNPS", "enps_score")
)

MM_HO_Happiness <- constructs(
  reflective("Managers",           multi_items("magers_", 1:3)),
  reflective("Peers",              multi_items("peers_", 4:6)),
  reflective("Confidence",         multi_items("confidence_", 7:9)),
  reflective("Autonomy",           multi_items("autonomy_", 10:12)),
  reflective("Mastery",            multi_items("mastery_", 13:16)),
  reflective("Purpose",            multi_items("purpose_", 17:19)),
  reflective("FreedomOpinion",     multi_items("freedom_of_opinion_", 20:22)),
  reflective("QualityFrequency",   multi_items("quality_._frequency_", 23:25)),
  reflective("ActiveListening",    multi_items("active_listening_", 26:28)),
  reflective("ValuesEthics",       multi_items("values_._ethics_", 29:31)),
  reflective("GoalsRole",          multi_items("goals_._role_", 32:34)),
  reflective("TrustVision",        multi_items("trust_._vision_", 35:38)),
  reflective("StressHealth",       c("stress_._health_39","stress_._health_40")),
  reflective("DiversityEquality",  multi_items("diversity_._equality_", 42:44)),
  reflective("Environment",        multi_items("environment_", 45:47)),
  reflective("Compensation",       multi_items("compensation_", 48:50)),
  reflective("Recognition",        multi_items("recognition_", 51:53)),
  reflective("Benefits",           "benefits_54"),
  higher_composite("Relationships",
                   c("Managers", "Peers", "Confidence"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Intrinsic_Motivation",
                   c("Autonomy", "Mastery", "Purpose"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Feedback",
                   c("FreedomOpinion", "QualityFrequency", "ActiveListening"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Alignment",
                   c("ValuesEthics", "GoalsRole", "TrustVision"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Wellbeing",
                   c("StressHealth", "DiversityEquality", "Environment"),
                   method  = two_stage,
                   weights = mode_A),
  higher_composite("Rewards",
                   c("Compensation", "Recognition", "Benefits"),
                   method  = two_stage,
                   weights = mode_A),
  reflective("Happiness", "avg_happiness")
)


# Structural models #############################################
SM_HO_eNPS <- relationships(
  paths(
    from = c("Relationships", "Intrinsic_Motivation", "Feedback",
             "Alignment", "Wellbeing", "Rewards"),
    to   = "eNPS"
  )
)

SM_HO_Happiness <- relationships(
  paths(
    from = c("Relationships", "Intrinsic_Motivation", "Feedback",
             "Alignment", "Wellbeing", "Rewards"),
    to   = "Happiness"
  )
)


# Helper functions ##############################################
run_pls <- function(data, MM, SM){
  estimate_pls(
    data              = data,
    measurement_model = MM,
    structural_model  = SM,
    inner_weights     = path_weighting
  )
}

run_boot <- function(pls){
  bootstrap_model(pls, nboot = 1000, cores = 10)
}


# Run models across imputations #################################
run_models <- function(scored_list, outcome){
  
  MM <- switch(outcome,
               "eNPS"      = MM_HO_eNPS,
               "Happiness" = MM_HO_Happiness)
  
  SM <- switch(outcome,
               "eNPS"      = SM_HO_eNPS,
               "Happiness" = SM_HO_Happiness)
  
  outcome_column <- switch(outcome,
                           "eNPS"      = "enps_score",
                           "Happiness" = "avg_happiness")
  
  lapply(scored_list, function(dat){
    sem_data <- dat[, c(outcome_column, item_vars)]
    
    pls  <- run_pls(sem_data, MM, SM)
    boot <- run_boot(pls)
    
    list(pls = pls, boot = boot)
  })
}

results_eNPS      <- run_models(scored_data, "eNPS")
results_Happiness <- run_models(scored_data, "Happiness")


# Pooling helpers ###############################################
pool <- function(x) Reduce("+", x) / length(x)

extract_paths <- function(res, outcome){
  col_name <- paste0(outcome, " PLS Est.")
  lapply(res, function(x) x$boot$paths_descriptives[, col_name])
}

extract_loadings <- function(res){
  lapply(res, function(x) x$boot$loadings_descriptives)
}

extract_weights <- function(res){
  lapply(res, function(x) x$boot$weights_descriptives)
}

extract_r2 <- function(res){
  lapply(res, function(x) x$boot$rSquared["Rsq", ])
}

extract_boot_draws <- function(res_list, param, outcome){
  lapply(res_list, function(x){
    x$boot$boot_paths[param, outcome, ]
  }) |> unlist()
}

pooled_ci <- function(draws, probs = c(.025, .975)){
  quantile(draws, probs = probs, na.rm = TRUE)
}

pool_all_cis <- function(res_list, outcome){
  params <- rownames(res_list[[1]]$boot$paths_descriptives)
  
  cis <- lapply(params, function(p){
    draws <- extract_boot_draws(res_list, p, outcome)
    pooled_ci(draws)
  })
  
  names(cis) <- params
  cis
}


# Pool results ###################################################
final_results <- list(
  eNPS = list(
    paths    = pool(extract_paths(results_eNPS, "eNPS")),
    loadings = pool(extract_loadings(results_eNPS)),
    weights  = pool(extract_weights(results_eNPS)),
    r2       = pool(extract_r2(results_eNPS)),
    ci_paths = pool_all_cis(results_eNPS, "eNPS")
  ),
  Happiness = list(
    paths    = pool(extract_paths(results_Happiness, "Happiness")),
    loadings = pool(extract_loadings(results_Happiness)),
    weights  = pool(extract_weights(results_Happiness)),
    r2       = pool(extract_r2(results_Happiness)),
    ci_paths = pool_all_cis(results_Happiness, "Happiness")
  )
)

saveRDS(final_results, file = "path/to/imputed_model.rds")
