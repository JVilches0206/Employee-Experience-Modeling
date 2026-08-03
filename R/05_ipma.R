# Importance–Performance Map Analysis (IPMA) tables and plots from PLS-SEM outputs.
# Load packages 
library(tidyverse)
library(mice)
library(psych)
library(ggrepel)

# Load imputed datasets #########################################
items_imputed <- readRDS("path/to/items_imputed.rds")

long_data <- complete(items_imputed, action = "long", include = TRUE) %>%
  filter(.imp != 0)

# Identify numeric and categorical variables #####################
numeric_vars <- long_data %>%
  select(-.imp, -.id) %>%
  select(where(is.numeric)) %>%
  names()

categorical_vars <- long_data %>%
  select(-.imp, -.id) %>%
  select(where(~ !is.numeric(.))) %>%
  names()


# Mode function ##################################################
mode_value <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# Create averaged “super dataset” ###############################
super_dataset <- long_data %>%
  group_by(.id) %>%
  summarise(
    across(all_of(numeric_vars), mean),
    across(all_of(categorical_vars), mode_value),
    .groups = "drop"
  )

# Scoring function ###############################################
score_items <- function(dat){
  dat$stress_._health_41_r <- 11 - dat$stress_._health_41
  
  dat$Managers          <- rowMeans(dat[, c("magers_1","magers_2","magers_3")])
  dat$Peers             <- rowMeans(dat[, c("peers_4","peers_5","peers_6")])
  dat$Confidence        <- rowMeans(dat[, c("confidence_7","confidence_8","confidence_9")])
  dat$Autonomy          <- rowMeans(dat[, c("autonomy_10","autonomy_11","autonomy_12")])
  dat$Mastery           <- rowMeans(dat[, c("mastery_13","mastery_14","mastery_15","mastery_16")])
  dat$Purpose           <- rowMeans(dat[, c("purpose_17","purpose_18","purpose_19")])
  dat$FreedomOpinion    <- rowMeans(dat[, c("freedom_of_opinion_20","freedom_of_opinion_21","freedom_of_opinion_22")])
  dat$QualityFrequency  <- rowMeans(dat[, c("quality_._frequency_23","quality_._frequency_24","quality_._frequency_25")])
  dat$ActiveListening   <- rowMeans(dat[, c("active_listening_26","active_listening_27","active_listening_28")])
  dat$ValuesEthics      <- rowMeans(dat[, c("values_._ethics_29","values_._ethics_30","values_._ethics_31")])
  dat$GoalsRole         <- rowMeans(dat[, c("goals_._role_32","goals_._role_33","goals_._role_34")])
  dat$TrustVision       <- rowMeans(dat[, c("trust_._vision_35","trust_._vision_36","trust_._vision_37","trust_._vision_38")])
  dat$StressHealth      <- rowMeans(dat[, c("stress_._health_39","stress_._health_40","stress_._health_41_r")])
  dat$DiversityEquality <- rowMeans(dat[, c("diversity_._equality_42","diversity_._equality_43","diversity_._equality_44")])
  dat$Environment       <- rowMeans(dat[, c("environment_45","environment_46","environment_47")])
  dat$Compensation      <- rowMeans(dat[, c("compensation_48","compensation_49","compensation_50")])
  dat$Recognition       <- rowMeans(dat[, c("recognition_51","recognition_52","recognition_53")])
  dat$Benefits          <- dat$benefits_54
  
  dat$Relationships        <- rowMeans(dat[, c("Managers","Peers","Confidence")])
  dat$Intrinsic_Motivation <- rowMeans(dat[, c("Autonomy","Mastery","Purpose")])
  dat$Feedback             <- rowMeans(dat[, c("FreedomOpinion","QualityFrequency","ActiveListening")])
  dat$Alignment            <- rowMeans(dat[, c("ValuesEthics","GoalsRole","TrustVision")])
  dat$Wellbeing            <- rowMeans(dat[, c("StressHealth","DiversityEquality","Environment")])
  dat$Rewards              <- rowMeans(dat[, c("Compensation","Recognition","Benefits")])
  
  dat
}


# Score the averaged dataset ####################################
Scored_Data <- score_items(super_dataset)


