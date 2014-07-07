require(plyr)
require(ggplot2)

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

#----------------------
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
#-----------------------

d<-wnBuildBiasDf(l, l2) #build main df

#------------------------------------
#subset for wx model bias criteria
#-------------------------------------
test <- subset(d, subset=(fcastType == "Weather Model" & 
                             plot=='R2' & 
                             abs(bias_speed) < 1.0 &
                             abs(bias_dir) < 30))
#subset for times and wx models in test
sub<-subset(d, subset=(wxType %in% test$wxType & datetime %in% test$datetime))

d<-sub

#-----------------------------------
# renaming stuff
#-----------------------------------
d$fcastNameOrdered <- factor(d$fcastNameOrdered, levels=c("NAM (12 km)", "WRF-UW (4 km)", "HRRR (3 km)", 
                             "WRF-NARR (1.33 km)", "WindNinja-NAM", "WindNinja-WRF-UW", 
                             "WindNinja-HRRR", "WindNinja-WRF-NARR"))
d$fcastType <- factor(d$fcastType, levels=c("Weather Model", "WindNinja"))


levels(d$wxType)[levels(d$wxType)=="NAM (12 km)"] <- "NAM"
levels(d$wxType)[levels(d$wxType)=="WRF-UW (4 km)"] <- "WRF-UW"
levels(d$wxType)[levels(d$wxType)=="HRRR (3 km)"] <- "HRRR"
levels(d$wxType)[levels(d$wxType)=="WRF-NARR (1.33 km)"] <- "WRF-NARR"

d$wxTypeOrdered <- factor(d$wxType, levels=c("WRF-NARR", "HRRR", "WRF-UW", "NAM"))

levels(d$fcastType)[levels(d$fcastType)=="Weather Model"] <- "NWP"
                             
#==========================================
#subset for flow regimes -- speed
#==========================================
#d$flow_regime<-"Five-day"
d$flow_regime<-"All Data"

stats <- ddply(d, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_speed), 
            rmse(df$bias_speed), sde(df$bias_speed)))
colnames(stats) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

#downslope flow regime
#down<-subsetOnSpeed(d, 'NM1', '<', 5.0)
down<-subsetOnSpeed(d, 'R2', '<', 6.0)
down$datetime<-as.POSIXlt(as.character(down$datetime))
down<-subset(down, subset=(datetime$hour %in% c(22:23, 0:7)))
#down<-subset(down, subset=(datetime$hour %in% c(23, 0:7)))
down$flow_regime<-"Downslope"

temp <- ddply(down, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_speed), 
            rmse(df$bias_speed), sde(df$bias_speed)))
colnames(temp) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

stats<-rbind(stats, temp)

#upslope flow regime
#up<-subsetOnSpeed(d, 'NM1', '<', 5.0)
up<-subsetOnSpeed(d, 'R2', '<', 6.0)
up$datetime<-as.POSIXlt(as.character(up$datetime))
#up<-subset(up, subset=(datetime$hour %in% c(10:15)))
up<-subset(up, subset=(datetime$hour %in% c(9:12)))
up$flow_regime<-"Upslope"

temp <- ddply(up, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_speed), 
            rmse(df$bias_speed), sde(df$bias_speed)))
colnames(temp) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

stats<-rbind(stats, temp)

#synoptically driven flow regime
#sdriven<-subsetOnSpeed(d, 'NM1', '>', 5.0)
sdriven<-subsetOnSpeed(d, 'R2', '>', 6.0)
sdriven$flow_regime<-"Synoptically-driven"

temp <- ddply(sdriven, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_speed), 
            rmse(df$bias_speed), sde(df$bias_speed)))
colnames(temp) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

stats<-rbind(stats, temp)

#====bar plot====================
stats$flow_regimeOrdered <- factor(stats$flow_regime, levels=c("All Data", "Downslope", "Upslope", "Synoptically-driven"))

p<-ggplot(stats, aes(x=wxType, y=rmse, fill=fcastType)) +
            xlab("Weather Model") + ylab("RMSE for Wind Speed (m/s)")
p <- p + geom_bar(stat="identity", position="dodge")
p <- p + facet_wrap( ~ flow_regimeOrdered, nrow=1)
p <- p + theme(axis.text.x = element_text(angle = 45))
p <- p + theme(axis.text.x = element_text(vjust = 0.5))



#==========================================
#subset for flow regimes -- direction
#==========================================
d$flow_regime<-"All Data"

