# hexmap
#https://github.com/jbaileyh/geogrid
# files in U:\R\R-3.4.0\library\geogrid\extdata

#install.packages("ggplot2")
#install.packages("gridExtra")
#install.packages("viridis")
#install.packages("geogrid")
#install.packages("maptools")

library(ggplot2)
library(gridExtra)
library(viridis)
# devtools::install_github("jbaileyh/geogrid")
library(geogrid)
library(maptools)


  ############## import already created boundaries ##############
  
  # import geographical boundaries
    result_df_raw3 <- read.table("GM_geo_boundaries.csv")

    # draw empty geographical map  
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

  # import hex map boundaries
      result_df_hex3 <- read.table("GM_hex_boundaries.csv")
      
    # draw empty hexmap
      hexplot3 <- ggplot(result_df_hex3) +
        geom_polygon(aes(x = long, y = lat, group = group ), fill = "light grey", colour = "dark grey") + # fill = NA gives transparant
        geom_text(aes(V1, V2, label = substr(LAD13NM, 1, 15)), size = 3, color = "black")  +
        scale_fill_viridis() +
        coord_equal() +
        guides(fill = FALSE) +
        theme_void() +
        ggtitle(paste("Hexmap of Greater Manchester Authorties"))+
        guides(fill = FALSE)
      hexplot3
      
##### get data from fingertips API #####################

  # #install packages first time
  # install.packages(c("httr", "jsonlite", "lubridate", "curl", "RCurl", "dplyr",
  #                   "tidyr", "data.table", "xlsx", "XLConnect", "openxlsx"))
  # install.packages("fingertipsR")
  # install.packages("rlist")
  # install.packages("maps")
  # install.packages("ggplot2")

  # setup
    library(httr)
    library(jsonlite)
    library(lubridate)
    library(curl)
    library(RCurl)
    library(dplyr)
    library(tidyr)
    library(data.table)
    library(xlsx)
    library(XLConnect)
    library(openxlsx)
    library(fingertipsR)
    library(rlist)
    library(maps)  
    library(ggplot2)

  set_config( config(ssl_verifypeer = 0L))


  getAreaType <- 101          # area_type_id = 101 = (District & UA)
  GetProfile <- 19            # 19 = PHOF
  wantedIndicators <- 90356 # indicators which are split by male/ female (where StateSex = true) have same IID
  comparators1 <- as.data.frame(c("E08000001", 
                                  "E08000002",
                                  "E08000003",
                                  "E08000004",
                                  "E08000005",
                                  "E08000006",
                                  "E08000007",
                                  "E08000008",
                                  "E08000009",
                                  "E08000010"))
  names(comparators1) <-"AreaCode"


# get indicator names
  indicatorList<- GET(url="https://fingertips.phe.org.uk", 
                 path = paste("/api/grouproot_summaries/by_profile_id?",
                              "profile_id=", GetProfile, "&area_type_id=", getAreaType,
                              sep = "", collapse = "")
                 )
  indicatorList<- rawToChar(indicatorList$content)
  indicatorList <- fromJSON(indicatorList, flatten = TRUE)
  ShortindicatorList <- indicatorList[1:4] # name, IID, group_ID, StateSex
  ShortindicatorList <- unique(ShortindicatorList)
  # View(ShortindicatorList) - view avaialble indicators
  indicatorname <- paste(indicatorList$IndicatorName[indicatorList$IID==wantedIndicators],
                         " (",indicatorList$Unit.Label[indicatorList$IID==wantedIndicators], ", ",
                         indicatorList$Sex.Name[indicatorList$IID==wantedIndicators],")", sep ="") 
  

## loop start - collecting comparator data ---------
  
  LAcounter <-1
#  as.data.frame(totalData <- NULL)
  
    while(LAcounter <= nrow(comparators1)){ # loops through nubmer of LAs to download, & downloads each
      getAreaName <- as.character(comparators1[[LAcounter,"AreaCode"]])

      CollectedData <- GET(url="https://fingertips.phe.org.uk", 
                          path = paste("/api/latest_data/specific_indicators_for_single_area?area_type_id=", 
                                       getAreaType, "&area_code=", getAreaName, 
                                       "&indicator_ids=", wantedIndicators, 
                                       "&restrict_to_profile_ids=", GetProfile, 
                                       sep ="", collapse=""))
      CollectedData <- rawToChar(CollectedData$content)
      CollectedData <- fromJSON(CollectedData, flatten = TRUE) # fromJSON - package jsonlite
      CollectedData <- as.data.frame(list.flatten(CollectedData$Data))
  #    View(CollectedData)
  
      # export out
      ifelse(LAcounter==1,
             totalData <- CollectedData,
             totalData <- rbind(totalData, CollectedData))
      
      # looping through areas
             LAcounter <- LAcounter +1
      }

    # View(totalData)

# loop end here -----------------------------------------------

############## draw maps ##################

# draw hex map with data
  names(totalData)[names(totalData) == 'AreaCode'] <- 'LAD13CD'
  forhexplot4 <- merge(result_df_hex3, totalData) 
  
  hexplot4 <- ggplot(forhexplot4) +
    geom_polygon(aes(x = long, y = lat, group = group, fill= Val)) + # fill = NA gives transparant
    geom_text(aes(V1, V2, label = substr(LAD13NM, 1, 15)), size = 3, color = "white")  +
    scale_fill_viridis(direction =-1) +
    coord_equal() +
    theme_void() +
    ggtitle("Hexmap of GM Authorties" , subtitle = paste("PHE Fingertips indicator:",indicatorname))+
    theme(
      legend.position = "right",
      legend.direction = "vertical",
      legend.justification = "center") +
    guides(fill = guide_colorbar(
      barwidth = 1.5,
      barheigh = 20,
      title.position = "top"))
  hexplot4
  
# draw geographical map  
  names(totalData)[names(totalData) == 'AreaCode'] <- 'LAD13CD'
  forrawplot4 <- merge(result_df_raw3, totalData)  
  
    rawplot4 <- ggplot(forrawplot4) +
    geom_polygon(aes(x = long, y = lat, group = group, fill= Val)) + # fill = NA gives transparant 
    #coord_equal(ratio = 0) + # makes it not stretch to fit
        geom_text(aes(xcentroid, ycentroid, label = substr(LAD13NM, 1, 15)), size = 3, color = "white")  +
    scale_fill_viridis(direction =-1) +
    coord_equal() +
    theme_void() +
    ggtitle("Geographical map of GM Authorties ", subtitle= paste("PHE Fingertips indicator:", indicatorname))+
    theme(
      legend.position = "right",
      legend.direction = "vertical",
      legend.justification = "center",
      aspect.ratio=0.7) +
    guides(fill = guide_colorbar(
      barwidth = 1.5,
      barheigh = 20,
      title.position = "top"))
  rawplot4