require(raster)
require(rasterVis)


bsb<-raster('/home/natalie/src/windninja/test_runs/big_butte.asc')
src<-raster('/home/natalie/src/windninja/test_runs/salmonriver_dem.asc')

#change font sizes
p.strip <- list(cex=1.5, lines=2, fontface='bold')
ckey <- list(labels=list(cex=1, col='black'), height=0.5)
x.scale <- list(cex=1, alternating=1, col='black')
y.scale <- list(cex=1, alternating=1, col='black')

f<-1 #dem resolution
f<-3 #WindNinja resolution (138 m); should be fact=5, but weird plotting issue...
f<-44 #WRF-NARR
f<-100 #HRRR
f<-133 #WRF-UW
f<-400 #NAM

bsb_agg<-aggregate(bsb, fact=f, fun=mean, expand=TRUE)
levelplot(bsb_agg, contour=FALSE, colorkey=ckey, par.strip.text=p.strip,
          scales=list(x=x.scale, y=y.scale))


f<-1 #dem resolution
f<-2 #WindNinja resolution (54 m); should be fact=5, but weird plotting issue...
f<-44 #WRF-NARR
f<-100 #HRRR
f<-133 #WRF-UW
f<-400 #NAM

src_agg<-aggregate(src, fact=f, fun=mean, expand=TRUE)
levelplot(src_agg, contour=FALSE, colorkey=ckey, par.strip.text=p.strip,
          scales=list(x=x.scale, y=y.scale))







