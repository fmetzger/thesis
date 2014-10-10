library(ggplot2)
library(extrafont)



#path <- "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleDimensioning/traditional/"
path <- "F:/uni/ggsn-sim/evaluateFeasibleDimensioning/traditional/"
files <- list.files(path=path, pattern="metrics.*csv")

df <- data.frame()
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  sample.size <- nrow(data)
  block.prob.mean  <- mean(data$block.prob)
  block.prob.sdev  <- sd(data$block.prob)
  # 95% quantiles
  block.prob.max   <- quantile(data$block.prob, 0.95)
  block.prob.min   <- quantile(data$block.prob, 0.05)
  # 95% confidence intervals
  block.prob.error <- qnorm(0.975)*block.prob.sdev/sqrt(sample.size)
  block.prob.left  <- block.prob.mean-block.prob.error
  block.prob.right <- block.prob.mean+block.prob.error
  
  res.util.mean    <- mean(data$res.util)
  res.util.sdev    <- sd(data$res.util)
  # 95% quantiles
  res.util.min     <- quantile(data$res.util, 0.05)
  res.util.max     <- quantile(data$res.util, 0.95)
  # 95% confidence intervals
  res.util.error   <- qnorm(0.975)*res.util.sdev/sqrt(sample.size)
  res.util.left    <- res.util.mean-res.util.error
  res.util.right   <- res.util.mean+res.util.error
  data <- data.frame(startstop.duration = 20, res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, max.tunnels=max.tunnels, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, max.instances=1, res.util.left=res.util.left, res.util.right=res.util.right, block.prob.left=block.prob.left, block.prob.right=block.prob.right)
  df <- rbind(df, data)
}

#path <- "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleMultiserver/multiserver/"
path <- "F:/uni/ggsn-sim/evaluateFeasibleMultiserver/multiserver/"
files <- list.files(path=path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][3])
  sample.size <- nrow(data)
  block.prob.mean  <- mean(data$block.prob)
  block.prob.sdev  <- sd(data$block.prob)
  # 95% quantiles
  block.prob.max   <- quantile(data$block.prob, 0.95)
  block.prob.min   <- quantile(data$block.prob, 0.05)
  # 95% confidence intervals
  block.prob.error <- qnorm(0.975)*block.prob.sdev/sqrt(sample.size)
  block.prob.left  <- block.prob.mean-block.prob.error
  block.prob.right <- block.prob.mean+block.prob.error
  
  res.util.mean    <- mean(data$res.util)
  res.util.sdev    <- sd(data$res.util)
  # 95% quantiles
  res.util.min     <- quantile(data$res.util, 0.05)
  res.util.max     <- quantile(data$res.util, 0.95)
  # 95% confidence intervals
  res.util.error   <- qnorm(0.975)*res.util.sdev/sqrt(sample.size)
  res.util.left    <- res.util.mean-res.util.error
  res.util.right   <- res.util.mean+res.util.error
  data <- data.frame(startstop.duration = 20, res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, max.tunnels=max.tunnels, max.instances=max.instances, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, res.util.left=res.util.left, res.util.right=res.util.right, block.prob.left=block.prob.left, block.prob.right=block.prob.right)
  df <- rbind(df, data)
}

#path <- "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleStartStop/multiserver/"
path <- "F:/uni/ggsn-sim/evaluateFeasibleStartStop/multiserver/"

files <- list.files(path=path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][3])
  startstop.duration <- as.numeric(strsplit(f, "_")[[1]][4])
  sample.size <- nrow(data)
  block.prob.mean  <- mean(data$block.prob)
  block.prob.sdev  <- sd(data$block.prob)
  # 95% quantiles
  block.prob.max   <- quantile(data$block.prob, 0.95)
  block.prob.min   <- quantile(data$block.prob, 0.05)
  # 95% confidence intervals
  block.prob.error <- qnorm(0.975)*block.prob.sdev/sqrt(sample.size)
  block.prob.left  <- block.prob.mean-block.prob.error
  block.prob.right <- block.prob.mean+block.prob.error
  
  res.util.mean    <- mean(data$res.util)
  res.util.sdev    <- sd(data$res.util)
  # 95% quantiles
  res.util.min     <- quantile(data$res.util, 0.05)
  res.util.max     <- quantile(data$res.util, 0.95)
  # 95% confidence intervals
  res.util.error   <- qnorm(0.975)*res.util.sdev/sqrt(sample.size)
  res.util.left    <- res.util.mean-res.util.error
  res.util.right   <- res.util.mean+res.util.error
  data <- data.frame(startstop.duration = startstop.duration, res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, max.tunnels=max.tunnels, max.instances=max.instances, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, res.util.left=res.util.left, res.util.right=res.util.right, block.prob.left=block.prob.left, block.prob.right=block.prob.right)
  df <- rbind(df, data)
}

dfsub <- subset(df, max.instances == 100 & max.tunnels %in% c(20,40,60))
dfsub <- rbind(dfsub, subset(df, max.instances == 10 & max.tunnels %in% c(100,200,300,400,500)))
dfsub <- rbind(dfsub, subset(df, max.instances == 20 & max.tunnels %in% c(100,200,300)))
dfsub <- rbind(dfsub, subset(df, max.instances == 70 & max.tunnels %in% c(25,50,75)))


dfsub$startstop.levels <- factor(dfsub$startstop.duration, levels=c(20,60,120,180,240,300), ordered=T)
levels(dfsub$startstop.levels) <- c("20s","1min","2min","3min","4min","5min")

dfsub$instances.levels <- factor(dfsub$max.instances, levels=c(10,20,70,100), ordered=T)
levels(dfsub$instances.levels) <- c("10 instances", "20 instances", "70 instances", "100 instances")

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


## blocking probability barchart
p <- ggplot(dfsub, aes(x= max.tunnels, y= block.prob.mean, ymax = block.prob.right, ymin=block.prob.left, fill=startstop.levels))
p <- p + geom_bar(stat="identity", position="dodge", width=10) + geom_errorbar(position="dodge", width=10)
p <- p + facet_wrap(~ instances.levels, scales="free_x") + scale_y_continuous(limits=c(0,1))
p <- p + theme(text = element_text(family="Liberation Sans", size=20)) + ylab("blocking probability") + xlab("individual instance tunnel capacity")
p <- p + guides(fill=guide_legend("start/stop\nduration"))
p <- p + scale_fill_manual(values=cbPalette)
p
ggsave("R-virtualized-startstop-blocking-barchart.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-virtualized-startstop-blocking-barchart.pdf")
