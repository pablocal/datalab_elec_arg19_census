# Metadata ----------------------------------------------------------------
# Title: Argentina PASO19 elections with census (BA and CABA)
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
# A) Electoral data
# B) Census data
# C) Geographical lookup
# D) Join files and clean
#
# Options and packages ----------------------------------------------------
rm(list = ls())

library(tidyverse)

# -------------------------------------------------------------------------

# A) Prepare electoral data: PASO19, PASO15, PRES15

# A.1. Create a PASO 2019 file -----------------------------------------

## Load the files (source: https://www.resultados2019.gob.ar/)
paso19_cand_id <- read_delim("data/paso2019/descripcion_postulaciones.dsv", delim = "|") %>% 
  rename_all(str_to_lower) # cadidate labels
paso19_reg_id <- read_delim("data/paso2019/descripcion_regiones.dsv", delim = "|") %>% 
  rename_all(str_to_lower) # region labels
paso19_totals <- read_delim("data/paso2019/mesas_totales.dsv", delim = "|") %>% 
  rename_all(str_to_lower) # electoral totals
paso19_cand <- read_delim("data/paso2019/mesas_totales_agrp_politica.dsv", delim = "|") %>% 
  rename_all(str_to_lower) # electoral votes to candidates

## Get blank votes to compute valid and percentages
paso19_totals_pres_blank <- paso19_totals %>% 
  filter(codigo_categoria == "000100000000000",
         contador == "VB") %>% 
  select(codigo_mesa, valor) %>% 
  rename(votos_blanco = valor)

## Prepare regional identifiers
paso19_reg_id <- paso19_reg_id %>% 
  mutate(codigo_distrito = codigo_region,
         codigo_seccion = codigo_region,
         codigo_circuito = codigo_region) %>% 
  rename(name = nombre_region)

## Select party names
paso19_cand_id <-  paso19_cand_id %>% 
  filter(codigo_categoria == "000100000000000") %>% 
  group_by(codigo_agrupacion) %>%
  summarise(nombre_agrupacion = first(nombre_agrupacion))

## Votes to candidature to compute total valids
paso19_cand_pres <- paso19_cand %>% 
  filter(codigo_categoria == "000100000000000") %>% 
  group_by(codigo_mesa) %>% 
  mutate(votos_candidatura = sum(votos_agrupacion)) %>%
  ungroup() 

## join files 
paso19_mesa <- paso19_cand_pres %>% 
  left_join(paso19_totals_pres_blank, by = "codigo_mesa") %>% 
  mutate(votos_validos = votos_candidatura + votos_blanco) %>%
  left_join(select(paso19_reg_id, codigo_distrito, name), by = "codigo_distrito") %>% 
  rename(name_distrito = name) %>% 
  left_join(select(paso19_reg_id, codigo_seccion, name), by = "codigo_seccion") %>% 
  rename(name_seccion = name) %>%
  left_join(paso19_cand_id, by = "codigo_agrupacion") %>% 
  select(codigo_distrito, name_distrito, codigo_seccion, name_seccion, codigo_circuito, 
         codigo_mesa, votos_blanco, votos_validos, codigo_agrupacion, nombre_agrupacion, votos_agrupacion)

## summarise file at circuito level
paso19_circuito_long <- paso19_mesa %>%
  filter(codigo_distrito %in% c("01", "02")) %>% 
  mutate(partido = recode(nombre_agrupacion, "JUNTOS POR EL CAMBIO" = "Juntos por el Cambio",
                          "FRENTE DE TODOS" = "Frente de Todos",
                          .default = "Otros")) %>% 
  group_by(codigo_circuito, partido, nombre_agrupacion) %>% 
  summarise(votos_blanco = sum(votos_blanco), votos_validos = sum(votos_validos), 
              votos_candidatura = sum(votos_agrupacion)) %>% 
  group_by(codigo_circuito, partido) %>% 
  summarise(votos_blanco = first(votos_blanco), votos_validos = first(votos_validos), 
            votos_candidatura = sum(votos_candidatura)) %>%
  rename(id_circuito_elec = codigo_circuito) %>% 
  mutate(year = 2019) %>% 
  select(year, id_circuito_elec, everything())

