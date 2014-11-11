library(ggplot2)
library(grid) # needed for arrow
library(extrafont)

# precision too high for automatic numeric conversion, specify it manually
d <- read.csv("/home/fm/git/thesis/data/streaming-eval-blocktransfer.csv", header=T, sep=",", colClasses=c("numeric", "numeric", "factor"))

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(d, aes(x=timestamp, y=size, color=type)) + geom_line(size = 1)
p <- p + xlab("time (s)") + ylab("data (KiB)") 
p <- p + annotate("text", x = 5, y = 5800, label = "detail plot", family="Linux Biolinum")
p <- p + geom_segment(aes(x = 5, y = 5600, xend = 5, yend = 4600), arrow = arrow(length = unit(0.5, "cm")), colour="black")
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p <- p + scale_color_manual(values=cbPalette, name="",breaks=c("segment", "frame"), labels=c("received", "played"))
p
ggsave("R-blocktransfer.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-blocktransfer.pdf")

p <- ggplot(d, aes(x=timestamp, y=size, color=type)) + geom_line(size = 1) +geom_point(size=3) + xlim(c(4.4,5.5)) + ylim(c(4350,4550))
p <- p + xlab("time (s)") + ylab("data (KiB)")
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p <- p + scale_color_manual(values=cbPalette, guide="none")
p                              
ggsave("R-blocktransferdetail.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-blocktransferdetail.pdf")
