# hexingGM
displaying GM data on a hexmap

Attached files:

  *GM_geo_boundaries.csv* - geographical boundaries for Greater Manchester local authorities
  *GM_hex_boundaries.csv* - boundaries for a hexed version of Greater Manchester local authorities
  *GM Geo map FP.jpeg* - geographical map of GM fuel poverty (output of the R code)
  *GM hex map FP.jpeg* - hex map of GM fuel poverty (output of the R code)
  
*creating a hexmap.R*
R code for creating a hexed version of Greater Manchester local authorities, based on geographical boundary data from https://martinjc.github.io/UK-GeoJSON/ & based on the method here: https://github.com/jbaileyh/geogrid
Attached hexmap boundary is the output of this

*displaying PHE fingertips data on a hexmap.R*
R code for displaying indicators from Public Health England (PHE)'s fingertips API as a colour graduated hexmap/ geographical map (using the boundaries in the attached files) 
It is currently set up for the fuel poverty indicator from the Public Health Outcomes Framework (PHOF). 
Mortality indicators are split by male/ female - the code won't currently deal with this. 
Indicators are low = good, or high = good, or neither = good, the code doesn't currently take this into account. 
Other indicator sets are available in the PHE API, but not all are available at local authority level 
