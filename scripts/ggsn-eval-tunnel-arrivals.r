################################################################################
################################################################################
## 
## violin plots of the number of tunnel arrivals/departures by time of day
## data should be preprocessed by awk scripts
##
## date: ~march 2013
## author: florian, albert
##
################################################################################
################################################################################

library(ggplot2)
library(extrafont)

# gawk data preparation; should be converted to R some day
#awk -F \\. 'BEGIN{begintime=1302472800; ts=begintime; print "timestamp hour_of_day create_events_per_second"}; {if ($1==ts) count++; else {print ts, int(((ts-begintime)/3600))%24, count; ts=$1;count=0}}' ts_create_all > create_freq_hours
d <- read.table("/home/fm/svn/ursa/out/create_freq_hours", header=TRUE)


p <- ggplot(d, aes(factor(hour_of_day), create_events_per_second)) + geom_violin(size=1)
p <- p + xlab("time of day") + ylab("tunnel create events per second")
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-createspersecond-1h-violin.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-createspersecond-1h-violin.pdf")


## histogramm for tunnel arrivals per second
p <- ggplot(d, aes(create_events_per_second)) + geom_density(size=1) + geom_histogram(aes(y=..density..), binwidth=1, colour="black", fill="white", size=1)
p <- p + ylab("relative occurence") + xlab("tunnel create events per second")
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-create-frequency.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-create-frequency.pdf")
