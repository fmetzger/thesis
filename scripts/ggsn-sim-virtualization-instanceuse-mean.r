library(ggplot2)
library(reshape)
#library(extrafont)
library(sysfonts)
library(Cairo)


## file format:
# col 1: seed
# col 2: instance 0 (should always be 0)
# col -1 max instance duration


path <- "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleMultiserver/multiserver/"
#path = "F:/uni/ggsn-sim/evaluateFeasibleMultiserver/multiserver"
files <- list.files(path = path, pattern="instance_use_distribution.*csv")

dfwm <- data.frame()
for (f in files) {
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][4])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][5])
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, sep=";")
  data <- data[,!(names(data) %in% c("V1", "V2"))] # drop seed and 0 instances
   
  # calculate the mean number of active instances per experiment seed
  # do only if df contains at least one value > 0
  if(any(sapply(data, function(x) any(x > 0)))){
    x <- apply(data, 1, function(x) weighted.mean(seq(1:ncol(data)), x))
    #x <- apply(data, 1, function(x) weighted.mean(seq(1:ncol(data)), x) / max.instances)
    x <- melt(x)
    wm <- mean(x$value)
    y <- quantile(x$value, c(0.05, 0.95), na.rm=T)
     
    # 95% confidence intervals
    sdev <-sd(x$value)
    sample.size <- length(x)
    error <- qnorm(0.975)*sdev/sqrt(sample.size)
    left  <- wm-error
    right <- wm+error
    
    tmp <- data.frame(startstop.duration=20, max.tunnels = max.tunnels, max.instances = max.instances, rel.instance.use = wm, q5.instance.use = y[["5%"]], q95.instance.use = y[["95%"]], left=left, right=right)
    dfwm <- rbind(dfwm, tmp)
  }
} 
dfwm$tunnel.levels <- factor(dfwm$max.instances, levels=c(10,20,30,40,50,60,70,80,90), ordered=T)
levels(dfwm$tunnel.levels) <- c("10 instances", "20 instances", "30 instances", "40 instances", "50 instances", "60 instances", "70 instances", "80 instances", "90 instances")


dfwm$capacity <- dfwm$max.instances*dfwm$max.tunnels
dfsub <- subset(dfwm, max.instances %in% c(10,20,30,40,50,60,70,80,90))
dfsub <- subset(dfsub, capacity > 4000)


p <- ggplot(dfsub, aes(x=max.tunnels, y=rel.instance.use, ymin=left, ymax=right))
p <- p + geom_line() + geom_point(size=2) + geom_errorbar()
p <- p + facet_wrap( ~ tunnel.levels, scale="free")# + ylim(0,1)
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p <- p + ylab("mean number of instances in use") + xlab("individual instance tunnel capacity")
p <- p + guides(color=guide_legend("start/stop\nduration"))
p
#ggsave("R-virtualized-mean-instanceusage.pdf", width=12, height=8, useDingbats=F)
#embed_fonts("R-virtualized-mean-instanceusage.pdf")
ggsave("R-virtualized-mean-instanceusage.pdf", width=12, height=8, device=cairo_pdf)
