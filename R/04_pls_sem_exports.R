# Export pooled PLS-SEM outputs (paths, CIs, loadings, weights, R-Sq)  

# Load packages #################################################
library(tidyverse)

# Load pooled SEM results ########################################
PLS_Outputs <- readRDS("path/to/imputed_model.rds")

# Export path coefficients + confidence intervals ################
ci_wide_eNPS <- PLS_Outputs$eNPS$ci_paths |>
  as.data.frame() |>
  tibble::rownames_to_column("CI") |>
  pivot_longer(cols = -CI, names_to = "Path", values_to = "Estimate") |>
  pivot_wider(names_from = CI, values_from = Estimate)

path_ci_eNPS <- cbind(as.data.frame(PLS_Outputs$eNPS$paths),
  			ci_wide_eNPS[, c("2.5%", "97.5%")] ) |>
  rename(Path = "PLS_Outputs$eNPS$paths",
    	`Lower 95% CI` = "2.5%",
    	`Upper 95% CI` = "97.5%")

write.csv(path_ci_eNPS,
          "Outputs/PLS_SEM/paths_ci_eNPS.csv",
          row.names = TRUE)

ci_wide_happy <- PLS_Outputs$Happiness$ci_paths |>
  as.data.frame() |>
  tibble::rownames_to_column("CI") |>
  pivot_longer(cols = -CI, names_to = "Path", values_to = "Estimate") |>
  pivot_wider(names_from = CI, values_from = Estimate)

path_ci_Happy <- cbind(as.data.frame(PLS_Outputs$Happiness$paths),
  ci_wide_happy[, c("2.5%", "97.5%")] ) |>
  rename(Path = "PLS_Outputs$Happiness$paths",
		`Lower 95%` = "2.5%",
    		`Upper 95%` = "97.5%")

write.csv(path_ci_Happy,
          "Outputs/PLS_SEM/paths_ci_Happy.csv",
          row.names = TRUE)


# Export R-squared ################################################
R2_eNPS <- as.data.frame(PLS_Outputs$eNPS$r2) |>
  rename(R2 = "PLS_Outputs$eNPS$r2")

R2_Happiness <- as.data.frame(PLS_Outputs$Happiness$r2) |>
  rename(R2 = "PLS_Outputs$Happiness$r2")

write.csv(R2_eNPS,      "Outputs/PLS_SEM/R2_eNPS.csv")
write.csv(R2_Happiness, "Outputs/PLS_SEM/R2_Happiness.csv")

# Export loadings #################################################
load_est_eNPS <- PLS_Outputs$eNPS$loadings |>
  as_tibble(rownames = "indicator") |>
  pivot_longer(-indicator, names_to = "construct", values_to = "loading_est") |>
  mutate(construct = str_remove(construct, " PLS Est\\.")) |>
  filter(loading_est != 0)

load_fixed_eNPS <- load_est_eNPS |>
  mutate(
    stat = case_when(
      str_detect(construct, "Boot Mean") ~ "mean",
      str_detect(construct, "Boot SD")   ~ "sd",
      TRUE                               ~ "est"
    ),
    construct = str_remove(construct, " Boot Mean") |>
      str_remove(" Boot SD")
  )

load_wide_eNPS <- load_fixed_eNPS |>
  pivot_wider(names_from = stat, values_from = loading_est)

write.csv(load_wide_eNPS,
          "Outputs/PLS_SEM/loadings_eNPS.csv",
          row.names = FALSE)


load_est_happy <- PLS_Outputs$Happiness$loadings |>
  as_tibble(rownames = "indicator") |>
  pivot_longer(-indicator, names_to = "construct", values_to = "loading_est") |>
  mutate(construct = str_remove(construct, " PLS Est\\.")) |>
  filter(loading_est != 0)

load_fixed_happy <- load_est_happy |>
  mutate(
    stat = case_when(
      str_detect(construct, "Boot Mean") ~ "mean",
      str_detect(construct, "Boot SD")   ~ "sd",
      TRUE                               ~ "est"
    ),
    construct = str_remove(construct, " Boot Mean") |>
      str_remove(" Boot SD")
  )

load_wide_happy <- load_fixed_happy |>
  pivot_wider(names_from = stat, values_from = loading_est)

write.csv(load_wide_happy,
          "Outputs/PLS_SEM/loadings_Happy.csv",
          row.names = FALSE)


# Export weights ##################################################
weight_est_eNPS <- PLS_Outputs$eNPS$weights |>
  as_tibble(rownames = "indicator") |>
  pivot_longer(-indicator, names_to = "construct", values_to = "Weights_est") |>
  mutate(construct = str_remove(construct, " PLS Est\\.")) |>
  filter(Weights_est != 0)

weight_fixed_eNPS <- weight_est_eNPS |>
  mutate(
    stat = case_when(
      str_detect(construct, "Boot Mean") ~ "mean",
      str_detect(construct, "Boot SD")   ~ "sd",
      TRUE                               ~ "est"
    ),
    construct = str_remove(construct, " Boot Mean") |>
      str_remove(" Boot SD")
  )

weight_wide_eNPS <- weight_fixed_eNPS |>
  pivot_wider(names_from = stat, values_from = Weights_est)

write.csv(weight_wide_eNPS,
          "Outputs/PLS_SEM/weights_eNPS.csv",
          row.names = FALSE)


weight_est_happy <- PLS_Outputs$Happiness$weights |>
  as_tibble(rownames = "indicator") |>
  pivot_longer(-indicator, names_to = "construct", values_to = "Weights_est") |>
  mutate(construct = str_remove(construct, " PLS Est\\.")) |>
  filter(Weights_est != 0)

weight_fixed_happy <- weight_est_happy |>
  mutate(
    stat = case_when(
      str_detect(construct, "Boot Mean") ~ "mean",
      str_detect(construct, "Boot SD")   ~ "sd",
      TRUE                               ~ "est"
    ),
    construct = str_remove(construct, " Boot Mean") |>
      str_remove(" Boot SD")
  )

weight_wide_happy <- weight_fixed_happy |>
  pivot_wider(names_from = stat, values_from = Weights_est)

write.csv(weight_wide_happy,
          "Outputs/PLS_SEM/weights_Happy.csv",
          row.names = FALSE)
