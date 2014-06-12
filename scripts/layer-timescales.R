library(ggplot)
library(extrafont)


xmin <- c(0.0000005, 0.000008, 0.005, 0.005, 0.05, 0.5, 0.5, 0.5, 0.6, 0.7, 10)
xmax <- c(0.0008, 5, 0.5, 5, 5, 5, 3, 3, 20, 4000, 10000000)
x <- c(100, 100, 100, 0.000001, 0.000001, 0.000001, 0.000001, 0.000001, 0.000001, 0.000001, 0.000001)

ymin <- 0.8:10.8
ymax <- 1.3:11.3
type <- c("10Gbps to 100Mbps ethernet packet duration",
          "wired RTT, ICMP ping, TCP bw probing, ECN",
          "video content at 1Mbps per ethernet frame",
          "LTE RTT",
          "UMTS RTT",
          "TCP initial RTO",
          "RTP receiver report",
          "HTTP adaptive streaming chunk",
          "video buffers, application layer flow control",
          "web session, RTP stream",
          "GTP tunnel duration")

df <- data.frame(x=x, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, type=type)

p <- ggplot(df, aes(x=x, y=ymin+(ymax-ymin)/2, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, label=type)) + geom_rect()
p <- p + scale_y_discrete(breaks=NULL) + annotation_logticks(sides="b")
p <- p + theme(axis.ticks = element_blank(), axis.text.y = element_blank())
p <- p + geom_text(hjust=0, family="Liberation Sans Narrow") + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p <- p + scale_x_log10(limits=c(0.0000001, 10000000), breaks=c(0.000001, 0.0001, 0.01, 1, 100, 10000, 1000000))
p <- p + ylab("") + xlab("time (s)")
p

ggsave("layer-timescales.pdf", width=12, height=6, useDingbats=F)
embed_fonts("layer-timescales.pdf")