stats <- ddply(d, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_dir), 
            rmse(df$bias_dir), sde(df$bias_dir)))
colnames(stats) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

#downslope flow regime
down<-subsetOnSpeed(d, 'NM1', '<', 5.0)
#down<-subsetOnSpeed(d, 'R2', '<', 6.0)
down$datetime<-as.POSIXlt(as.character(down$datetime))
down<-subset(down, subset=(datetime$hour %in% c(22:23, 0:7)))
#down<-subset(down, subset=(datetime$hour %in% c(23, 0:7)))
down$flow_regime<-"Downslope"

temp <- ddply(down, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_dir), 
            rmse(df$bias_dir), sde(df$bias_dir)))
colnames(temp) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

stats<-rbind(stats, temp)

#upslope flow regime
up<-subsetOnSpeed(d, 'NM1', '<', 5.0)
#up<-subsetOnSpeed(d, 'R2', '<', 6.0)
up$datetime<-as.POSIXlt(as.character(up$datetime))
#up<-subset(up, subset=(datetime$hour %in% c(10:15)))
up<-subset(up, subset=(datetime$hour %in% c(9:12)))
up$flow_regime<-"Upslope"

temp <- ddply(up, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_dir), 
            rmse(df$bias_dir), sde(df$bias_dir)))
colnames(temp) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

stats<-rbind(stats, temp)

#synoptically driven flow regime
sdriven<-subsetOnSpeed(d, 'NM1', '>', 5.0)
#sdriven<-subsetOnSpeed(d, 'R2', '>', 6.0)
sdriven$flow_regime<-"Synoptically-driven"

temp <- ddply(sdriven, .(wxTypeOrdered, fcastType, flow_regime), function(df)c(mean(df$bias_dir), 
            rmse(df$bias_dir), sde(df$bias_dir)))
colnames(temp) <- c("wxType", "fcastType", "flow_regime", "bias", "rmse", "sde")

stats<-rbind(stats, temp)

#====bar plot====================
stats$flow_regimeOrdered <- factor(stats$flow_regime, levels=c("All Data", "Downslope", "Upslope", "Synoptically-driven"))

p<-ggplot(stats, aes(x=wxType, y=rmse, fill=fcastType)) +
            xlab("Weather Model") + ylab("RMSE for Wind Direction")
p <- p + geom_bar(stat="identity", position="dodge")
p <- p + facet_wrap( ~ flow_regimeOrdered, nrow=1)
p <- p + theme(axis.text.x = element_text(angle = 45))
p <- p + theme(axis.text.x = element_text(vjust = 0.5))



#=================================================================== 
# time series plots
#===================================================================                            
#see here for ddply explanation: http://www.r-bloggers.com/a-fast-intro-to-plyr-for-r/
mb <- ddply(d, .(wxType, fcastType, datetime), function(df)c(mean(df$bias_speed), 
            rmse(df$bias_speed), sde(df$bias_speed)))
colnames(mb) <- c("wxType", "fcastType", "datetime", "bias", "rmse", "sde")


flow_regime <- "Five-day"
wxModel <- c("NAM", "WRF-UW", "HRRR", "WRF-NARR")
fcastName <- c("NAM", "WRF-UW", "HRRR", "WRF-NARR", "WindNinja-NAM", "WindNinja-WRF-UW", 
               "WindNinja-HRRR", "WindNinja-WRF-NARR")
fcastType <- c("NWP", "NWP", "NWP", "NWP", "WindNinja", "WindNinja", "WindNinja", "WindNinja")

stats<-as.data.frame(cbind(bias, rmse, sde, flow_regime, wxModel, fcastName, fcastType))

#===================================================================    
p<-ggplot(mb, aes(x=datetime, y=rmse, colour=fcastType)) +
            xlab("Datetime") + ylab("Speed (m/s)")
p <- p + geom_point()
p <- p + geom_smooth(method=loess)
p <- p + theme(axis.text.x = element_text(angle = 45))
p <- p + theme(axis.text.x = element_text(vjust = 0.5))
p <- p + facet_grid(. ~ wxType)


p<-ggplot(d.r1, aes(x=datetime, y=bias_speed, colour=fcastType)) +
            xlab("Datetime") + ylab("Speed (m/s)")
p <- p + geom_point()
#p <- p + geom_smooth(method=loess)
p <- p + theme(axis.text.x = element_text(angle = 45))
p <- p + theme(axis.text.x = element_text(vjust = 0.5))
p <- p + facet_grid(. ~ wxType)


