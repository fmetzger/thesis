library(ggplot2)
library(extrafont)


# timestamps (finished + requested) of every update event
#
# dataset too large, sample
# add hours: awk -F\; 'BEGIN{begintime="1302472800.000212743878364563"; print "timestamp_finished timestamp_requested hour_of_day"}; {print $1, $2, int((($1-begintime)/3600))%24}' time_update > time_update_hours
# sample: awk 'BEGIN{srand()}; (rand()<0.001)' time_update_hours > time_update_hours_sampled
# u  <- read.table("/home/fm/svn/ursa/out/time_update_hours", header=TRUE)
u <- read.table("/home/fm/svn/ursa/out/time_update_hours_sampled", header=TRUE, colClasses=c("numeric", "numeric", "numeric"))
u$timestamp_delta <- u$timestamp_finished - u$timestamp_requested
u <- subset(u, timestamp_delta >= 0) # filter garbage values (<0)

u$timeslot[u$hour_of_day < 6] <- "0h-5h"
u$timeslot[u$hour_of_day > 5 & u$hour_of_day < 12] <- "6h-11h"
u$timeslot[u$hour_of_day > 11 & u$hour_of_day < 18] <- "12h-17h"
u$timeslot[u$hour_of_day > 17 & u$hour_of_day < 24] <- "18h-23h"

u$timeslot <- factor(u$timeslot, levels=c("0h-5h","6h-11h", "12h-17h", "18h-23h"), ordered=T)

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# plot hourly ecdf lines
sampled <- u[sample(nrow(u), nrow(u)*0.05), ]
p <- ggplot(sampled, aes(x=timestamp_delta, color=as.factor(timeslot))) + stat_ecdf(lwd=1)
p <- p + coord_cartesian(xlim = c(0, 0.03))# + guides(col = guide_legend(nrow = 12))
p <- p + ylab("cumulative probability") + xlab("tunnel update processing time")
p <- p + scale_color_manual(values=cbPalette, name="time of day")
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p 
ggsave("R-update-time-cdfs.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-update-time-cdfs.pdf")
