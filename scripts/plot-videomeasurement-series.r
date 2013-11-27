# replace the libreoffice plots for video playback measurement delay/loss series
#
#
#

library(reshape)
library(ggplot2)
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

#ggplot(df, aes(x=Delay, y=value, color=src)) + stat_summary(fun.y = mean, geom="line") + stat_smooth(method="lm",  fullrange=T, size=1)


ggplot(l, aes(x=Loss, y=value)) + stat_summary(fun.y = mean, geom="line") + stat_smooth(method="lm",  fullrange=T, size=1, se=F) + ylab("total stalling (s)") + xlab("packet loss (%)")


ggplot(d, aes(x=Delay, y=value)) + stat_summary(fun.y = mean, geom="line") + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="lm",  fullrange=T, size=1, se=F) + ylab("total stalling (s)") + xlab("additional delay (ms)") + theme(text = element_text(size=20))
ggsave("R-delayseries.pdf")

ggplot(l, aes(x=Loss, y=value)) + stat_summary(fun.y = mean, geom="line")  + stat_summary(fun.data="mean_cl_boot", geom="errorbar") + stat_smooth(method="lm",  fullrange=T, size=1, se=F) + ylab("total stalling (s)") + xlab("packet loss (%)") + theme(text = element_text(size=20))
ggsave("R-lossseries.pdf")