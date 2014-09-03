library(ggplot2)
library(extrafont)


#path <- "/home/fm/svn/fc-sim/results/set2/video1/100ms_1000mbit_0pct_results_1407771504"
path <- "/home/fm/svn/fc-sim/results/set3/video1/50ms_1000mbit_0pct_results_1409580670/"


buffer.log <- read.table(sprintf("%s/%s", path, "buffer.log"), sep=" ", dec=".", header=F)
controls.log <- read.table(sprintf("%s/%s", path, "controls.log"), sep=" ", dec=".", header=F)

# if row 1 is newLimits:
threshold.stopplayback <- controls.log[1,7] # at or below
threshold.stoptransmission <-  controls.log[1,5] # at or above
threshold.startplayback <- controls.log[1,6] # at or above
threshold.startTransmission <- controls.log[1,4] # at or below


df <- data.frame(timestamp <- buffer.log[,1], buffer.data <- buffer.log[,2], buffer.time <- buffer.log[,5])


cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


p <- ggplot(df, aes(x=timestamp, y=buffer.data)) + geom_line(size=1)
p <- p + xlab("time (s)") + ylab("buffered data (KiB)") 
p


p <- ggplot(df, aes(x=timestamp, y=buffer.time)) + geom_line(size=1)
p <- p + geom_hline(yintercept = threshold.stopplayback, color="#E69F00", size=1)
p <- p + annotate("text", label = "playback stop", x = 520, y = threshold.stopplayback - 0.15, hjust = 1, family="Liberation Sans Narrow", size = 8)
p <- p + geom_hline(yintercept = threshold.stoptransmission, color="#56B4E9", size=1)
p <- p + annotate("text", label = "transmission stop", x = 520, y = threshold.stoptransmission - 0.15, hjust = 1, family="Liberation Sans Narrow", size = 8)
p <- p + geom_hline(yintercept = threshold.startplayback, color="#009E73", size=1)
p <- p + annotate("text", label = "playback start", x = 520, y = threshold.startplayback - 0.15, hjust = 1, family="Liberation Sans Narrow", size = 8)
p <- p + geom_hline(yintercept = threshold.startTransmission, color="#F0E442", size=1)
p <- p + annotate("text", label = "transmission start", x = 520, y = threshold.startTransmission - 0.15, hjust = 1, family="Liberation Sans Narrow", size = 8)
p <- p + xlab("time (s)") + ylab("buffered video duration (s)") 
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
ggsave("R-ltesim-plotbuffer-time.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-plotbuffer-time.pdf")