# Construct descriptives ########################################
HO_Construct_Desc <- describe(
  Scored_Data[, c("Relationships","Intrinsic_Motivation","Feedback",
                  "Alignment","Wellbeing","Rewards")],
  IQR = FALSE, ranges = FALSE, skew = FALSE
)

write.csv(HO_Construct_Desc, "Outputs/construct_descriptives.csv")

# Load pooled SEM outputs #######################################
PLS_Outputs <- readRDS("path/to/imputed_model.rds")

# Build IPMA tables #############################################
paths_enps <- read.csv("Outputs/PLS_SEM/paths_ci_eNPS.csv")
paths_happy <- read.csv("Outputs/PLS_SEM/paths_ci_Happy.csv")
construct_desc <- read.csv("Outputs/construct_descriptives.csv")

importance_enps <- setNames(paths_enps$Path, paths_enps$X)
importance_happy <- setNames(paths_happy$Path, paths_happy$X)

performances <- setNames(construct_desc$mean, construct_desc$X)

common_enps <- intersect(names(importance_enps), names(performances))
common_happy <- intersect(names(importance_happy), names(performances))


# Build IPMA tables (seminr-style) ##############################
ipma_enps <- data.frame(
  Construct           = common_enps,
  Unstd_Total_Effect  = importance_enps[common_enps],
  Std_Total_Effect    = importance_enps[common_enps] / max(abs(importance_enps)),
  Performance         = performances[common_enps]
)

ipma_happy <- data.frame(
  Construct           = common_happy,
  Unstd_Total_Effect  = importance_happy[common_happy],
  Std_Total_Effect    = importance_happy[common_happy] / max(abs(importance_happy)),
  Performance         = performances[common_happy]
)


# Priority classification ########################################
ipma_enps$Priority <- ifelse(
  ipma_enps$Unstd_Total_Effect > mean(ipma_enps$Unstd_Total_Effect),
  "Important driver",
  "Low priority"
)

ipma_happy$Priority <- ifelse(
  ipma_happy$Unstd_Total_Effect > mean(ipma_happy$Unstd_Total_Effect),
  "Important driver",
  "Low priority"
)


# Standardize performance (0–100) ###############################
ipma_enps$Performance_std <- (ipma_enps$Performance - 1) / 6 * 100
ipma_happy$Performance_std <- (ipma_happy$Performance - 1) / 6 * 100


# Export IPMA tables ############################################
write.csv(ipma_enps,  "Outputs/PLS_SEM/IPMA/ipma_enps_tab.csv",  row.names = FALSE)
write.csv(ipma_happy, "Outputs/PLS_SEM/IPMA/ipma_happy_tab.csv", row.names = FALSE)


# IPMA Plots #####################################################
ggplot(ipma_enps, aes(
  x = Unstd_Total_Effect,
  y = Performance_std,
  label = Construct
)) +
  geom_point(size = 4, color = "#1B4F72") +
  geom_text_repel(size = 4.5, max.overlaps = Inf, color = "#1B2631") +
  geom_vline(xintercept = mean(ipma_enps$Unstd_Total_Effect), linetype = "dashed") +
  geom_hline(yintercept = mean(ipma_enps$Performance_std), linetype = "dashed") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Importance–Performance Map Analysis (IPMA): eNPS",
    x = "Importance (Total Effect)",
    y = "Performance (0–100 standardized)"
  )

ggsave("Outputs/PLS_SEM/IPMA/ipma_enps.png",
       units = "in", width = 10, height = 6, dpi = 300)


ggplot(ipma_happy, aes(
  x = Unstd_Total_Effect,
  y = Performance_std,
  label = Construct
)) +
  geom_point(size = 4, color = "#1B4F72") +
  geom_text_repel(size = 4.5, max.overlaps = Inf, color = "#1B2631") +
  geom_vline(xintercept = mean(ipma_happy$Unstd_Total_Effect), linetype = "dashed") +
  geom_hline(yintercept = mean(ipma_happy$Performance_std), linetype = "dashed") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Importance–Performance Map Analysis (IPMA): Happiness",
    x = "Importance (Total Effect)",
    y = "Performance (0–100 standardized)"
  )

ggsave("Outputs/PLS_SEM/IPMA/ipma_happy.png",
       units = "in", width = 10, height = 6, dpi = 300)
