# Metadata ----------------------------------------------------------------
# Title: D) Join and create final files
# Purpose: Combine census and electoral data at "circuito" for BA & CABA
# Author(s): @pablocal
# Date Created: 2019-09-11
#
# Comments ----------------------------------------------------------------
# This is a combination of election data and 2010 census:
# a) Electoral data: PASO 2015, Presidential 2015, PASO 2019
# b) Censo 2010: Downloaded from http://dump.jazzido.com/CNPHV2010-RADIO/
# collected by @jazzido
#
# D) Join files and clean
#
# Options and packages ----------------------------------------------------

library(tidyverse)

# D) Create final files

# D.1. Load all files and join ----------------------------------------------

censo <- read_rds("data/data_censo_radio.RDS") %>% 
  rename(id_radio = radio)
totales <- read_rds("data/data_censo_totales_radio.RDS") %>% 
  rename(id_radio = radio)
lkup <- read_rds("data/all_lookup.RDS") %>% 
  mutate(por_radio = as.double(por_radio))
elec_paso19 <- read_rds("data/PASO_2019_circuito_wide.RDS")
elec_paso15 <- read_rds("data/PASO_2015_circuito_wide.RDS")
elec_pres15 <- read_rds("data/Pres_2015_circuito_wide.RDS")
elec_pres19 <- read_rds("data/Pres_2019_circuito_wide.RDS")

## join files
joint <- reduce(list(lkup, censo, totales), left_join, by = "id_radio")

## compute circuito stats
joint_circuito <- joint %>%
  ungroup() %>% 
  mutate_at(vars(starts_with("vi"), starts_with("ho"), starts_with("per"), starts_with("TOTAL")), list(~ .*por_radio)) %>% 
  select(-por_radio, -id_radio, -id_circuito, -id_seccion_indec, -id_seccion_elec) %>% 
  group_by(id_circuito_elec) %>% 
  summarise_all(sum, na.rm = T) %>% 
  ungroup() %>% 
  mutate_at(vars(starts_with("vi"), starts_with("ho"), starts_with("per"), starts_with("TOTAL")), round, 0) %>%
  mutate_at(vars(starts_with("vi_urban_")), list(~ ./vi_urban_TOTAL*100)) %>%
  mutate_at(vars(starts_with("vi"), -starts_with("vi_urban_")), list(~ ./vi_TOTAL*100)) %>%
  mutate_at(vars(starts_with("ho")), list(~ ./ho_TOTAL*100)) %>%
  mutate_at(vars(starts_with("per")), list(~ ./per_TOTAL*100)) %>% 
  select(-ends_with("TOTAL"))

## join circuito
joint_circuito <- reduce(list(joint_circuito, elec_paso19, elec_pres19, elec_paso15, elec_pres15), 
                         left_join, by = "id_circuito_elec")

joint_circuito <- joint_circuito %>% 
  mutate_at(vars(starts_with("paso15_cand")), list(~ ./paso15_validos*100)) %>% 
  mutate_at(vars(starts_with("pres15_cand")), list(~ ./pres15_validos*100)) %>% 
  mutate_at(vars(starts_with("paso19_cand")), list(~ ./paso19_validos*100)) %>% 
  mutate_at(vars(starts_with("pres19_cand")), list(~ ./pres19_validos*100))

# D.2. Clean joint file ---------------------------------------------------

## get file with the census variables selected
varsel <- read_csv2("data/varnames.csv")

## vars to select
vars_keep <- varsel %>% 
  filter(in_file == 1) %>% 
  pull(vars)

varnames <- varsel %>% 
  filter(in_file == 1) %>% 
  pull(new_name)

## select variables and rename
joint_circuito <- joint_circuito %>% 
  select(one_of(vars_keep))%>% 
  rename_all(~ varnames) %>% 
  mutate(province = case_when(
    str_sub(id_circuito_elec, 1, 2) == "01" ~ "CABA",
    str_sub(id_circuito_elec, 1, 2) == "02" ~ "Buenos Aires"
  )) %>% 
  select(id_circuito_elec, province, everything())

## save final file
write_rds(joint_circuito, "arg_elec_censo_wide.RDS")
write_csv2(joint_circuito, "arg_elec_censo_wide.csv")
openxlsx::write.xlsx(joint_circuito, "arg_elec_censo_wide.xlsx")