## to wide format
paso19_circuito_wide <- spread(paso19_circuito_long, key = partido, value = votos_candidatura) %>% 
  rename(paso19_cand_FdT = `Frente de Todos`,
         paso19_cand_JxC = `Juntos por el Cambio`,
         paso19_cand_Otros = Otros,
         paso19_blanco = votos_blanco,  
         paso19_validos = votos_validos) %>% 
  select(-year)

## save file  
write_rds(paso19_circuito_long, "data/PASO_2019_circuito_long.RDS")
write_rds(paso19_circuito_wide, "data/PASO_2019_circuito_wide.RDS")

# A.2. Create a PASO 2015 file -----------------------------------------

paso15_cand_id <- read_csv2("data/paso2015/codigosbasicospaso2015provisional/FPARTIDOS.csv") %>% 
  rename_all(str_to_lower)
paso15_cand_caba <- read_csv2("data/paso2015/presidentepaso2015provisional/FMESPR_0101.csv") %>% 
  rename_all(str_to_lower)
paso15_cand_ba <- read_csv2("data/paso2015/presidentepaso2015provisional/FMESPR_0202.csv") %>% 
  rename_all(str_to_lower)

paso15_cand <- bind_rows(paso15_cand_ba, paso15_cand_caba)

## get blank votes
paso15_blanks <- paso15_cand %>% 
  filter(`codigo votos` == 9004) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`) %>%
  summarise(blancos = sum(as.integer(votos))) 

## get valid votes
paso15_sum_votes <- paso15_cand %>% 
  filter(`codigo votos` < 9000) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`) %>%
  summarise(candidaturas = sum(as.integer(votos)))

paso15_valid <- left_join(paso15_sum_votes, paso15_blanks, 
                          by = c("codigo provincia", "codigo departamento", "codigo circuito"))

## get cand votes
paso15_cand_id <- paso15_cand_id %>% 
  mutate(`codigo votos` = as.numeric(codigo_partido)) %>% 
  select(-codigo_partido, -lista_interna, -agrupacion)

paso15_votes <- paso15_cand %>% 
  filter(`codigo votos` < 9000) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`, `codigo votos`) %>%
  summarise(candidatura = sum(as.integer(votos))) %>% 
  left_join(paso15_cand_id, by = "codigo votos") %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`, denominacion) %>%
  summarise(candidatura = sum(candidatura)) %>% 
  mutate(denominacion = recode(denominacion,
                          "ALIANZA CAMBIEMOS" = "Cambiemos",
                          "ALIANZA FRENTE PARA LA VICTORIA" = "Frente Para la Victoria" ,
                          "ALIANZA UNIDOS POR UNA NUEVA ALTERNATIVA (UNA)" =  "UNA",	
                          .default = "Otros")) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`, denominacion) %>%
  summarise(candidatura = sum(candidatura)) %>% 
  rename(partido = denominacion,
         votos_candidatura = candidatura) %>% 
  ungroup()

## join files semi-long
paso15_circuito_long <- paso15_votes %>%
  left_join(paso15_valid, by = c("codigo provincia", "codigo departamento", "codigo circuito")) %>% 
  mutate(year = 2015,
         ln_circuito = str_length(`codigo circuito`),
         zeroes = case_when(
           ln_circuito == 2 ~ "0000",
           ln_circuito == 3 ~ "000",
           ln_circuito == 4 ~ "00",
           ln_circuito == 5 ~ "0",
           ln_circuito == 6 ~ ""
         ),
         id_circuito_elec = paste0(`codigo provincia`, `codigo departamento`, zeroes, `codigo circuito`),
         votos_validos = blancos + candidaturas) %>% 
  rename(votos_blanco = blancos) %>% 
  select(year, id_circuito_elec, partido, votos_blanco, votos_validos, votos_candidatura)

## join files wide
paso15_circuito_wide <- spread(paso15_circuito_long, key = partido, value = votos_candidatura) %>% 
  rename(paso15_cand_FPV = `Frente Para la Victoria`,
         paso15_cand_Cam = Cambiemos,
         paso15_cand_UNA = UNA,
         paso15_cand_Otros = Otros,
         paso15_blanco = votos_blanco,  
         paso15_validos = votos_validos) %>% 
  select(-year)

## join files wide
write_rds(paso15_circuito_long, "data/PASO_2015_circuito_long.RDS")
write_rds(paso15_circuito_wide, "data/PASO_2015_circuito_wide.RDS")

# A.3. Create a presi 2015 file -----------------------------------------

pres15_cand_id <- read_csv2("data/paso2015/codigosbasicospaso2015provisional/FPARTIDOS.csv") %>% 
  rename_all(str_to_lower)
pres15_cand_caba <- read_csv2("data/pres2015/FMESPR_0101.csv") %>% 
  rename_all(str_to_lower)
pres15_cand_ba <- read_csv2("data/pres2015/FMESPR_0202.csv") %>% 
  rename_all(str_to_lower)

pres15_cand <- bind_rows(pres15_cand_ba, pres15_cand_caba)

## get blank votes
pres15_blanks <- pres15_cand %>% 
  filter(`codigo votos` == 9004) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`) %>%
  summarise(blancos = sum(as.integer(votos))) 

