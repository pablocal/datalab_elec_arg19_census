# Metadata ----------------------------------------------------------------
# Title: Figures PASO and presidential election
# Purpose:
# Author(s): @pablocal
# Date Created: 2019-10-31
#
# Comments ----------------------------------------------------------------
# 
# 
# 
#
#
# Options and packages ----------------------------------------------------
library(tidyverse)
library(showtext)

font_add_google("Roboto Condensed", "Roboto_c")
font_add_google("Roboto", "Roboto")
showtext_auto()

pablo_theme <- theme(plot.title = element_text(family = "Roboto_c", hjust = -.01, face = "bold"),
                     plot.subtitle = element_text(family = "Roboto_c", hjust = -.01),
                     plot.caption = element_text(family = "Roboto_c", color = "grey40"),
                     legend.position = "none",
                     axis.line.x = element_line(color = "black"),
                     axis.title.y = element_text(color = "black", family = "Roboto_c"),
                     axis.ticks.y = element_blank(),
                     axis.text.x = element_text(color = "grey15", family = "Roboto_c"),
                     axis.title.x = element_text(color = "black", family = "Roboto_c"),
                     axis.text.y = element_text(color = "grey15", family = "Roboto_c"),
                     plot.background = element_rect(fill = "white"),
                     panel.background = element_rect(fill = "white"),
                     strip.background = element_rect(fill = "firebrick3"),
                     strip.text = element_text(color = "white", family = "Roboto_c", hjust = .1))

# 1. Data -----------------------------------------------------------------
df <- read_rds("arg_elec_censo_wide.RDS")

# 2. Voto peronista -------------------------------------------------------

df_peron <- df %>% 
  select(paso19_cand_FdT, pres19_cand_FdT, ho_3omas_por_cuarto, per_nietos_hogar, per_edad_20_24, ho_necesidad_basica_insatisfecha) %>% 
  drop_na() %>% 
  gather("facet", "x", ho_3omas_por_cuarto:ho_necesidad_basica_insatisfecha) %>% 
  mutate(facet = recode(facet,
                        ho_3omas_por_cuarto = "Hogares con 3 o más personas por cuarto",
                        per_nietos_hogar = "Jefes de hogar que viven con nietos",
                        per_edad_20_24 = "Personas entre 20 y 24 años",
                        ho_necesidad_basica_insatisfecha = "Hogares con necesidades básicas insatisfechas"))

