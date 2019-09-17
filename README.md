
# Dataset: 2019 Argentine General Election

The resulting dataset is availabel in `RDS` (for R), `xlsx` (for excel)
and `csv` formats:

  - `arg_elec_censo_wide.RDS`
  - `arg_elec_censo_wide.csv`
  - `arg_elec_censo_wide.xlsx`

This project aims to create a dataset combining census statistics and
electoral results for the **Province of Buenos Aires** and the **City of
BA**. These are the data sources combined:

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

The dataset contains relative estimates of some relevant census
variables and electoral results. These are the variables (names are in
Spanish):

<table>

<thead>

<tr>

<th style="text-align:left;">

Variable

</th>

<th style="text-align:left;">

Label

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

id\_circuito\_elec

</td>

<td style="text-align:left;">

ID electoral circuit

</td>

</tr>

<tr>

<td style="text-align:left;">

province

</td>

<td style="text-align:left;">

Argentine province

</td>

</tr>

<tr>

<td style="text-align:left;">

vi\_\*

</td>

<td style="text-align:left;">

Dwelling unit level variables

</td>

</tr>

<tr>

<td style="text-align:left;">

ho\_\*

</td>

<td style="text-align:left;">

Household level variables

</td>

</tr>

<tr>

<td style="text-align:left;">

per\_\*

</td>

<td style="text-align:left;">

Person level variables

</td>

</tr>

<tr>

<td style="text-align:left;">

paso19\_\*

</td>

<td style="text-align:left;">

2019 PASO election variables

</td>

</tr>

<tr>

<td style="text-align:left;">

paso15\_\*

</td>

<td style="text-align:left;">

2015 PASO election variables

</td>

</tr>

<tr>

<td style="text-align:left;">

pres15\_\*

</td>

<td style="text-align:left;">

2015 Presidential election variables

</td>

</tr>

</tbody>

</table>

## How it was built