## get valid votes
pres15_sum_votes <- pres15_cand %>% 
  filter(`codigo votos` < 9000) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`) %>%
  summarise(candidaturas = sum(as.integer(votos)))

pres15_valid <- left_join(pres15_sum_votes, pres15_blanks, by = c("codigo provincia", "codigo departamento", "codigo circuito"))

## get cand votes
pres15_cand_id <- pres15_cand_id %>% 
  mutate(`codigo votos` = as.numeric(codigo_partido)) %>% 
  select(-codigo_partido, -lista_interna, -agrupacion)

pres15_votes <- pres15_cand %>% 
  filter(`codigo votos` < 9000) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`, `codigo votos`) %>%
  summarise(candidatura = sum(as.integer(votos))) %>% 
  mutate(`codigo votos` = as.numeric(`codigo votos`)) %>% 
  left_join(pres15_cand_id, by = "codigo votos") %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`, denominacion) %>%
  summarise(candidatura = sum(candidatura)) %>% 
  mutate(denominacion = recode(denominacion,
                               "ALIANZA CAMBIEMOS" = "Cambiemos",
                               "ALIANZA FRENTE PARA LA VICTORIA" = "Frente Para la Victoria" ,
                               "ALIANZA UNIDOS POR UNA NUEVA ALTERNATIVA (UNA)" =  "UNA",	
                               .default = "Otros")) %>% 
  group_by(`codigo provincia`, `codigo departamento`, `codigo circuito`, denominacion) %>%
  summarise(candidatura = sum(candidatura)) %>% 
  rename(partido = denominacion,
         votos_candidatura = candidatura) %>% 
  ungroup()

## join files semi-long
pres15_circuito_long <- pres15_votes %>%
  left_join(pres15_valid, by = c("codigo provincia", "codigo departamento", "codigo circuito")) %>% 
  mutate(year = 2015,
         ln_circuito = str_length(`codigo circuito`),
         zeroes = case_when(
           ln_circuito == 2 ~ "0000",
           ln_circuito == 3 ~ "000",
           ln_circuito == 4 ~ "00",
           ln_circuito == 5 ~ "0",
           ln_circuito == 6 ~ ""
         ),
         id_circuito_elec = paste0(`codigo provincia`, `codigo departamento`, zeroes, `codigo circuito`),
         votos_validos = blancos + candidaturas) %>% 
  rename(votos_blanco = blancos) %>% 
  select(year, id_circuito_elec, partido, votos_blanco, votos_validos, votos_candidatura)

## transform to wide format
pres15_circuito_wide <- spread(pres15_circuito_long, key = partido, value = votos_candidatura) %>% 
  rename(pres15_cand_FPV = `Frente Para la Victoria`,
         pres15_cand_Cam = Cambiemos,
         pres15_cand_UNA = UNA,
         pres15_cand_Otros = Otros,
         pres15_blanco = votos_blanco,  
         pres15_validos = votos_validos) %>% 
  select(-year)

## save files
write_rds(pres15_circuito_long, "data/Pres_2015_circuito_long.RDS")
write_rds(pres15_circuito_wide, "data/Pres_2015_circuito_wide.RDS")

# -------------------------------------------------------------------------

# B) Prepare 2010 census information

# B.1 census variables ------------------------------------------------------

rm(list= ls())
library(rvest)
source("source/source.R")

## scrape the urls (source: http://dump.jazzido.com/CNPHV2010-RADIO/)
url <- "http://dump.jazzido.com/CNPHV2010-RADIO/"
url <- read_html(url)
url_list <- url %>% 
  html_nodes("a") %>% 
  html_attr("href")

url_list <- url_list[str_ends(url_list, ".csv")] 
url_list <- url_list[!str_detect(url_list, "HOGAR.NHOG|VIVIENDA.V00|HOGAR.H15|PERSONA.P03")]

# Prepare a list of varnames
prefix_list <- tibble(url_end = url_list,
                      prefix = c("vi_cal_cons_", "vi_cal_servbas_", "vi_cal_mat_", 
                                 "vi_tipo_", "vi_nho_", "vi_urban_", 
                                 "vi_tipo_part_", "vi_tipo_ocupa_", "ho_nbi_", 
                                 "ho_suelo_", "ho_techo_", "ho_rev_int_", 
                                 "ho_agua_", "ho_agua_beber_", "ho_aseo_", 
                                 "ho_cadena_", "ho_desague_", "ho_combus_", 
                                 "ho_refri_", "ho_compu_", 
                                 "ho_celu_", "ho_fijo_", "ho_hacinam_", 
                                 "ho_nhogar_", "ho_prop_", "ho_npers_", 
                                 "per_siteco_", "per_edad_gru_", 
                                 "per_edad_quin_", "per_rela_jefe_", 
                                 "per_sexo_", "per_inmig_", 
                                 "per_leer_", "per_escuela_", "per_educa_", 
                                 "per_educa_completo_", "per_compu_"),
                      descr = c("Calidad constructiva de la vivienda",
                                "Calidad de Conexiones a Servicios Básicos",
                                "Calidad de los materiales",
                                "Tipo de vivienda agrupado",
                                "Cantidad de Hogares en la Vivienda",
                                "Area Urbano - Rural",
                                "Tipo de vivienda particular",
                                "Condición de ocupación",
                                "Al menos un indicador NBI",
                                "Material predominante de los pisos",
                                "Material predominante de la cubierta exterior del techo",
                                "Revestimiento interior o cielorraso del techo",
                                "Tenencia de agua",
                                "Procedencia del agua para beber y cocinar",
                                "Tiene baño / letrina",
                                "Tiene botón, cadena, mochila para limpieza del inodoro",
                                "Desagüe del inodoro",
                                "Baño / letrina de uso exclusivo",
                                "Combustible usado principalmente para cocinar",
                                "Heladera",
                                "Computadora",
                                "Teléfono celular",
                                "Teléfono de línea",
                                "Hacinamiento",
                                "Régimen de tenencia",
                                "Total de Personas en el Hogar",
                                "Condición de actividad",
                                "Edad en grandes grupos",
                                "Edades quinquenales",
                                "Relación o parentesco con el jefe(a) del hogar",
                                "Sexo",
                                "En que país nació",
                                "Sabe leer y escribir",
                                "Condición de asistencia escolar",
                                "Nivel educativo que cursa o cursó",
                                "Completó el nivel",
                                "Utiliza computadora"))


## collect data and save
data_censo_radio <-  map2(prefix_list$url_end, prefix_list$prefix, ~ read_arg_census(end_url = .x, prefix = .y))

data_censo_joint <- data_censo_radio %>% 
  reduce(left_join, by = "radio")

write_rds(data_censo_joint, "data/data_censo_radio.RDS")

## collect totals to compute proportions and save
data_totales <- map2(c("VIVIENDA-INCALCONS.csv", "VIVIENDA-URP.csv", "HOGAR-ALGUNBI.csv", "PERSONA-P02.csv"), 
                     c("vi_", "vi_urban_", "ho_", "per_"), ~ read_arg_totales(end_url = .x, prefix = .y))

data_totales <- data_totales %>% 
  reduce(left_join, by = "radio")

write_rds(data_totales, "data/data_censo_totales_radio.RDS")

# -------------------------------------------------------------------------

# C) Create lookups to match census "radios" and electoral "circuitos"

rm(list= ls())
library(sf)
source("source/source.R")

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

# -------------------------------------------------------------------------

# D) Create final files

rm(list= ls())

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
joint_circuito <- reduce(list(joint_circuito, elec_paso19, elec_pres15, elec_paso15), 
                         left_join, by = "id_circuito_elec")
  
joint_circuito <- joint_circuito %>% 
  mutate_at(vars(starts_with("paso15_cand")), list(~ ./paso15_validos*100)) %>% 
  mutate_at(vars(starts_with("pres15_cand")), list(~ ./pres15_validos*100)) %>% 
  mutate_at(vars(starts_with("paso19_cand")), list(~ ./paso19_validos*100)) 

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

