
library(parallel)
library(fitdistrplus) 
# library(Hmisc)
library(MASS)
library(ggplot2)
library(extrafont)


tsdata <- scan("/home/fm/svn/ursa/out/ts_create_all", dec=".")

df <- data.frame(tsdata)
colnames(df) <- c("ts")
df <-subset(df, ts >= 1302472800)
df <-subset(df, ts != 4294967296)
df$IAT <- c(NA, diff(df$ts))
#df <- subset(df, IAT <= 3600)
df<- subset(df, !is.na(IAT))

samplesize <- nrow(df)*0.001 # 0.1% sample size for plotting and keeping plot size considerably smaller
df.sampled <- df[sample(nrow(df), samplesize),  ]
df.sampled <- data.frame(origin="sample", ts=df.sampled$IAT, IAT=df.sampled$IAT)

#ggplot(df.sampled, aes(x=IAT)) + stat_ecdf()
#ggplot(df.sampled, aes(x=IAT)) + geom_histogram(binwidth=.001)
#plotdist(df.sampled$IAT)
#descdist(df.sampled$IAT, boot = 1000, method='sample') # cullen-frey skewness kurtosis plot 


############# lognormal fitting (fitdistrplus)
tsdata_dist_lnorm <- fitdist(df.sampled$IAT[df.sampled$IAT > 0], 'lnorm', method='mme') # method={mme,mle,mge,qme}
lnorm_estimate <- tsdata_dist_lnorm$estimate

rv <- rlnorm(samplesize, meanlog=lnorm_estimate["meanlog"], sdlog=lnorm_estimate["sdlog"])
tmp <- data.frame(origin="lognormal", IAT=rv, ts=NA)
df.sampled <- rbind(df.sampled, tmp)

############# exponential fitting
tsdata_dist_exp <- fitdist(df.sampled$IAT, 'exp', method='mme') # method={mme,mle,mge,qme}
exp_estimate <- tsdata_dist_exp$estimate

rv <- rexp(samplesize, exp_estimate)
tmp <- data.frame(origin="exponential", IAT=rv, ts=NA)
df.sampled <- rbind(df.sampled, tmp)

############# GAMMA fitting
tsdata_dist_gamma <- fitdist(df.sampled$IAT, 'gamma', method='mme') # method={mme,mle,mge,qme}
gamma_estimate <- tsdata_dist_gamma$estimate

rv <- rgamma(samplesize, gamma_estimate["shape"], rate=gamma_estimate["rate"])
tmp <- data.frame(origin="gamma", IAT=rv, ts=NA)
df.sampled <- rbind(df.sampled, tmp)

############# BETA fitting
tsdata_dist_beta <- fitdist(df.sampled$IAT[df.sampled$IAT <= 1], 'beta', method='mme') # method={mme,mle,mge,qme}
beta_estimate <- tsdata_dist_beta$estimate

rv <- rbeta(samplesize, shape1=beta_estimate["shape1"], shape2=beta_estimate["shape2"])
tmp <- data.frame(origin="beta", IAT=rv, ts=NA)
df.sampled <- rbind(df.sampled, tmp)

############# weibull (MASS)
tsdata_dist_weibull <- fitdistr(df.sampled$IAT[df.sampled$IAT > 0], 'weibull')
weibull_estimate <- tsdata_dist_weibull$estimate

rv <- rweibull(samplesize, tsdata_dist_weibull$estimate["shape"], tsdata_dist_weibull$estimate["scale"])
tmp <- data.frame(origin="weibull", IAT=rv, ts=NA)
df.sampled <- rbind(df.sampled, tmp)


########### density comparison
#ggplot(df.sampled, aes(x=df.sampled$IAT, color=as.factor(df.sampled$origin))) + geom_density(size=1.3) + coord_cartesian(xlim=c(0,0.15)) + guides(col = guide_legend(nrow = 12)) + labs(colour = "")  + theme(text = element_text(size=20)) + ylab("Density") + xlab("Tunnel interarrival time")
#ggsave("R-IAT-densities.pdf")


########### cdf comparison

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(df.sampled, aes(x=df.sampled$IAT, color=as.factor(df.sampled$origin))) + stat_ecdf(lwd=1)
p <- p + scale_x_log10() + coord_cartesian(xlim=c(0.001,0.4)) + guides(col = guide_legend(nrow = 12)) + labs(colour = "")
p <- p + ylab("cumulative probability") + xlab("tunnel interarrival time")
p <- p + scale_color_manual(values=cbPalette)
p <- p + annotation_logticks(sides="b")
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
ggsave("R-IAT-ecdfs.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-IAT-ecdfs.pdf")





########### pearson's chi-squared goodness-of-fit test
# not sure of this is the appropriate metric for this kind of distribution

# count the number of events in the given interval and compare it to the probabilities
#

RV_samples <- 100000000
exp_RV <- rexp(RV_samples, exp_estimate)
gamma_RV <- rgamma(RV_samples, gamma_estimate["shape"], rate=gamma_estimate["rate"])

## exp
chiexp <- chisq.test(table(cut(tsdata_delta,breaks=seq(0,1,0.1))), p=(table(cut(exp_RV, breaks=seq(0,1,0.1)))/length(exp_RV)))
chiexp
chiexp$observed
chiexp$expected
chiexp$residuals

# gamma
chigamma <- chisq.test(table(cut(tsdata_delta,breaks=seq(0,1,0.1))), p=(table(cut(gamma_RV, breaks=seq(0,1,0.1)))/length(gamma_RV)))
chigamma
chigamma$observed
chigamma$expected
chigamma$residuals


############## Kolmogorov-Smirnov Tests

# exp
ks.test(tsdata_delta, "pexp", exp_estimate[["rate"]])

# gamma
ks.test(tsdata_sampled, "pgamma",gamma_estimate["shape"], gamma_estimate["rate"])



############ alternativ: fitting mit MASS fitdistr
x <- fitdistr(tsdata_delta, 'exponential', method='mme')
x$rate
x$sd
logLik(x)
x$vcov


############# weibull (MASS)
tsdata_sampled_nonzero <- tsdata_sampled[tsdata_sampled>0]
tsdata_dist_weibull <- fitdistr(tsdata_sampled_nonzero, 'weibull')
weibull_estimate <- tsdata_dist_weibull$estimate
print(tsdata_dist_weibull)
Ecdf(rweibull(100000, tsdata_dist_weibull$estimate["shape"], tsdata_dist_weibull$estimate["scale"]))
Ecdf(tsdata_sampled, add=TRUE)

ks.test(tsdata_delta, "pweibull", tsdata_dist_weibull$estimate["shape"], tsdata_dist_weibull$estimate["scale"])

## full data test
#tsdata_deltas_nonzero <- tsdata_delta[tsdata_delta>0]
#tsdata_dist_weibull <- fitdistr(tsdata_deltas_nonzero, 'weibull')
#ks.test(tsdata_delta, "pweibull", tsdata_dist_weibull$estimate["shape"], tsdata_dist_weibull$estimate["scale"])

############ further fitting tests (fitdistrplus)

## bootdist to the estimate the fitting parameter (distribution)
tsdata_dist <- fitdist(tsdata_sampled, 'exp', method='mme') # only use the sampled data, otherwise bootdist doesnt work
x <- bootdist(tsdata_dist, bootmethod="param", niter=1001)
summary(x)
plot(x)
<- bootdist(tsdata_dist, bootmethod="nonparam", niter=1001)
summary(x)
plot(x)

## cdfcomp 
cdfcomp(list(tsdata_dist,tsdata_dist_g))