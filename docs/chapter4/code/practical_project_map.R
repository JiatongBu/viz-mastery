options(width=100)
knitr::opts_chunk$set(out.width='1000px',dpi=200,message=FALSE,warning=FALSE)

#install.packages("maps")
#install.packages("geosphere")
#install.packages("fmsb")

library(ggplot2)
library(dplyr)
library(gridExtra)
library(RColorBrewer)
library(ggthemes)
library(ggrepel)
library(maps)
library(geosphere)
library(knitr)
library(fmsb)



df<-read.csv('C:/Users/c3388/Downloads/archive/airport_codes.csv',stringsAsFactors=F)
#df$long<-sapply(df$Airport.Name, function(x) geocode(x)[[1]])
#df$lat<-sapply(df$Airport.Name, function(x) geocode(x)[[2]])
LONG<-c(-84.42770,-76.66839,-71.00956,-80.94731,-87.75219,-87.90732,-96.85121,-97.04034,-104.99025,  -83.35538,-80.15060,-95.33678,-115.15374,-118.24368,-80.19179,-93.20100,-73.77814,-73.87397,-74.17446,-81.37924,-75.16522,-112.00779,-122.67648,-111.89105,-117.16108,-122.41942,-122.30882,-82.45718,  -77.04023,-77.45654)

LAT<-c(33.64073,39.17740,42.36561,35.21440,41.78678,41.97416,32.84810,32.89981,39.73924,42.21617,26.07423,29.99022,36.08400,34.05223,25.76168,44.93748,40.64131,40.77693,40.68953,28.53834, 39.95258,33.43727,45.52306,40.76078,32.71574,37.77493,47.45025,27.95058,38.85124,38.95312)
df$long<-LONG
df$lat<-LAT
head(df)

allConnections_list<-list()

for(i in 1:nrow(df)){
  allConnections_df<-data.frame(lon=double(), lat=double(), start_airport=character(), end_airport = character())
  start<-c(df$long[i],df$lat[i])
  for(j in 1:nrow(df)){
    if(i!=j){
      end<-c(df$long[j],df$lat[j])
      inter <- data.frame(gcIntermediate(start,  end, n=100, addStartEnd=TRUE, breakAtDateLine=F))
      inter$start_airport <- rep(df$Airport.Code[i],nrow(inter))
      inter$end_airport <- rep(df$Airport.Code[j],nrow(inter))
      allConnections_df<-rbind(allConnections_df,inter)
    }
  }
  allConnections_list[[i]]<-allConnections_df
}

states_map <-map_data("state")
USMAP <- ggplot() + 
  geom_map(data = states_map, 
           map = states_map,aes(x = long, y = lat, map_id = region, group = group),
           fill = "white", color = "black", size = 0.1)

#define customs color from rcolorbrewer, to be extended to n>10
mycols<-c("#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A", "#B15928")

USMAP + 
  geom_point(data=df,aes(x=long,y=lat),size=1,color='blue',alpha=1) + 
  geom_line(data=allConnections_list[[1]],aes(x=lon,y=lat,color=end_airport)) +
  geom_label_repel(data=df,aes(x=long,y=lat,label=df$Airport.Name),
                   size=3,
                   fontface = 'bold', 
                   color = 'black',
                   box.padding = unit(0.35, "lines"),
                   point.padding = unit(0.5, "lines"),
                   segment.color = 'black',alpha=.75) + 
  theme_fivethirtyeight() + theme(legend.position='none') + 
  scale_color_manual(values=colorRampPalette(mycols)(length(unique(allConnections_list[[1]]$end_airport)))) + 
  ggtitle(paste0('Departures from ',unique(allConnections_list[[1]]$start_airport)))
