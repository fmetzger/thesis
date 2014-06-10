library(ggplot2)
library(grid) # needed for arrow
library(extrafont)

# auto string to numeric conversion seems to be broken here
# timestamp and size are erroneously converted to factors
# we do it manually instead
d <- read.csv("/home/fm/git/thesis/scripts/buffer.csv", header=T, sep=",", as.is=T)
d$timestamp <- as.numeric(d$timestamp)
d$size <- as.numeric(d$size)
d$type <- as.factor(d$type)

p <- ggplot(d, aes(x=timestamp, y=size, color=type)) + geom_line(size = 1)
p <- p + xlab("time (s)") + ylab("data (KiB)") + scale_color_discrete(name="",breaks=c("segment", "frame"), labels=c("received", "played"))
p <- p + annotate("text", x = 5, y = 5800, label = "detail plot", family="Liberation Sans Narrow") + geom_segment(aes(x = 5, y = 5600, xend = 5, yend = 4600), arrow = arrow(length = unit(0.5, "cm")), colour="black")
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p
#p + annotation_custom(grob=circleGrob(r=unit(1,"npc")), xmin=2, xmax=4, ymin=4000, ymax=4500) #  add circle on top for more highlighting
ggsave("R-blocktransfer.pdf", width=12, height=10, useDingbat=F)

p <- ggplot(d, aes(x=timestamp, y=size, color=type)) + geom_line() +geom_point(size=2) + xlim(c(4.4,5.5)) + ylim(c(4350,4550))
p + xlab("time (s)") + ylab("data (KiB)") +scale_color_discrete(guide="none")
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
ggsave("R-blocktransferdetail.pdf", width=12, height=10, useDingbat=F)
