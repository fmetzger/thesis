library(ggplot2)
library(extrafont)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


path <- "/home/fm/svn/fc-sim/results/set2"
dirs <- list.dirs(path) 

df <- data.frame()
for (directory in dirs) {
  
  control.file <- sprintf("%s/%s", directory, "controls.log")
  
  if (file.exists(control.file) && file.info(control.file)$size > 0){
    leafdirectory <- strsplit(directory, "/")[[1]]
    videoname <- leafdirectory[length(leafdirectory) -1]
    leafdirectory <- tail(leafdirectory, n=1)
    simparameters <- strsplit(leafdirectory, "_")[[1]]
    latency  <- as.numeric(gsub("ms", "", simparameters[1]))
    bandwidth <- as.numeric(gsub("mbit", "", simparameters[2]))
    loss     <- as.numeric(gsub("pct", "", simparameters[3]))
    
    control.log <- read.table(control.file, sep=" ", dec=".", header=F)
    events.stop <- control.log[control.log[,2] == "stopPlay",] # only stopPlay lines
    events.start <- control.log[control.log[,2] == "startPlay",] # only startPlay lines
    # there is always on "startPlay" at beginning of log
    events.start <- events.start[-1, ]
    # remove if there is one last "stopPlay" without corresponding "startPlay"
    if (nrow(events.stop) > nrow(events.start)) {
      events.stop <- events.stop[-nrow(events.stop), ]
    }
    
    num.stop <- nrow(events.stop)
    duration.stop <- sum(events.start[,1] - events.stop[,1])
    
    tmpdf <- data.frame(videoname = videoname, latency = latency, bandwidth = bandwidth, loss = loss, num.stop = num.stop, duration.stop = duration.stop)
    df <- rbind(df, tmpdf)
  }
}

df$qoe <- 3.5*exp(-(0.15*df$duration.stop+0.19)*df$num.stop)+1.5

dbw <- subset(df, df$latency == 0)
dlatency <- subset(df, df$bandwidth == 1000)


p <- ggplot(dbw, aes(x=bandwidth, y=qoe, color=videoname))
p <- p + geom_point(size=3) + geom_line()
p <- p + scale_x_log10() + annotation_logticks(sides="b")
p <- p + ylim(1,5) + xlab("bandwidth (Mb/s)") + ylab("MOS")
p <- p + scale_color_manual(values=cbPalette, name="", breaks=c("video1", "video3", "video2"), labels=c("low quality", "standard quality", "high quality"))
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-ltesim-bwseries-qoe.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-ltesim-bwseries-qoe.pdf")


p <- ggplot(dlatency, aes(x=latency, y=qoe, color=videoname))
p <- p + geom_point(size=3) + geom_line()
p <- p + scale_x_log10() + annotation_logticks(sides="b")
p <- p + ylim(1.5,5) + xlab("bandwidth (Mb/s)") + ylab("MOS")
p <- p + scale_color_manual(values=cbPalette, name="", breaks=c("video1", "video3", "video2"), labels=c("low quality", "standard quality", "high quality"))
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-ltesim-latencyseries-qoe.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-ltesim-latencyseries-qoe.pdf")




