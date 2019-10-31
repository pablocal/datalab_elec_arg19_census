# Metadata ----------------------------------------------------------------
# Title: C) Create geographical lookup
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
# C) Geographical lookup
#
# Options and packages ----------------------------------------------------
library(sf)
source("source/source.R")

# C) Create lookups to match census "radios" and electoral "circuitos"

# C.1. Generate map lookup to compute stats for circuitos ------------------
files_census <- list.dirs("data/censo/") # shapes census 
files_census <- files_census[2:3] 
files_circuitos <- list.dirs("data/circuitos/")[2:3] # shapes electoral

intersec_list <- map2(files_census, files_circuitos, intersect_polygons) 
censo_elec_lookup <- reduce(intersec_list, bind_rows) %>% 
  filter(por_radio > .001) # clean empty por_radio

write_rds(censo_elec_lookup, "data/censo_elec_lookup.RDS")

# C.2. Generate lookup of electoral sections ----------------------------------
elec_lookup <- map(.x = files_circuitos, 
                   ~gen_geo_lookup(map1 = "data/paso2015/establecimientos.geojson", 
                                   map2 = .x)
)  

lookup_elec_indec <- reduce(elec_lookup, bind_rows)

lookup_elec_indec <- lookup_elec_indec %>%
  group_by(id_seccion_elec) %>%
  mutate(count_id_elec = n(), max_count = max(count)) %>%
  filter(count_id_elec == 1 | count_id_elec > 1 & max_count == count) %>%
  select(starts_with("id")) %>% 
  filter(id_seccion_elec != "16001") 

write_rds(lookup_elec_indec, "data/elec_indec_lookup.RDS")

# C.3. Create lookup file ---------------------------------------------------
# only for the circuito PASO 19
rm(list = ls())

lookup_censo <- read_rds("data/censo_elec_lookup.RDS")
lookup_elec_indec <- read_rds("data/elec_indec_lookup.RDS")
elec_paso19 <- read_rds("data/PASO_2019_circuito_wide.RDS") 

lookup_all <- lookup_censo %>% 
  mutate(id_seccion_indec = str_sub(id_circuito, 1, 5)) %>% 
  left_join(lookup_elec_indec, by = "id_seccion_indec") %>% 
  mutate(id_circuito_elec = paste0(id_seccion_elec, str_sub(id_circuito, 6, 11))) %>% 
  left_join(elec_paso19, by = "id_circuito_elec") %>% 
  filter(!is.na(paso19_blanco)) %>% 
  select(-starts_with("paso19"))

write_rds(lookup_all, "data/all_lookup.RDS")

