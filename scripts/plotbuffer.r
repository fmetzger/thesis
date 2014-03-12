library(ggplot2)
library(grid) # needer for arrow

d <- read.csv("buffer.csv", header=T)

p <- ggplot(d, aes(x=timestamp, y=size, color=type)) + geom_line(size = 1)
p <- p + xlab("time (s)") + ylab("data (KiB)") + scale_color_discrete(name="",breaks=c("segment", "frame"), labels=c("received", "played")) + theme(text = element_text(size=20))
p + annotate("text", x = 5, y = 5800, label = "detail plot") + geom_segment(aes(x = 5, y = 5600, xend = 5, yend = 4600), arrow = arrow(length = unit(0.5, "cm")), colour="black")
#p + annotation_custom(grob=circleGrob(r=unit(1,"npc")), xmin=2, xmax=4, ymin=4000, ymax=4500) #  add circle on top for more highlighting
ggsave("R-blocktransfer.pdf")

p <- ggplot(d, aes(x=timestamp, y=size, color=type)) + geom_line() +geom_point(size=2) + xlim(c(4.4,5.5)) + ylim(c(4350,4550))
p + xlab("time (s)") + ylab("data (KiB)") +scale_color_discrete(guide="none") + theme(text = element_text(size=20))
ggsave("R-blocktransferdetail.pdf")
