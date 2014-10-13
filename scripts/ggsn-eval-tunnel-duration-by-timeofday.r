library(ggplot2)
library(extrafont)

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

d <- read.table("/home/fm/git/eval-core/data/duration_activetunnels", header=FALSE, colClasses=c("numeric", "numeric"))
colnames(d) <- c("ts_start", "ts_end")
d$duration <- d$ts_end - d$ts_start

d <-subset(d, ts_start != 4294967296 && ts_end != 4294967296) # data sanity

numpoints <- 1000
y <- seq(0,1,1/numpoints)
#y <- lseq(0.00001,1,numpoints) #alternatively: logspaced sequence
begintime <- 1302386400
d$hour_of_day <- floor(abs((d$ts_start-begintime)/3600)%%24)

d$timeslot[d$hour_of_day < 6] <- "0h-5h"
d$timeslot[d$hour_of_day > 5 & d$hour_of_day < 12] <- "6h-11h"
d$timeslot[d$hour_of_day > 11 & d$hour_of_day < 18] <- "12h-17h"
d$timeslot[d$hour_of_day > 17 & d$hour_of_day < 24] <- "18h-23h"
d$timeslot <- factor(d$timeslot, levels=c("0h-5h","6h-11h", "12h-17h", "18h-23h"), ordered=T)

## overall ecdf with color factor
sampled <- d[sample(nrow(d), nrow(d)*0.01), ]
p <- ggplot(sampled, aes(x=duration, color=timeslot)) + stat_ecdf(lwd=1)
p <- p + scale_x_log10("tunnel duration (s)") + coord_cartesian(xlim = c(0.5, 1000000))
p <- p + annotation_logticks(sides="b") + ylab("cumulative probability")
#+ guides(color=guide_legend("time of day", ncol=2, override.aes = list(size=4)))
p <- p + scale_color_manual(values=cbPalette, name="time of day")
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-duration-timeofday-ecdf.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-duration-timeofday-ecdf.pdf")
