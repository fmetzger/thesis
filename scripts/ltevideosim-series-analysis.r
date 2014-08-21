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

# bandwidth plots
dfsub <- subset(df, df$latency == 0)

p <- ggplot(dfsub, aes(x=bandwidth, y=num.stop, color=videoname))
p <- p + geom_point(size=3) + geom_line()
p <- p + scale_x_log10()
p <- p + xlab("bandwidth (Mb/s)") + ylab("number of video stalls")
p <- p + scale_color_manual(values=cbPalette, name="", breaks=c("video1", "video2", "video3"), labels=c("video1", "video2", "video3"))
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
ggsave("R-ltesim-bwseries-numstalls.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-bwseries-numstalls.pdf")


p <- ggplot(dfsub, aes(x=bandwidth, y=duration.stop, color=videoname))
p <- p + geom_point(size=3) + geom_line()
p <- p + scale_x_log10()
p <- p + xlab("bandwidth (Mb/s)") + ylab("video stall duration (s)")
p <- p + scale_color_manual(values=cbPalette, name="", breaks=c("video1", "video2", "video3"), labels=c("video1", "video2", "video3"))
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
ggsave("R-ltesim-bwseries-stallduration.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-bwseries-stallduration.pdf")


# latency plots
dfsub <- subset(df, df$bandwidth == 1000)

p <- ggplot(dfsub, aes(x=latency, y=num.stop, color=videoname))
p <- p + geom_point(size=3) + geom_line()
p <- p + scale_x_log10()
p <- p + xlab("additional latency (ms)") + ylab("number of video stalls")
p <- p + scale_color_manual(values=cbPalette, name="", breaks=c("video1", "video2", "video3"), labels=c("video1", "video2", "video3"))
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
ggsave("R-ltesim-latencyseries-numstalls.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-latencyseries-numstalls.pdf")

p <- ggplot(dfsub, aes(x=latency, y=duration.stop, color=videoname))
p <- p + geom_point(size=3) + geom_line()
p <- p + scale_x_log10()
p <- p + xlab("additional latency (ms)") + ylab("video stall duration (s)")
p <- p + scale_color_manual(values=cbPalette, name="", breaks=c("video1", "video2", "video3"), labels=c("video1", "video2", "video3"))
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
ggsave("R-ltesim-latencyseries-stallduration.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-latencyseries-stallduration.pdf")
