# Metadata ----------------------------------------------------------------
# Title: Analysis PASO19 election
# Purpose: dataViz of PASO19 election data using 2010 census
# Author(s): @pablocal
# Date Created: 2019-09-17
#
# Comments ----------------------------------------------------------------
# 
# 
# 
#
#
# Options and packages ----------------------------------------------------
rm(list = ls())
library(tidyverse)
library(caret)

# 1. Data -----------------------------------------------------------------
df <- read_rds("arg_elec_censo_wide.RDS")


# 2. DV and prepare for plotting ------------------------------------------
df <- df %>%
  mutate(change_peron_paso19_paso15 =  paso19_cand_FdT - paso15_cand_FPV,
         change_peron_paso19_pres15 =  paso19_cand_FdT - pres15_cand_FPV,
         change_macri_paso19_paso15 = paso19_cand_JxC - paso15_cand_Cam,
         change_macri_paso19_pres15 = paso19_cand_JxC - pres15_cand_Cam,
         change_peron_paso15_pres15 = pres15_cand_FPV - paso15_cand_FPV,
         change_macri_paso15_pres15 = pres15_cand_Cam - paso15_cand_Cam
         )

colnames(df)


# 3. Quick correlation analysis -------------------------------------------

df_cor <- df %>% 
  select(-id_circuito_elec, -province) %>% 
  drop_na()

cor_mat <- cor(df_cor)

cor_long <- cor_mat %>% 
  as_tibble(rownames = "var") %>% 
  filter(str_sub(var, 1, 4) == "chan" |
           str_sub(var, 1, 10) == "paso19_can" |
           str_sub(var, 1, 10) == "paso15_can" |
           str_sub(var, 1, 10) == "pres15_can"
           ) %>% 
  gather("var_cor", "corr", 2:100) %>% 
  filter(str_sub(var_cor, 1, 4) != "chan" &
           str_sub(var_cor, 1, 6) != "paso19" &
           str_sub(var_cor, 1, 6) != "paso15" &
           str_sub(var_cor, 1, 6) != "pres15"
  ) %>% 
  mutate(corr_abs = abs(corr)) %>% 
  arrange(var, -corr_abs) 


View(cor_long)

## peronismo

cor_evol_per <- cor_long %>% 
  select(-corr_abs) %>%
  filter(var %in% c("paso19_cand_FdT", "paso15_cand_FPV")) %>% 
  spread(var, corr) %>% 
  mutate(evol15_19 = abs(paso19_cand_FdT - paso15_cand_FPV),
         abs_paso19 = abs(paso19_cand_FdT))

View(cor_evol_per)

## macri 

cor_evol_mac <- cor_long %>% 
  select(-corr_abs) %>%
  filter(var %in% c("paso19_cand_JxC", "paso15_cand_Cam")) %>% 
  spread(var, corr) %>% 
  mutate(evol15_19 = abs(paso19_cand_JxC - paso15_cand_Cam),
         abs_paso19 = abs(paso19_cand_JxC))

View(cor_evol_mac)


# 3. Quick stepwise models ------------------------------------------------

# Set seed for reproducibility
set.seed(123)

# Set up repeated k-fold cross-validation
df_paso19_cand_FdT <- df %>% 
  select(paso19_cand_FdT, starts_with("ho_"), starts_with("vi_"), starts_with("per_")) %>% 
  drop_na()

train_control <- trainControl(method = "cv", number = 10)
# Train the model
step_model_peron <- train(paso19_cand_FdT ~., data = df_paso19_cand_FdT,
                    method = "leapForward", 
                    tuneGrid = data.frame(nvmax = 1:10),
                    trControl = train_control
)
step_model_peron$results
coef(step_model_peron$finalModel, 4)


df_paso19_cand_JxC <- df %>% 
  select(paso19_cand_JxC, starts_with("ho_"), starts_with("vi_"), starts_with("per_")) %>% 
  drop_na()

step_model_macri <- train(paso19_cand_JxC ~., data = df_paso19_cand_JxC,
                          method = "leapForward", 
                          tuneGrid = data.frame(nvmax = 1:10),
                          trControl = train_control
)
step_model_macri$results
coef(step_model_macri$finalModel, 4)


df_change_peron_paso19_paso15 <- df %>% 
  select(change_peron_paso19_paso15, starts_with("ho_"), starts_with("vi_"), starts_with("per_")) %>% 
  drop_na()

step_model_change_peron_paso <- train(change_peron_paso19_paso15 ~., 
                                      data = df_change_peron_paso19_paso15,
                                      method = "leapForward", 
                                      tuneGrid = data.frame(nvmax = 1:10),
                                      trControl = train_control
)
step_model_change_peron_paso$results
coef(step_model_change_peron_paso$finalModel, 4)




df_change_macri_paso19_paso15 <- df %>% 
  select(change_macri_paso19_paso15, starts_with("ho_"), starts_with("vi_"), starts_with("per_")) %>% 
  drop_na()

step_model_change_macri_paso <- train(change_macri_paso19_paso15 ~., 
                                      data = df_change_macri_paso19_paso15,
                                      method = "leapForward", 
                                      tuneGrid = data.frame(nvmax = 1:10),
                                      trControl = train_control
)
step_model_change_macri_paso$results
coef(step_model_change_macri_paso$finalModel, 4)



