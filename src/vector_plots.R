library(devtools)
install_github('windtools', 'nwagenbrenner')
library(windtools)

#butte
namFile = '/home/natalie/model_evaluations/bsb/5day/NAM/output/bias.txt'
hrrrFile = '/home/natalie/model_evaluations/bsb/5day/HRRR/output/bias.txt'
wrfuwFile = '/home/natalie/model_evaluations/bsb/5day/WRF-UW/output/bias.txt'
wrfnarrFile = '/home/natalie/model_evaluations/bsb/5day/WRF-NARR/output/bias.txt'

bias_nam<-wnReadBiasData(namFile, 'w')
bias_hrrr<-wnReadBiasData(hrrrFile, 'w')
bias_wrfuw<-wnReadBiasData(wrfuwFile, 'w')
bias_wrfnarr<-wnReadBiasData(wrfnarrFile, 'w')

l <- list(bias_nam, bias_hrrr, bias_wrfuw, bias_wrfnarr) #list of dfs to combine
l2 <- list("NAM", "HRRR", "WRFUW", "WRFNARR") #list of forecast names

data<-wnBuildBiasDf(l, l2) #build main df

t<-as.POSIXct(strptime("2010-07-18 17:00:00", '%Y-%m-%d %H:%M:%S'))

#subset on time
s <- subset(data, subset=(datetime == t))
#subset on forecast
#s <-subset(s, subset=(fcastName=='WindNinja-NAM'))
s <-subset(s, subset=(fcastName=='NAM (12 km)'))

s.hr <- buildBiasHourlyAverages(s)

#bsb
lat = 43.402726
lon = -113.027724
zoom = 12
maptype = 'terrain' #terrain, hybrid
datatype = 'observed' #observed or predicted
colorscale='continuous' #discrete or continous

m <- wnCreateVectorMap(s.hr, lat, lon, zoom, 
                       maptype, 
                       colorscale=colorscale, 
                       axis_labels=FALSE, 
                       datatype=datatype)







