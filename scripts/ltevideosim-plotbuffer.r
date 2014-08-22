library(ggplot2)
library(extrafont)


path <- "F:/uni/svn/fc-sim/results/set2/video1/100ms_1000mbit_0pct_results_1407771504"

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
p <- p + geom_hline(yintercept = threshold.stoptransmission, color="#56B4E9", size=1)
p <- p + geom_hline(yintercept = threshold.startplayback, color="#009E73", size=1)
p <- p + geom_hline(yintercept = threshold.startTransmission, color="#F0E442", size=1)
p <- p + xlab("time (s)") + ylab("buffered video duration (s)") 
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
ggsave("R-ltesim-plotbuffer-time.pdf", width=12, height=10, useDingbat=F)
embed_fonts("R-ltesim-plotbuffer-time.pdf")

		
	plot(buffer.log[,1], buffer.log[,5], type="l", main="Buffer Time", xlab="Simulation Time [s]", ylab="Data [s]")
	lines(controls.log[,1], controls.log[,4], col="blue")
	lines(controls.log[,1], controls.log[,5], col="red")
	lines(controls.log[,1], controls.log[,6], col="green")
	lines(controls.log[,1], controls.log[,7], col="yellow")
	plot(buffer.log[,1], buffer.log[,6], type="l", main="Transmission and Playback Times", xlab="Simulation Time [s]", ylab="Data [s]")
	lines(buffer.log[,1], buffer.log[,7], col="blue")
	plot(buffer.log[,1], buffer.log[,3], type="l", main="Transmission and Playback Bytes", xlab="Simulation Time [s]", ylab="Data [bytes]")
	lines(buffer.log[,1], buffer.log[,4], col="blue")
	plot(ecdf(buffer.log[,7]/buffer.log[,6]), verticals=TRUE, main="Transmission and Playback Ratio", xlab="Played Video/Transmitted Video [%]", ylab="Frequency [%]")


