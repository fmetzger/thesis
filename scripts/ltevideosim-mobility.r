library(ggplot2)
library(extrafont)

#Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.15/bin/gswin64c.exe")

#path <- "/home/fm/svn/fc-sim/results/set5/video2"
path <- "/home/fm/svn/fc-sim/results/set4/video3"
dirs <- list.dirs(path) 

df <- data.frame()
for (directory in dirs) {
  control.file  <- sprintf("%s/%s", directory, "controls.log")
  buffer.file   <- sprintf("%s/%s", directory, "buffer.log")
  handover.file <- sprintf("%s/%s", directory, "handover.log")

  if (file.exists(control.file) && file.exists(buffer.file) && file.exists(handover.file) && file.info(control.file)$size > 0){
  
    controls.log <- read.table(control.file, sep=" ", dec=".", header=F)
    buffer.log <- read.table(buffer.file, sep=" ", dec=".", header=F, fill=T)
    handover.log <- read.table(handover.file, sep=" ", dec=".", header=F, fill=T)
      
    threshold.stopplayback <- controls.log[1,7] # at or below
    threshold.stoptransmission <-  controls.log[1,5] # at or above
    threshold.startplayback <- controls.log[1,6] # at or above
    threshold.startTransmission <- controls.log[1,4] # at or below
    
    distance <-  handover.log[1,4] - 500
    handover.start <- handover.log[handover.log[,2] == "HandoverStart", ]
    handover.start <- handover.start[handover.start[,3] == "UE", ]
    handover.stop <- handover.log[handover.log[,2] == "HandoverEndOk", ]
    handover.stop <- handover.stop[handover.stop[,3] == "UE", ]
    
    buffer.time <- buffer.log[,5]
    f11 <- rep(1/11,11)
    buffer.time.smoothed <- filter(buffer.time, f11, sides=2)
    dftmp <- data.frame(distance = distance, timestamp = buffer.log[,1], buffer.data = buffer.log[,2], buffer.time = buffer.time, buffer.time.smoothed = as.numeric(buffer.time.smoothed))
    dfsub <- dftmp[-seq(2, nrow(dftmp), by = 2),]
    df <- rbind(df, dfsub)
  }
} 

df$distance.levels <- factor(df$distance, levels=c(0,50,100,150), ordered=T)
levels(df$distance.levels) <- c("0m","50m","100m","150m")
  
p <- ggplot(df, aes(x=timestamp, y=buffer.time.smoothed)) + geom_line()
p <- p + facet_wrap(~ distance.levels, ncol=1)
p <- p + geom_hline(yintercept = threshold.stopplayback, color="#E69F00", size=1)
p <- p + geom_hline(yintercept = threshold.stoptransmission, color="#56B4E9", size=1)
p <- p + geom_hline(yintercept = threshold.startplayback, color="#009E73", size=1)
p <- p + geom_hline(yintercept = threshold.startTransmission, color="#F0E442", size=1)
p <- p + geom_vline(xintercept=handover.start[,1], color="#999999")
#p <- p + geom_vline(xintercept=handover.stop[,1], color="#999999")    
p <- p + xlab("time (s)") + ylab("buffered video duration (s)") 
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
ggsave("R-ltesim-plotbuffer-mobility-facets.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-plotbuffer-mobility-facets.pdf")
