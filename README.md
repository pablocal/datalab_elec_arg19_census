
# Dataset: 2019 Argentine General Election

The resulting dataset is availabel in `csv` (for excel) and `RDS` (for
R) formats:

  - `arg_elec_censo_wide.csv`
  - `arg_elec_censo_wide.RDS`

This project aims to create a dataset combining census statistics and
electoral results. These are the data sources combined:

  - 2010 **census** statistics
  - 2019 **PASO** presidential election
  - 2015 **PASO** presidential election
  - 2015 **presidential** election

Data is aggregated at “circuito”, the lowest level at which electoral
results are available. In Argentina, census and electoral geography are
independent so I had to create a lookup file for correspondences between
census tracks and electoral “circuitos”. I did this by computing the
area intersected between both sets of boundaries.

## The dataset

    #> # A tibble: 5 x 94
    #>   id_circuito_elec vi_calidad_insu… vi_serv_basicos… vi_nho_2mas vi_urbano
    #>   <chr>                       <dbl>            <dbl>       <dbl>     <dbl>
    #> 1 01001000001                 3.18             0.511        2.47       100
    #> 2 01001000002                 6.73             2.70         3.24       100
    #> 3 01001000003                19.1             34.6          6.25       100
    #> 4 01001000005                53.3             13.7         14.1        100
    #> 5 01001000006                 0.969            0.477       14.2        100
    #> # … with 89 more variables: vi_rural_agrupado <dbl>,
    #> #   vi_rural_disperso <dbl>, ho_necesidad_basica_insatisfecha <dbl>,
    #> #   ho_suelo_cemento <dbl>, ho_suelo_ladrillo <dbl>,
    #> #   ho_techo_chapa_metal <dbl>, ho_techo_chapa_pastico <dbl>,
    #> #   ho_techo_chapa_carton <dbl>, ho_techo_chapa_barro <dbl>,
    #> #   ho_agua_fuera_vivienda <dbl>, ho_agua_fuera_terreno <dbl>,
    #> #   ho_sin_aseo <dbl>, ho_refri_carbon <dbl>, ho_compu <dbl>,
    #> #   ho_celu <dbl>, ho_fijo <dbl>, ho_fhacinamiento <dbl>,
    #> #   ho_3omas_por_cuarto <dbl>, ho_prop_vivienda_terreno <dbl>,
    #> #   ho_prop_vivienda <dbl>, ho_inquilino <dbl>, ho_npers_1 <dbl>,
    #> #   ho_npers_2 <dbl>, ho_npers_3 <dbl>, ho_npers_4 <dbl>,
    #> #   ho_npers_5 <dbl>, ho_npers_6 <dbl>, ho_npers_7 <dbl>,
    #> #   ho_npers_8mas <dbl>, per_ocupado <dbl>, per_desocupado <dbl>,
    #> #   per_inactivo <dbl>, per_edad_0_14 <dbl>, per_edad_15_65 <dbl>,
    #> #   per_edad_65mas <dbl>, per_edad_0_4 <dbl>, per_edad_5_9 <dbl>,
    #> #   per_edad_10_14 <dbl>, per_edad_14_19 <dbl>, per_edad_20_24 <dbl>,
    #> #   per_edad_25_29 <dbl>, per_edad_30_34 <dbl>, per_edad_35_39 <dbl>,
    #> #   per_edad_40_44 <dbl>, per_edad_45_49 <dbl>, per_edad_50_54 <dbl>,
    #> #   per_edad_55_59 <dbl>, per_edad_60_64 <dbl>, per_edad_65_69 <dbl>,
    #> #   per_edad_70_74 <dbl>, per_edad_75_79 <dbl>, per_edad_80_84 <dbl>,
    #> #   per_edad_85_89 <dbl>, per_edad_90_94 <dbl>, per_edad_95mas <dbl>,
    #> #   per_nietos_hogar <dbl>, per_servicio_domestico_interno <dbl>,
    #> #   per_hombre <dbl>, per_mujer <dbl>, per_inmigrante <dbl>,
    #> #   per_sabe_leer <dbl>, per_nunca_asiste <dbl>, per_estud_primario <dbl>,
    #> #   per_estud_egb <dbl>, per_estud_secundara <dbl>,
    #> #   per_estud_polimodal <dbl>, per_estud_superior <dbl>,
    #> #   per_estud_universitario <dbl>, per_estud_postuniversitario <dbl>,
    #> #   per_estud_especial <dbl>, per_estud_completos <dbl>, per_compu <dbl>,
    #> #   paso19_blanco <dbl>, paso19_validos <dbl>, paso19_cand_FdT <dbl>,
    #> #   paso19_cand_JxC <dbl>, paso19_cand_Otros <dbl>, pres15_blanco <int>,
    #> #   pres15_validos <int>, pres15_cand_Cam <dbl>, pres15_cand_FPV <dbl>,
    #> #   pres15_cand_Otros <dbl>, pres15_cand_UNA <dbl>, paso15_blanco <int>,
    #> #   paso15_validos <int>, paso15_cand_Cam <dbl>, paso15_cand_FPV <dbl>,
    #> #   paso15_cand_Otros <dbl>, paso15_cand_UNA <dbl>

