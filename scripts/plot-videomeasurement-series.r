# evaluate python playback emulation csv
#

library(Hmisc) #implicitly loaded by ggplot2 when required
library(ggplot2)

d <- read.csv("playbackemulation.csv", header=T)

d$relativestall <- d$stall_duration/d$duration
#df <- subset(d, d$duration == d$video_duration) # this fails due to float rounding errors, avoid!
df <- subset(d, abs(d$duration - 92.5) < 1)

dmax <- subset(df, df$stall_duration < 1000)

dloss <- subset(dmax, dmax$qostype == "loss")
dlatency <- subset(dmax, dmax$qostype == "delay")

pl <- ggplot(dloss, aes(x=qosvalue, y=relativestall, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("packet loss (%)") + ylab("stall duration / video duration") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Predictive", "Null Strategy", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallduration-loss.pdf")

pl <- ggplot(dloss, aes(x=qosvalue, y=stall_count, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("packet loss (%)") + ylab("number of playback stalls") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Predictive", "Null Strategy", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallnumber-loss.pdf")


pl <- ggplot(dlatency, aes(x=qosvalue, y=relativestall, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("latency (ms)") + ylab("stall duration / video duration") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Predictive", "Null Strategy", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallduration-latency.pdf")

pl <- ggplot(dlatency, aes(x=qosvalue, y=stall_count, color=as.factor(strat))) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2)
pl + xlab("latency (ms)") + ylab("number of playback stalls") + scale_color_discrete(name="Playback Strategies",breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "Predictive", "Null Strategy", "YouTube Flash")) + theme(text = element_text(size=20))
ggsave("R-playbackemulation-stallnumber-latency.pdf")