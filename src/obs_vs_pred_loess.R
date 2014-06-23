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


#sub <- subset(data, subset=(obs_speed > 2 & obs_speed < 10))

color_list <- c("darkorange", "red", "darkgreen", "darkblue")
t <- wnPlotObsVsPred(data, 'speed', color_list=color_list)

#-------------------------------------------------------------------
# filter out data where wx model bias is within 1.5 m/s at sensor R2
#--------------------------------------------------------------------
test <- subset(data, subset=(fcastType == "Weather Model" & 
                             plot=='NM1' & 
                             abs(bias_speed) < 1.5 &
                             abs(bias_dir) < 30))
#subset for times and wx models in test
sub<-subset(data, subset=(wxType %in% test$wxType & datetime %in% test$datetime))

t <- wnPlotObsVsPred(sub, 'speed', color_list=color_list)

#===============================
# long term
#===============================

#butte long-term
namFile = '/home/natalie/model_evaluations/bsb/long_term/NAM/output/bias.txt'
wrfnarrFile = '/home/natalie/model_evaluations/bsb/long_term/WRF-NARR/output/bias.txt'

#salmon long-term
namFile = '/home/natalie/model_evaluations/salmon_river/long_term/NAM/output/bias.txt'
wrfnarrFile = '/home/natalie/model_evaluations/salmon_river/long_term/WRF-NARR/output/bias.txt'

bias_nam<-wnReadBiasData(namFile, 'w')
bias_wrfnarr<-wnReadBiasData(wrfnarrFile, 'w')

l <- list(bias_nam, bias_wrfnarr) #list of dfs to combine
l2 <- list("NAM", "WRFNARR") #list of forecast names

data<-wnBuildBiasDf(l, l2) #build main df

sub<-subsetOnSpeed(data, 'R2', '<', 6.0)
sub<-subset(sub, subset=(as.POSIXlt(datetime)$hour) %in% c(22:23, 0:7))

#h<-c(0,6,9,12,18)
#sub <- subset(data, subset=(as.POSIXlt(datetime)$hour %in% h))
              #obs_speed > 10 & obs_speed < 30))

#dtmin <- as.POSIXct(strptime("2010-06-01 00:00:00", '%Y-%m-%d %H:%M:%S'))
#dtmax <- as.POSIXct(strptime("2010-07-31 00:00:00", '%Y-%m-%d %H:%M:%S'))
#sub <- subset(data, subset=(datetime < dtmax & datetime > dtmin))

color_list <- c("darkorange", "red", "darkgreen", "darkblue")
t <- wnPlotObsVsPred(data, 'speed', color_list=color_list)


