require(raster)
require(rasterVis)

#r<-raster('/home/natalie/src/windninja/test_runs/big_butte.asc')
r<-raster('/home/natalie/src/windninja/test_runs/salmonriver_dem.asc')

#pts<-read.table('/home/natalie/bsb_locations.txt', skip=1, sep=",")
pts<-read.table('/home/natalie/salmon_locations.txt', skip=1, sep=",")
colnames(pts)<-c('id','lat','lon','z')

points<-cbind(pts$lon, pts$lat)
sp<-SpatialPoints(points, proj4string=CRS("+proj=longlat +datum=WGS84"))
sp_utm <- spTransform(sp, CRS(proj4string(r)))

#change font sizes
p.strip <- list(cex=1, lines=2, fontface='bold')
ckey <- list(labels=list(cex=1, col='black'), height=0.6)
x.scale <- list(cex=1, alternating=1, col='black')
y.scale <- list(cex=1, alternating=1, col='black')

#f<-1 #dem resolution
#f<-3 #BSB WindNinja resolution (138 m); should be fact=5, but weird plotting issue...
#f<-2 #SRC WindNinja resolution (54 m);
#f<-44 #WRF-NARR
#f<-100 #HRRR
f<-133 #WRF-UW
#f<-400 #NAM

r_agg<-aggregate(r, fact=f, fun=mean, expand=TRUE)
levelplot(r_agg, 
          contour=FALSE, colorkey=ckey, 
          par.strip.text=p.strip,
          scales=list(x=x.scale, y=y.scale)) + layer(sp.points(sp_utm, col = 'black'))











