################################################################################
################################################################################
## 
## attempts to plot the empirical cdf of tunnel activation, update, 
## and deactivation time deltas
##
## results for anything other than update times might not be reliable at all
##
## date: ~march 2013
## author: florian
##
################################################################################
################################################################################

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

# plot hourly ecdf lines
sampled <- u[sample(nrow(u), nrow(u)*0.05), ]
p <- ggplot(sampled, aes(x=timestamp_delta, color=as.factor(hour_of_day))) + stat_ecdf()
p <- p + coord_cartesian(xlim = c(0, 0.03)) + guides(col = guide_legend(nrow = 12))
p <- p + ylab("cumulative probability") + xlab("tunnel update processing time")+ labs(colour = "time of day")
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p 
ggsave("R-update-time-cdfs.pdf", width=12, height=10, useDingbats=F)
embed_fonts("R-update-time-cdfs.pdf")
