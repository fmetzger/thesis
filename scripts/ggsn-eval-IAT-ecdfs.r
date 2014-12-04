################################################################################
################################################################################
## 
## approaches plotting the 2h empirical CDFs of the event
## inter-arrival times for the various datasets
## with and without split files
## with and without ggplot2
##
## date: ~january 2013
## author: florian
##
################################################################################
################################################################################

library(ggplot2)
library(plyr)
#library(extrafont)
library(sysfonts)
library(Cairo)

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

###
ecdf2h <- function(d){
  ## sort by timestamp
  d <- arrange(d, ts)
  ## generate hour_of_day column
  begintime <- 1302386400
  d$hour_of_day <- floor(abs((d$ts-begintime)/3600)%%24)

  d$timeslot[d$hour_of_day < 6] <- "0h-5h"
  d$timeslot[d$hour_of_day > 5 & d$hour_of_day < 12] <- "6h-11h"
  d$timeslot[d$hour_of_day > 11 & d$hour_of_day < 18] <- "12h-17h"
  d$timeslot[d$hour_of_day > 17 & d$hour_of_day < 24] <- "18h-23h"
  
  d$timeslot <- factor(d$timeslot, levels=c("0h-5h","6h-11h", "12h-17h", "18h-23h"), ordered=T)
  #levels(dfsub$startstop.levels)<- c("1min", "5min")
  
  ## data sanity
  d <-subset(d, ts >= 1302472800) # drop everything before 1302472800 epoch// Mo 11. Apr 00:00:00 CEST 2011 as we dont have real tunnel arrivals before that
  d <-subset(d, ts != 4294967296) # drop the 2^32 artifacts (where the heck do they even come from?)
  d$IAT <- c(NA, diff(d$ts)) # add the diff column with NA in the first row
  d <- subset(d, IAT <= 3600)
  d<- subset(d, !is.na(IAT)) # filter empty diff rows
  
  sampled <- d[sample(nrow(d), nrow(d)*0.01), ]
  p <- ggplot(sampled, aes(x=IAT, color=timeslot)) + stat_ecdf(lwd=1) +  scale_x_log10() + coord_cartesian(xlim = c(0.005, 1.0))
#  p <- p + guides(color = guide_legend(title = "time of day", nrow = 12, , override.aes = list(size=3)))
  p <- p + annotation_logticks(sides="b")
  p <- p + ylab("cumulative probability") + xlab("tunnel interarrival time (s)")
  p <- p + scale_color_manual(values=cbPalette, name="time of day")
  p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
  p
}


u <- read.table("/home/fm/svn/ursa/out/ts_create_all", header=FALSE, fill=TRUE, colClasses=c("numeric"))
d <- data.frame(u$V1)
colnames(d) <- c("ts")
ecdf2h(d)
#ggsave("R-IAT-all-2h-ecdfs.pdf", width=8, height=5.33, useDingbats=F)
#embed_fonts("R-IAT-all-2h-ecdfs.pdf")
ggsave("R-IAT-all-2h-ecdfs.pdf", width=8, height=5.33, device=cairo_pdf)

u <- read.table("/home/fm/svn/ursa/out/ts_create_successful", header=FALSE, fill=TRUE, colClasses=c("numeric"))
d <- data.frame(u$V1)
colnames(d) <- c("ts")
ecdf2h(d)
#ggsave("R-IAT-successful-2h-ecdfs.pdf", width=8, height=5.33, useDingbats=F)
#embed_fonts("R-IAT-successful-2h-ecdfs.pdf")
ggsave("R-IAT-successful-2h-ecdfs.pdf", width=8, height=5.33, device=cairo_pdf)

u <- read.table("/home/fm/svn/ursa/out/PERS_ts_create_firstflow_radiotype", header=FALSE, fill=TRUE, colClasses=c("numeric", "factor"))
d <- data.frame(u$V1, u$V2)
colnames(d) <- c("ts", "radiotype")
ecdf2h(d)
#ggsave("R-IAT-fromflows-ecdfs-2h.pdf", width=8, height=5.33, useDingbats=F)
#embed_fonts("R-IAT-fromflows-ecdfs-2h.pdf")
ggsave("R-IAT-fromflows-ecdfs-2h.pdf", width=8, height=5.33, device=cairo_pdf)

z <- subset(d, radiotype=="GERAN")
ecdf2h(z)
#ggsave("R-IAT-fromflows-gprs-ecdfs-2h.pdf", width=8, height=5.33, useDingbats=F)
#embed_fonts("R-IAT-fromflows-gprs-ecdfs-2h.pdf")
ggsave("R-IAT-fromflows-gprs-ecdfs-2h.pdf", width=8, height=5.33, device=cairo_pdf)

z <- subset(d, radiotype=="UTRAN")
ecdf2h(z)
#ggsave("R-IAT-fromflows-umts-ecdfs-2h.pdf", width=8, height=5.33, useDingbats=F)
#embed_fonts("R-IAT-fromflows-umts-ecdfs-2h.pdf")
ggsave("R-IAT-fromflows-umts-ecdfs-2h.pdf", width=8, height=5.33, device=cairo_pdf)
