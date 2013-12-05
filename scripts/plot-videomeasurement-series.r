# evaluate python playback emulation csv
#

library(Hmisc) #implicitly loaded by ggplot2 when required
library(ggplot2)

#setwd("/home/fm/git/thesis/scripts/py-playbackemulation")
setwd("F:/uni/git/thesis/scripts/py-playbackemulation/")

d <- read.csv("playbackemulation.csv", header=T)

d$relativestall <- d$stall_duration/d$duration
df <- subset(d, d$duration == d$video_duration)

dloss <- subset(df, df$qostype == "loss")
dlatency <- subset(df, df$qostype == "delay")

pl <- ggplot(dloss, aes(x=qosvalue, y=relativestall, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("packet loss (%)") + ylab("stall duration / video duration") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Null Strategy", "Predictive", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallduration-loss.pdf")

pl <- ggplot(dloss, aes(x=qosvalue, y=stall_count, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="line")  + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=F, lty=2)
pl + xlab("packet loss (%)") + ylab("number of playback stalls") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Null Strategy", "Predictive", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallnumber-loss.pdf")


pl <- ggplot(dlatency, aes(x=qosvalue, y=relativestall, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("latency (ms)") + ylab("stall duration / video duration") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Null Strategy", "Predictive", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallduration-latency.pdf")

pl <- ggplot(dlatency, aes(x=qosvalue, y=stall_count, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("latency (ms)") + ylab("number of playback stalls") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Null Strategy", "Predictive", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallnumber-latency.pdf")


## old single strategy libreoffice import
library(reshape)
library(nlme)
d <- read.csv("yt-delay-allBW.csv", header=T, sep=";", dec=",",fill=T)
d <- melt(d, id="Delay")
d$Loss <- 0
d$src <- "delayseries"
l <- read.csv("yt-loss-allBW.csv", header=T, sep=";", dec=",",fill=T)
l <- melt(l, id="Loss")
l$Delay <- 100
l$src <- "lossseries"
df <- rbind(d,l)
ggplot(d, aes(x=Delay, y=value)) + stat_summary(fun.y = mean, geom="line") + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="lm",  fullrange=T, size=1, se=F) + ylab("total stalling (s)") + xlab("additional delay (ms)") + theme(text = element_text(size=20))
ggsave("R-delayseries.pdf")

ggplot(l, aes(x=Loss, y=value)) + stat_summary(fun.y = mean, geom="line")  + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="lm",  fullrange=T, size=1, se=F) + ylab("total stalling (s)") + xlab("packet loss (%)") + theme(text = element_text(size=20))
ggsave("R-lossseries.pdf")
