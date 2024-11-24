all_airport<-read.csv('C:/Users/c3388/Downloads/archive/airport_codes.csv')
airport_acro<-all_airport$Airport.Code
airport_name<-all_airport$Airport.Name

allAirlines_per_Airports<-list()
#list.files('../input/data')
#unzip("../input/data.zip", list=TRUE)

for(aa in 1:length(airport_acro)){
  #allAirlines_per_Airports[[aa]]<-read.csv(unzip('../input/data.zip',paste0('airports_all_airlines/all_airlines-',airport_acro[aa],'.csv')))
  allAirlines_per_Airports[[aa]]<-read.csv(paste0('C:/Users/c3388/Downloads/archive/data/all_airlines-',airport_acro[aa],'.csv'))
  allAirlines_per_Airports[[aa]]$Airport.Code<-rep(airport_acro[aa],nrow(allAirlines_per_Airports[[aa]]))
  allAirlines_per_Airports[[aa]]$Airport.Name<-rep(airport_name[aa],nrow(allAirlines_per_Airports[[aa]]))
}
RES <- do.call("rbind", allAirlines_per_Airports)
RES$year<-sapply(RES$Date, function(x) as.numeric(strsplit(as.character(x),'-')[[1]][1]))
RES$month<-sapply(RES$Date, function(x) as.numeric(strsplit(as.character(x),'-')[[1]][2]))
#head(RES)
#str(RES)

RES %>% 
  group_by(year,Airport.Name) %>% 
  summarize(domestic_flight = sum(Flights_Domestic)) %>% 
  group_by(year) %>% 
  ggplot(aes(fill=factor(Airport.Name), x=factor(year), y=domestic_flight)) + 
  geom_bar(stat="identity", position="fill") + theme_fivethirtyeight() + 
  scale_fill_manual(name='',values=colorRampPalette(mycols)(length(unique(RES$Airport.Name)))) + 
  ggtitle('Percentage of Domestic flights per Airport')


RES %>% 
  mutate(Flights_International=ifelse(is.na(Flights_International), 0, Flights_International)) %>%
  group_by(year,Airport.Name) %>% 
  summarize(international_flight = sum(Flights_International)) %>% 
  group_by(year) %>% 
  ggplot(aes(fill=factor(Airport.Name), x=factor(year), y=international_flight)) + 
  geom_bar(stat="identity", position="fill") + theme_fivethirtyeight() + 
  scale_fill_manual(name='',values=colorRampPalette(mycols)(length(unique(RES$Airport.Name)))) + 
  ggtitle('Percentage of International flights per Airport')