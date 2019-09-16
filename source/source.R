# Metadata ----------------------------------------------------------------
# Title: Source
# Purpose: Read census and intersect maps
# Author(s): @pablocal
# Date Created: 2019-09-11
#
# Comments ----------------------------------------------------------------
# 
# 
# 
#
#



# 1. Read census data -----------------------------------------------------

read_arg_census <- function(end_url, prefix){
  
  ## gen url
  url <- paste0("http://dump.jazzido.com/CNPHV2010-RADIO/", end_url)
  
  ## open file
  file <- read_csv(url, locale = locale(encoding = "Latin1"))
  
  vars <- colnames(file)[3:ncol(file)-1]
  vars <- paste0(prefix, 
                 str_replace_all(str_sub(vars, str_locate(vars, " ")[1]+1, str_length(vars)), " ", "\\_"))
  colnames(file)[3:ncol(file)-1] <- vars
  
  return_file <- select(file, -TOTAL)
  
  return(return_file)
  
}


# 2. Read census data -----------------------------------------------------

read_arg_totales <- function(end_url, prefix){
  
  ## gen url
  url <- paste0("http://dump.jazzido.com/CNPHV2010-RADIO/", end_url)
  
  ## open file
  file <- read_csv(url, locale = locale(encoding = "Latin1"))
  
  varname <- paste0(prefix, "TOTAL")
  
  file <- select(file, radio, TOTAL) 
  colnames(file)[2] <- varname
  
  return(file)
  
}


# 3. Intersect maps to compute area correspondences -----------------------

intersect_polygons <- function(map_censo, map_circuitos){
  library(sf)
  library(tidyverse)
  
 # map_censo <- "data/censo/21_Santa_Fe_con_datos/"
 # map_circuitos <- "data/circuitos/circuito_21/"
  ## read maps
  censo <- read_sf(map_censo, stringsAsFactors = FALSE, options = "ENCODING=Latin1") %>% 
    rename_all(str_to_lower)
  
  circuitos <- read_sf(map_circuitos, stringsAsFactors = FALSE, options = "ENCODING=Latin1") %>% 
    rename_all(str_to_lower)
  
  if("Río Negro" %in% unique(circuitos$provincia)){
    circuitos$indec_p <- "63"
  }
  
  ## set same corrd system
  censo <- st_transform(censo, 4326)
  circuitos <- st_transform(circuitos, 4326)
  
  ## preapre cenus to join
  censo_to_join <- censo %>% 
    select(link, geometry) %>% 
    rename(id_radio = link) %>%
    mutate(area_radio = st_area(censo))
  
  ## preapre circuitos to join
  circuitos_to_join <- circuitos %>% 
    mutate(area_circuito = st_area(circuitos),
           ln_circuito = str_length(circuito),
           zeroes = case_when(
             ln_circuito == 2 ~ "0000",
             ln_circuito == 3 ~ "000",
             ln_circuito == 4 ~ "00",
             ln_circuito == 5 ~ "0",
             ln_circuito == 6 ~ ""
           ),
           id_circuito = paste0(indec_p, indec_d, zeroes, circuito)) %>% 
    filter(!is.na(zeroes)) %>% 
    select(id_circuito, geometry, area_circuito)
    
  
  censo_circuitos_int <- st_intersection(lwgeom::st_make_valid(censo_to_join), circuitos_to_join) %>% 
    mutate(area = st_area(.),
           por_radio = round(area/area_radio, 5)) 
  st_geometry(censo_circuitos_int) <- censo_elec_int <- NULL
  
  censo_elec_lookup <- censo_circuitos_int %>% 
    group_by(id_radio, id_circuito) %>% 
    summarise(por_radio = sum(por_radio)) %>% 
    select(id_radio, id_circuito, por_radio)
  
  return(censo_elec_lookup)
  
}



# 4. Match areas to create a INDRA and INDEC lookup -----------------------

gen_geo_lookup <- function(map1, map2){
  
  library(sf)
  library(tidyverse)
  
  elec_estab_2015 <- sf::read_sf(map1) %>% 
    rename_all(str_to_lower) 
  
  circuitos <- sf::read_sf(map2) %>% 
    rename_all(str_to_lower)
  
  
  elec_estab_2015 <- st_transform(elec_estab_2015, 4326)
  circuitos <- st_transform(circuitos, 4326)
  
  elec_estab_2015_to_join <- elec_estab_2015 %>% 
    group_by(id_distrito, id_seccion) %>% 
    summarise(count = n()) %>% 
    ungroup() %>% 
    mutate(id_seccion_elec = 100000 + id_distrito*1000 + id_seccion,
           id_seccion_elec = str_sub(as.character(id_seccion_elec), 2, 6)) %>% 
    select(id_seccion_elec)
  
  circuitos_to_join <- circuitos %>%
    mutate(id_seccion_indec = paste0(indec_p, indec_d)) %>% 
    select(id_seccion_indec) 
  
  joint_seccion <- st_intersection(elec_estab_2015_to_join, circuitos_to_join)
  
  st_geometry(joint_seccion) <- NULL
  
  lookup <- joint_seccion %>% 
    group_by(id_seccion_elec, id_seccion_indec) %>% 
    summarise(count = n()) 
  
  return(lookup)
}

  