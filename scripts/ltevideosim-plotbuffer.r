library(ggplot2)
library(extrafont)


path <- "/home/fm/svn/fc-sim/results/set3/video1/50ms_1000mbit_0pct_results_1409580670/"
#path <- "F:/uni/svn/fc-sim/results/set3/video1/50ms_1000mbit_0pct_results_1409580670/"


buffer.log <- read.table(sprintf("%s/%s", path, "buffer.log"), sep=" ", dec=".", header=F)
controls.log <- read.table(sprintf("%s/%s", path, "controls.log"), sep=" ", dec=".", header=F)

# if row 1 is newLimits:
threshold.stopplayback <- controls.log[1,7] # at or below
threshold.stoptransmission <-  controls.log[1,5] # at or above
threshold.startplayback <- controls.log[1,6] # at or above
threshold.startTransmission <- controls.log[1,4] # at or below

df <- data.frame(timestamp = buffer.log[,1], buffer.data = buffer.log[,2], buffer.time = buffer.log[,5])


p <- ggplot(df, aes(x=timestamp, y=buffer.time)) + geom_line(size=1)
p <- p + geom_hline(yintercept = threshold.stopplayback, color="#E69F00", size=1)
p <- p + annotate("text", label = "playback stop", x = 510, y = threshold.stopplayback - 0.2, hjust = 1, family="Linux Biolinum", size = 6)
p <- p + geom_hline(yintercept = threshold.stoptransmission, color="#56B4E9", size=1)
p <- p + annotate("text", label = "transmission stop", x = 510, y = threshold.stoptransmission - 0.2, hjust = 1, family="Linux Biolinum", size = 6)
p <- p + geom_hline(yintercept = threshold.startplayback, color="#009E73", size=1)
p <- p + annotate("text", label = "playback start", x = 510, y = threshold.startplayback - 0.2, hjust = 1, family="Linux Biolinum", size = 6)
p <- p + geom_hline(yintercept = threshold.startTransmission, color="#F0E442", size=1)
p <- p + annotate("text", label = "transmission start", x = 510, y = threshold.startTransmission - 0.2, hjust = 1, family="Linux Biolinum", size = 6)
p <- p + xlab("time (s)") + ylab("buffered video duration (s)") 
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
ggsave("R-ltesim-plotbuffer-time.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-ltesim-plotbuffer-time.pdf")

