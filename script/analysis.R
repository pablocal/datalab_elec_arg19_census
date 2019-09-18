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

# 1. Data -----------------------------------------------------------------
df <- read_rds("arg_elec_censo_wide.RDS")


# 2. DV and prepare for plotting ------------------------------------------
df <- df %>%
  mutate(change_peron_paso15 =  paso19_cand_FdT - paso15_cand_FPV,
         change_peron_pres15 =  paso19_cand_FdT - pres15_cand_FPV,
         change_macri_paso15 = paso19_cand_JxC - paso15_cand_Cam,
         change_macri_pres15 = paso19_cand_JxC - pres15_cand_Cam,
         change_peron_paso15_pres15 = pres15_cand_FPV - paso15_cand_FPV,
         change_macri_paso15_pres15 = pres15_cand_Cam - paso15_cand_Cam
         )

colnames(df)

ggplot(df, aes(x = paso15_cand_Cam, y = change_macri_paso15_pres15)) +
  geom_point(alpha = .3, shape = 1)

ggplot(df, aes(x = paso15_cand_FPV, y = change_peron_paso15_pres15)) +
  geom_point(alpha = .3, shape = 1)

ggplot(df, aes(x = ho_necesidad_basica_insatisfecha, y = paso19_cand_JxC)) +
  geom_point(alpha = .3, shape = 1) +
  geom_smooth(method = "lm")

ggplot(df, aes(x = ho_fijo, y = paso15_cand_FPV)) +
  geom_point(alpha = .3, shape = 1) +
  geom_smooth(method = "lm")

ggplot(df, aes(x = per_estud_universitario, y = paso19_cand_FdT)) +
  geom_point(alpha = .3, shape = 1) +
    geom_smooth(method = "lm")



