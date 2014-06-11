library(parallel)
library(fitdistrplus) 
library(Hmisc)
library(MASS)
library(ggplot2)
library(extrafont)

#d <- read.table("/home/fm/git/eval-core/data/ts_create_all_hours", header=FALSE) ## all tunnel requests
d <- read.table("/home/fm/svn/ursa/out/PERS_ts_create_firstflow_radiotype", header=FALSE, fill=TRUE, colClasses=c("numeric", "factor")) ## only active tunnels
d <- data.frame(d$V1, d$V2)
colnames(d) <- c("ts", "radiotype")

d <- d[order(d$ts), ] # sort by the timestamp column

begintime <- 1302386400
d$hour_of_day <- floor(abs((d$ts-begintime)/3600)%%24)

## data sanity
d <-subset(d, ts >= 1302472800) # drop everything before 1302472800 epoch// Mo 11. Apr 00:00:00 CEST 2011 as we dont have real tunnel arrivals before that
d <-subset(d, ts != 4294967296) # drop the 2^32 artifacts (where teh heck do they even come from?)
d$IAT <- c(NA, diff(d$ts)) # add the diff column with NA in the first row
d <- subset(d, IAT <= 3600)
d<- subset(d, !is.na(IAT)) # filter empty diff rows

##
timeslots <- list(c(0:5), c(6:11), c(12:17), c(18:23))
# timeslots <- c(0:23) # for 24h time of day slots instead of 4

####### subset fitting to exponential
i <- 0
fit <- vector("list", length(timeslots))
for (slot in timeslots){
  print(slot)
  sub <- subset(d, hour_of_day %in% slot)
  fit[[i+1]] <- fitdist(sub$IAT, 'exp', method='mme')
  print(fit[i+1])
  i <- i + 1
}

####### generate exp random vars for timeslots
rvars <- data.frame(IAT=character(), hour_of_day=character())
i <- 0
for (slot in timeslots){
  print(slot)
  sub <- subset(d, hour_of_day %in% slot)
  l <- nrow(sub)
  rv <- rexp(l, as.numeric(fit[[i+1]]$estimate))
  df <- data.frame(IAT=rv, timeslot=paste(slot, collapse=""), origin="fit", stringsAsFactors=FALSE)
  rvars <- rbind(rvars, df)
  i <- i + 1
}


####### partition sample data into the timeslots
df <- data.frame()
for (slot in timeslots){
  print(slot)
  t <- subset(d, hour_of_day %in% slot)
  tmp <- data.frame(IAT=t$IAT, timeslot=paste(slot, collapse=""), origin="sample", stringsAsFactors=FALSE)
  df <- rbind(df, tmp)
}


####### plot subset sample cdfs vs random vars
z <- rbind(df,rvars)
z$timeslot[z$timeslot == "012345"] <- "0h-5h"
z$timeslot[z$timeslot == "67891011"] <- "6h-11h"
z$timeslot[z$timeslot == "121314151617"] <- "12h-17h"
z$timeslot[z$timeslot == "181920212223"] <- "18h-23h"
z$timeslot <- as.factor(z$timeslot)
z$origin <- as.factor(z$origin)
sampled <- z[sample(nrow(z), nrow(z)*0.01), ]

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(sampled, aes(x=IAT, group=origin, color=as.factor(origin))) + stat_ecdf(size=1)
p <- p + scale_x_log10() + coord_cartesian(xlim = c(0.001, 0.4)) + facet_wrap(~ timeslot)
p <- p + ylab("cumulative probability") + xlab("tunnel interarrivals (s)") + guides(color=guide_legend("", override.aes = list(size=4)))
p <- p + scale_color_manual(values=cbPalette)
p <- p + theme(text = element_text(family="Liberation Sans Narrow", size=20))
p

ggsave("R-IAT-active-fit-cdf-facets.pdf", width=12, height=10, useDingbats=F)
embed_fonts("R-IAT-active-fit-cdf-facets.pdf")


####### correlation tests
stringslots = list("0h-5h",  "6h-11h", "12h-17h", "18h-23h")
for (slot in stringslots){
  print(slot)
  s <- subset(z, timeslot == slot & origin=="sample")
  f <- subset(z, timeslot == slot & origin=="fit")
  sq <- quantile(s$IAT, probs=seq(0, 1, by=0.1))
  fq <- quantile(f$IAT, probs=seq(0, 1, by=0.1))
  print(cor(sq,fq))
  print(cor.test(sq,fq))
}


####### goodness-of-fit tests
i_max <- 23
i <- 0
while(i <= i_max) {
  print(i)
  sub <- subset(d, hour_of_day==i & origin=="sample")
  tmp <- gofstat(fit[[i+1]])
  print(tmp)
  print(tmp$chisq)
  print(tmp$chisqpvalue)
  ks.test(sub$IAT, "pexp", fit[[i+1]]$estimate["rate"])
  i <- i+1
}