ggplot(df_peron, aes(x = x, y = paso19_cand_FdT)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap(~ facet, scales = "free_x") +
  labs(title = "Voto al Frente de Todos en las PASO '19",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Censo 2010 (%)",
       y = "Voto al Frente de Todos (% válido)") +
  pablo_theme

ggsave("output/peron_paso.pdf")

ggplot(df_peron, aes(x = x, y = pres19_cand_FdT)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap(~ facet, scales = "free_x") +
  labs(title = "Voto al Frente de Todos en las presidenciales '19",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Censo 2010 (%)",
       y = "Voto al Frente de Todos (% válido)") +
  pablo_theme

ggsave("output/peron_pres.pdf")


# 3. Voto macrista --------------------------------------------------------

df_macri <- df %>% 
  select(paso19_cand_JxC, pres19_cand_JxC, per_estud_universitario, per_servicio_domestico_interno, per_edad_65mas, ho_compu) %>% 
  drop_na() %>% 
  gather("facet", "x", per_estud_universitario:ho_compu) %>% 
  mutate(facet = recode(facet,
                        per_estud_universitario = "Personas con estudio universitarios",
                        per_servicio_domestico_interno = "Personas con servicio doméstico",
                        per_edad_65mas = "Personas de 60 o más años",
                        ho_compu = "Hogares con computadora")) %>% 
  filter(!(facet == "Hogares con computadora" & x < 75))

ggplot(df_macri, aes(x = x, y = paso19_cand_JxC)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap(~ facet, scales = "free_x") +
  labs(title = "Voto a Juntos por el Cambio en las PASO '19",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Censo 2010 (%)",
       y = "Voto a Juntos por el Cambio (% válido)") +
  pablo_theme

ggsave("output/cambiemos_paso.pdf")

ggplot(df_macri, aes(x = x, y = pres19_cand_JxC)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap(~ facet, scales = "free_x") +
  labs(title = "Voto a Juntos por el Cambio en las presidenciales '19",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Censo 2010 (%)",
       y = "Voto a Juntos por el Cambio (% válido)") +
  pablo_theme

ggsave("output/cambiemos_pres.pdf")


# 4. Voto peronista y desempleo -------------------------------------------

df_des <- df %>% 
  select(per_desocupado, paso19_cand_FdT, paso15_cand_FPV, pres19_cand_FdT, pres15_cand_FPV) %>% 
  drop_na() %>% 
  gather("facet", "y", paso19_cand_FdT:pres15_cand_FPV) %>% 
  mutate(facet = recode(facet,
                        paso19_cand_FdT = "Frente de Todos (PASO '19)",
                        paso15_cand_FPV = "Frente para la Victoria (PASO '15)",
                        pres19_cand_FdT = "Frente de Todos (pres. '19)",
                        pres15_cand_FPV = "Frente para la Victoria (pres. '15)"))

ggplot(filter(df_des, facet %in% c("Frente de Todos (PASO '19)", "Frente para la Victoria (PASO '15)")), aes(x = per_desocupado, y = y)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap( ~ facet) +
  labs(title = "Voto peronista PASO '15 y '19 según nivel de desempleo 2010",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Personas desempleadas (%) (Censo 2010)",
       y = "Voto Peronismo (% válido)") +
  pablo_theme

ggsave("output/peron_paro_paso.pdf")


ggplot(filter(df_des, facet %in% c("Frente de Todos (pres. '19)", "Frente para la Victoria (pres. '15)")), aes(x = per_desocupado, y = y)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap( ~ facet) +
  labs(title = "Voto peronista presidenciales '15 y '19 según nivel de desempleo 2010",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Personas desempleadas (%) (Censo 2010)",
       y = "Voto Peronismo (% válido)") +
  pablo_theme

ggsave("output/peron_paro_pres.pdf")



# 5. paso vs presidential -------------------------------------------------

df_per15 <- df %>% 
  select(pres15_cand_FPV, paso15_cand_FPV) %>% 
  mutate(facet = "FPV") %>% 
  rename(paso15_per = paso15_cand_FPV,
         pres15_per = pres15_cand_FPV) 

df_paso15_pres15 <- df %>% 
  select(pres15_cand_Cam, paso15_cand_Cam) %>%
  mutate(facet = "Cam") %>% 
  rename(paso15_per = paso15_cand_Cam,
         pres15_per = pres15_cand_Cam) %>% 
  bind_rows(df_per15) %>% 
  drop_na() %>% 
  mutate(facet = recode(facet,
                        FPV = "Frente para la Victoria",
                        Cam = "Cambiemos"))

ggplot(df_paso15_pres15, aes(x = paso15_per, y = pres15_per)) +
  geom_point(alpha = .2, shape = 1) +
  geom_abline(intercept = 0, col = "blue") +
  scale_y_continuous(limits = c(0, 80)) +
  scale_x_continuous(limits = c(0, 80)) +
  facet_wrap( ~ facet) +
  labs(title = "Voto PASO y presidenciales '15",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral",
       x = "PASO '15 (% válido)",
       y = "Presidenciales '15 (1ª vuelta) (% válid0)") +
  pablo_theme

ggsave("output/paso_pres15.pdf")

df_per19 <- df %>% 
  select(pres19_cand_FdT, paso19_cand_FdT) %>% 
  mutate(facet = "FdT") %>% 
  rename(paso19_per = paso19_cand_FdT,
         pres19_per = pres19_cand_FdT) 

df_paso19_pres19 <- df %>% 
  select(pres19_cand_JxC, paso19_cand_JxC) %>%
  mutate(facet = "JxC") %>% 
  rename(paso19_per = paso19_cand_JxC,
         pres19_per = pres19_cand_JxC) %>% 
  bind_rows(df_per19) %>% 
  drop_na() %>% 
  mutate(facet = recode(facet,
                        FdT = "Frente de Todos",
                        JxC = "Juntos por el Cambio"))

ggplot(df_paso19_pres19, aes(x = paso19_per, y = pres19_per)) +
  geom_point(alpha = .2, shape = 1) +
  geom_abline(intercept = 0, col = "blue") +
  scale_y_continuous(limits = c(0, 80)) +
  scale_x_continuous(limits = c(0, 80)) +
  facet_wrap( ~ facet) +
  labs(title = "Voto PASO y presidenciales '19",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral",
       x = "PASO '19 (% válido)",
       y = "Presidenciales '19 (1ª vuelta) (% válid0)") +
  pablo_theme

ggsave("output/paso_pres19.pdf")


# 6. Fijos y voto paso -------------------------------------------------------

df_tel <- df %>% 
  select(ho_fijo, paso19_cand_FdT, paso19_cand_JxC) %>% 
  drop_na() %>% 
  gather("facet", "y", paso19_cand_FdT:paso19_cand_JxC) %>% 
  mutate(facet = recode(facet,
                        paso19_cand_FdT = "Frente de Todos",
                        paso19_cand_JxC = "Frente Juntos por el Cambio"),
         facet = fct_relevel(facet, "Frente de Todos"))

ggplot(df_tel, aes(x = ho_fijo, y = y)) +
  geom_point(alpha = .2, shape = 1) +
  geom_smooth(method = "lm", col = "red4") +
  scale_y_continuous(limits = c(0, 80)) +
  facet_wrap( ~ facet) +
  labs(title = "Voto PASO '19 según hogares con línea fija",
       subtitle = "Circuitos electorales de BA y CABA",
       caption = "@pablocalv · Datos Comisión Electoral e INDEC",
       x = "Hogares con línea fija (%) (Censo 2010)",
       y = "Voto válido") +
  pablo_theme

ggsave("output/fijos.pdf")
