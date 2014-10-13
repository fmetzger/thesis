# evaluate python playback emulation csv
#

library(Hmisc) #implicitly loaded by ggplot2 when required
library(ggplot2)
library(extrafont)

d <- read.csv("/home/fm/git/thesis/data/playbackemulation.csv", header=T,
              colClasses=c("factor", "numeric", "factor", "factor", "factor", "factor", "factor", "numeric", "numeric", "numeric", "numeric", "factor"))

d$relativestall <- d$stall_duration/d$duration
#df <- subset(d, d$duration == d$video_duration) # this fails due to float rounding errors, avoid!
df <- subset(d, abs(d$duration - 92.5) < 1)

dmax <- subset(df, df$stall_duration < 1000)

dloss <- subset(dmax, dmax$qostype == "loss")
dlatency <- subset(dmax, dmax$qostype == "delay")

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(dloss, aes(x=qosvalue, y=relativestall, color=as.factor(strat)))
p <- p + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar")
p <- p + xlab("packet loss (%)") + ylab("stall duration / video duration")
p <- p + scale_color_manual(values=cbPalette, name="playback strategies", breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "predictive", "null strategy", "YouTube Flash"))
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-playbackemulation-stallduration-loss.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-playbackemulation-stallduration-loss.pdf")


p <- ggplot(dloss, aes(x=qosvalue, y=stall_count, color=as.factor(strat)))
p <- p  + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar")
p <- p + xlab("packet loss (%)") + ylab("number of playback stalls")
p <- p + scale_color_manual(values=cbPalette, name="playback strategies", breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "predictive", "null strategy", "YouTube Flash"))
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p
ggsave("R-playbackemulation-stallnumber-loss.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-playbackemulation-stallnumber-loss.pdf")


p <- ggplot(dlatency, aes(x=qosvalue, y=relativestall, color=as.factor(strat)))
p <- p + stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar")
p <- p + xlab("latency (ms)") + ylab("stall duration / video duration")
p <- p + scale_color_manual(values=cbPalette, name="playback strategies", breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "predictive", "null strategy", "YouTube Flash"))
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p 
ggsave("R-playbackemulation-stallduration-latency.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-playbackemulation-stallduration-latency.pdf")

p <- ggplot(dlatency, aes(x=qosvalue, y=stall_count, color=as.factor(strat)))
p <- p+ stat_smooth(method="loess",  fullrange=T, size=1, se=T, lty=2) + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar")
p <- p + xlab("latency (ms)") + ylab("number of playback stalls")
p <- p + scale_color_manual(values=cbPalette, name="playback strategies", breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "predictive", "null strategy", "YouTube Flash"))
p <- p + theme(text = element_text(family="Liberation Sans", size=20))
p 
ggsave("R-playbackemulation-stallnumber-latency.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-playbackemulation-stallnumber-latency.pdf")
