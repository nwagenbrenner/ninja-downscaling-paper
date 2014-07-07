library(devtools)
install_github('windtools', 'nwagenbrenner')
library(windtools)

#butte
namFile = '/home/natalie/model_evaluations/bsb/5day/NAM/output/bias.txt'
hrrrFile = '/home/natalie/model_evaluations/bsb/5day/HRRR/output/bias.txt'
wrfuwFile = '/home/natalie/model_evaluations/bsb/5day/WRF-UW/output/bias.txt'
wrfnarrFile = '/home/natalie/model_evaluations/bsb/5day/WRF-NARR/output/bias.txt'

#salmon
namFile = '/home/natalie/model_evaluations/salmon_river/5day/NAM/output/bias.txt'
hrrrFile = '/home/natalie/model_evaluations/salmon_river/5day/HRRR/output/bias.txt'
wrfuwFile = '/home/natalie/model_evaluations/salmon_river/5day/WRF-UW/output/bias.txt'
wrfnarrFile = '/home/natalie/model_evaluations/salmon_river/5day/WRF-NARR/output/bias.txt'

bias_nam<-wnReadBiasData(namFile, 'w')
bias_hrrr<-wnReadBiasData(hrrrFile, 'w')
bias_wrfuw<-wnReadBiasData(wrfuwFile, 'w')
bias_wrfnarr<-wnReadBiasData(wrfnarrFile, 'w')

l <- list(bias_nam, bias_hrrr, bias_wrfuw, bias_wrfnarr) #list of dfs to combine
l2 <- list("NAM", "HRRR", "WRFUW", "WRFNARR") #list of forecast names

data<-wnBuildBiasDf(l, l2) #build main df

t<-as.POSIXct(strptime("2011-08-19 12:00:00", '%Y-%m-%d %H:%M:%S'))
#subset on time
s <- subset(data, subset=(datetime == t))

#subset on forecast and build hourly averages
ss <-subset(s, subset=(fcastName=='WindNinja-NAM'))
s.hr <- buildBiasHourlyAverages(ss)
s.hr$fcastName<-'WindNinja-NAM'
ss <-subset(s, subset=(fcastName=='NAM (12 km)'))
s.hr.temp <- buildBiasHourlyAverages(ss)
s.hr.temp$fcastName<-'NAM (12 km)'
s.hr<-rbind(s.hr, s.hr.temp)

#s <-subset(s, subset=(fcastName=='WRF-NARR (1.33 km)'))
#s <-subset(s, subset=(fcastName=='WindNinja-WRF-NARR'))

#bsb
#lat = 43.402726
#lon = -113.027724
#zoom = 12
#src
lat = 45.401667
lon = -116.228889
zoom = 14

maptype = 'terrain' #terrain, hybrid
#datatype = 'predicted' #observed or predicted
colorscale='discrete' #discrete or continous

m <- wnCreatePredObsVectorMap(s.hr, lat, lon, zoom, 
                       maptype, 
                       colorscale=colorscale, 
                       axis_labels=FALSE)

#m <- wnCreateVectorMap(s.hr, lat, lon, zoom, 
#                       maptype, 
#                       colorscale=colorscale, 
#                       axis_labels=FALSE, 
#                       datatype=datatype)

#-----------------------------------
# make a bubble plot of the bias
#-----------------------------------

t<-as.POSIXct(strptime("2010-07-18 18:00:00", '%Y-%m-%d %H:%M:%S'))

#subset on time
s <- subset(data, subset=(datetime == t))

#model<-"WRF-NARR (1.33 km)"
model<-"NAM (12 km)"

var<-"dir"
stat<-"bias"
#breaks<-5
b<-c(-6,-3,-0.1,2,4)
b<-c(15,45,90,120)
c<-heat.colors(4, alpha = 1)


test<-wnCreateBubbleMap(s, model, var=var, stat, b=b, c=c)