### Variables

<table>

<thead>

<tr>

<th style="text-align:left;">

Variable

</th>

<th style="text-align:left;">

Summary

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

vi\_cal\_cons\_

</td>

<td style="text-align:left;">

Calidad constructiva de la vivienda

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_cal\_servbas\_

</td>

<td style="text-align:left;">

Calidad de Conexiones a Servicios Básicos

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_cal\_mat\_

</td>

<td style="text-align:left;">

Calidad de los materiales

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_tipo\_

</td>

<td style="text-align:left;">

Tipo de vivienda agrupado

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_nho\_

</td>

<td style="text-align:left;">

Cantidad de Hogares en la Vivienda

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_urban\_

</td>

<td style="text-align:left;">

Area Urbano - Rural

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_tipo\_part\_

</td>

<td style="text-align:left;">

Tipo de vivienda particular

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_tipo\_ocupa\_

</td>

<td style="text-align:left;">

Condición de ocupación

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_nbi\_

</td>

<td style="text-align:left;">

Al menos un indicador NBI

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_suelo\_

</td>

<td style="text-align:left;">

Material predominante de los pisos

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_techo\_

</td>

<td style="text-align:left;">

Material predominante de la cubierta exterior del techo

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_rev\_int\_

</td>

<td style="text-align:left;">

Revestimiento interior o cielorraso del techo

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_agua\_

</td>

<td style="text-align:left;">

Tenencia de agua

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_agua\_beber\_

</td>

<td style="text-align:left;">

Procedencia del agua para beber y cocinar

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_aseo\_

</td>

<td style="text-align:left;">

Tiene baño / letrina

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_cadena\_

</td>

<td style="text-align:left;">

Tiene botón, cadena, mochila para limpieza del inodoro

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_desague\_

</td>

<td style="text-align:left;">

Desagüe del inodoro

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_combus\_

</td>

<td style="text-align:left;">

Baño / letrina de uso exclusivo

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_refri\_

</td>

<td style="text-align:left;">

Combustible usado principalmente para cocinar

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_compu\_

</td>

<td style="text-align:left;">

Heladera

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_celu\_

</td>

<td style="text-align:left;">

Computadora

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_fijo\_

</td>

<td style="text-align:left;">

Teléfono celular

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_hacinam\_

</td>

<td style="text-align:left;">

Teléfono de línea

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_nhogar\_

</td>

<td style="text-align:left;">

Hacinamiento

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_prop\_

</td>

<td style="text-align:left;">

Régimen de tenencia

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_npers\_

</td>

<td style="text-align:left;">

Total de Personas en el Hogar

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_siteco\_

</td>

<td style="text-align:left;">

Condición de actividad

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_edad\_gru\_

</td>

<td style="text-align:left;">

Edad en grandes grupos

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_edad\_quin\_

</td>

<td style="text-align:left;">

Edades quinquenales

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_rela\_jefe\_

</td>

<td style="text-align:left;">

Relación o parentesco con el jefe(a) del hogar

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_sexo\_

</td>

<td style="text-align:left;">

Sexo

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_inmig\_

</td>

<td style="text-align:left;">

En que país nació

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_leer\_

</td>

<td style="text-align:left;">

Sabe leer y escribir

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_escuela\_

</td>

<td style="text-align:left;">

Condición de asistencia escolar

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_educa\_

</td>

<td style="text-align:left;">

Nivel educativo que cursa o cursó

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_educa\_completo\_

</td>

<td style="text-align:left;">

Completó el nivel

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_compu\_

</td>

<td style="text-align:left;">

Utiliza computadora

</td>

</tr>

</tbody>

</table>

## How it was built
