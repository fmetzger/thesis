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


df <- data.frame(timestamp <- buffer.log[,1], buffereddata <- buffer.log[,2])


p <- ggplot(df, aes(x=timestamp, y=buffereddata)) + geom_line(size=1)
p <- p + xlab("time (s)") + ylab("buffered data (KiB)") 
p
		
	plot(buffer.log[,1], buffer.log[,2], type="l", main="Buffer", xlab="Simulation Time [s]", ylab="Data [bytes]")

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


