# Metadata ----------------------------------------------------------------
# Title: B) Scrape and prepare census data
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
# B) Census data
#
# Options and packages ----------------------------------------------------

library(tidyverse)
library(rvest)
source("source/source.R")

# B) Prepare 2010 census information

# B.1 census variables ------------------------------------------------------

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
