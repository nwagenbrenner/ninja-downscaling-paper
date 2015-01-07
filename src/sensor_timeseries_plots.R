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

s<-subset(data, subset=(plot=='R2'))

s$fcastTypeOrdered <- factor(s$fcastType, levels=c("Weather Model", "WindNinja"))

color_list <- c("darkorange", "red", "darkgreen", "darkblue")

ss<-subset(s, subset=(wxType %in% c('NAM (12 km)', 'HRRR (3 km)')))

#--- plot the time series ----------------------------------------------------
p <- ggplot(ss, aes(x=datetime, y=obs_speed)) +
        geom_point(shape=19, size=1.5, alpha = 1.0, colour='black') +
        geom_line() +
        theme_bw() +
        xlab("Time") + ylab("Speed (m/s)")

p <- p + theme(axis.text.x = element_text(angle = 45))
p <- p + theme(axis.text.x = element_text(vjust = 0.5))
p <- p + theme(axis.text.x = element_text(color='black', size=16))
p <- p + theme(axis.text.y = element_text(color='black', size=16))
    
p<-p + scale_x_datetime(breaks=c(min(s$datetime)+12*60*60,
                   min(s$datetime)+12*3*60*60,
                   min(s$datetime)+12*5*60*60,
                   min(s$datetime)+12*7*60*60,
                   min(s$datetime)+12*9*60*60))
    

p<- p + theme(axis.title=element_text(size=16))

p<-p + geom_point(data=ss, aes(x=datetime, y=pred_speed, colour=wxType),shape = 19, size=1.5, alpha = 0.5)
p<-p + geom_line(data=ss, aes(x=datetime, y=pred_speed, size = 0.0001, colour=wxType, linetype=fcastTypeOrdered))
   
p<-p + scale_colour_manual(values=color_list, name="Model Type")




