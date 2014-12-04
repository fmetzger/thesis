library(ggplot2)
#library(extrafont)
library(sysfonts)
library(Cairo)

d <- read.csv("/home/fm/git/thesis/data/playbackemulation.csv", header=T,
              colClasses=c("factor", "numeric", "factor", "factor", "factor", "factor", "factor", "numeric", "numeric", "numeric", "numeric", "factor"))

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#d$relativestall <- d$stall_duration/d$duration
#df <- subset(d, d$duration == d$video_duration) # this fails due to float rounding errors, avoid!
df <- subset(d, abs(d$duration - 92.5) < 1)
dmax <- subset(df, df$stall_duration < 1000)

d$qoe <- 3.5*exp(-(0.15*d$stall_duration+0.19)*d$stall_count)+1.5
dmax$qoe <- 3.5*exp(-(0.15*dmax$stall_duration+0.19)*dmax$stall_count)+1.5

dloss <- subset(dmax, dmax$qostype == "loss")
dlatency <- subset(dmax, dmax$qostype == "delay")


p <- ggplot(dloss, aes(x=qosvalue, y=qoe, color=as.factor(strat)))
p <- p + stat_smooth(method="loess",  fullrange=T, size=1, se=F, lty=2)
p <- p + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar")
p <- p + ylim(1,5) + xlab("packet loss (%)") + ylab("MOS")
p <- p + scale_color_manual(values=cbPalette, name="playback strategies", breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "predictive", "null strategy", "YouTube Flash"))
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
#ggsave("R-playbackemulation-qoe-loss.pdf", width=12, height=8, useDingbat=F)
#embed_fonts("R-playbackemulation-qoe-loss.pdf")
ggsave("R-playbackemulation-qoe-loss.pdf", width=12, height=8, device=cairo_pdf)


p <- ggplot(dlatency, aes(x=qosvalue, y=qoe, color=as.factor(strat)))
p <- p + stat_smooth(method="loess",  fullrange=T, size=1, se=F, lty=2)
p <- p + stat_summary(fun.y = mean, geom="point", size=4) + stat_summary(fun.data="mean_cl_boot", geom="errorbar")
p <- p + ylim(1,5) + xlab("latency (ms)") + ylab("MOS")
p <- p + scale_color_manual(values=cbPalette, name="playback strategies", breaks=c("ffh5", "nnbs", "stbs", "ytfa"), labels=c("Firefox 4", "predictive", "null strategy", "YouTube Flash"))
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
#ggsave("R-playbackemulation-qoe-latency.pdf", width=12, height=8, useDingbat=F)
#embed_fonts("R-playbackemulation-qoe-latency.pdf")
ggsave("R-playbackemulation-qoe-latency.pdf", width=12, height=8, device=cairo_pdf)

