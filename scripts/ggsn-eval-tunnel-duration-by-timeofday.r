library(ggplot2)
library(extrafont)

d <- read.table("/home/fm/git/eval-core/data/duration_activetunnels", header=FALSE, colClasses=c("numeric", "numeric"))
colnames(d) <- c("ts_start", "ts_end")
d$duration <- d$ts_end - d$ts_start

d <-subset(d, ts_start != 4294967296 && ts_end != 4294967296) # data sanity

numpoints <- 1000
y <- seq(0,1,1/numpoints)
#y <- lseq(0.00001,1,numpoints) #alternatively: logspaced sequence
begintime <- 1302386400
d$hour_of_day <- floor(abs((d$ts_start-begintime)/3600)%%24)


## overall ecdf with color factor
sampled <- d[sample(nrow(d), nrow(d)*0.01), ]
p <- ggplot(sampled, aes(x=duration, color=as.factor(hour_of_day))) + geom_line(stat="ecdf")
p <- p + scale_x_log10("tunnel duration (s)") + coord_cartesian(xlim = c(0.5, 1000000))
p <- p + annotation_logticks(sides="b") + ylab("cumulative probability") + guides(color=guide_legend("time of day", ncol=2, override.aes = list(size=4)))
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p

ggsave("R-duration-timeofday-ecdf.pdf", width=12, height=10, useDingbats=F)
embed_fonts("R-duration-timeofday-ecdf.pdf")
