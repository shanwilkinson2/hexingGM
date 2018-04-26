# creating a hexmap
# https://github.com/jbaileyh/geogrid
# files in ~[R version]\library\geogrid\extdata
# boundaries from https://martinjc.github.io/UK-GeoJSON/

#install.packages("ggplot2")
#install.packages("gridExtra")
#install.packages("viridis")
#install.packages("geogrid")
#install.packages("maptools")

########## GM ###################################################################################

library(ggplot2)
library(gridExtra)
library(viridis)
# devtools::install_github("jbaileyh/geogrid")
library(geogrid)
library(maptools)

input_file3 <- system.file("extdata", "LAs.json", package = "geogrid")
original_shapes3 <- read_polygons(input_file3)

original_shapes3<- subset(original_shapes3[(original_shapes3@data$LAD13NM== "Bolton"| 
                                              original_shapes3@data$LAD13NM== "Bury" |
                                              original_shapes3@data$LAD13NM== "Rochdale" |
                                              original_shapes3@data$LAD13NM== "Tameside" |
                                              original_shapes3@data$LAD13NM== "Oldham" |
                                              original_shapes3@data$LAD13NM== "Stockport" |
                                              original_shapes3@data$LAD13NM== "Trafford" |
                                              original_shapes3@data$LAD13NM== "Manchester" |
                                              original_shapes3@data$LAD13NM== "Wigan" |
                                              original_shapes3@data$LAD13NM== "Salford"
                                              ) ,])

raw3 <- read_polygons(input_file3)
raw3@data$xcentroid <- sp::coordinates(raw3)[,1]
raw3@data$ycentroid <- sp::coordinates(raw3)[,2]

raw3<- subset(raw3[(raw3@data$LAD13NM== "Bolton"| 
                      raw3@data$LAD13NM== "Bury" |
                      raw3@data$LAD13NM== "Rochdale" |
                      raw3@data$LAD13NM== "Tameside" |
                      raw3@data$LAD13NM== "Oldham" |
                      raw3@data$LAD13NM== "Stockport" |
                      raw3@data$LAD13NM== "Trafford" |
                      raw3@data$LAD13NM== "Manchester" |
                      raw3@data$LAD13NM== "Wigan" |
                      raw3@data$LAD13NM== "Salford"
                    ) ,])

clean <- function(shape) {
  shape@data$id = rownames(shape@data)
  shape.points = fortify(shape, region="id")
  shape.df = merge(shape.points, shape@data, by="id")
}
result_df_raw3 <- clean(raw3)

# plot geographical map
  rawplot3 <- ggplot(result_df_raw3) +
  geom_polygon(aes(x = long, y = lat,  
                   colour = "area", 
                   group = group
  ), 
  fill = "light grey", 
  colour = "dark grey"
  ) + # varies colour by size of area
  geom_text(aes(xcentroid, ycentroid, label = substr(LAD13NM, 1, 15)), size = 3,color = "black") + # labels in the centre of each area
  #coord_equal(ratio = 1) + # makes it not stretch to fit
  #scale_fill_viridis() + # colour scheme of the fill range
  ggtitle("Geographical map of Greater Manchester Authorities")+
  guides(fill = FALSE) + # takes away the key
  theme_void() # no grid lines theme
rawplot3

## hexing ##

# plot different hex maps
par(mfrow = c(2, 3), mar = c(0, 0, 2, 0))
for (i in 1:6) {
  new_cells3 <- calculate_grid(shape = original_shapes3, grid_type = "hexagonal", seed = i)
  plot(new_cells3, main = paste("Seed", i, sep = " "))
}

new_cells_hex3 <- calculate_grid(shape = original_shapes3, grid_type = "hexagonal", seed = 1)
resulthex3 <- assign_polygons(original_shapes3, new_cells_hex3)

result_df_hex3 <- clean(resulthex3)

##### this one!! seed of 6. ###
Myseed <- 6
new_cells_hex3 <- calculate_grid(shape = original_shapes3, grid_type = "hexagonal", seed = Myseed)
resulthex3 <- assign_polygons(original_shapes3, new_cells_hex3)
result_df_hex3 <- clean(resulthex3)

hexplot3 <- ggplot(result_df_hex3) +
  geom_polygon(aes(x = long, y = lat, group = group ), fill = "light grey", colour = "dark grey") + # fill = NA gives transparant
  geom_text(aes(V1, V2, label = substr(LAD13NM, 1, 15)), size = 3, color = "black")  +
  scale_fill_viridis() +
  coord_equal() +
  guides(fill = FALSE) +
  theme_void() +
  ggtitle(paste("Hexmap of GM seed =", Myseed, " (using geogrid)"))+
  guides(fill = FALSE)
hexplot3

