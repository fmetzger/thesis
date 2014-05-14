library(ggplot2)
library(stats)
library(extrafont)

df <- data.frame()

path = "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleDimensioning/traditional/"
files <- list.files(path = path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- 1
  total.tunnels <- max.tunnels * max.instances
  startstop.duration <- 20
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
  data <- data.frame(res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, res.util.left=res.util.left, res.util.right=res.util.right, max.tunnels=max.tunnels, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, block.prob.left=block.prob.left, block.prob.right=block.prob.right, max.instances=max.instances, startstop.duration=startstop.duration, total.tunnels = total.tunnels)
  df <- rbind(df, data)
}


path <- "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleMultiserver/multiserver"
files <- list.files(path = path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][3])
  startstop.duration <- 20
  total.tunnels <- max.tunnels * max.instances
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
  data <- data.frame(res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, res.util.left=res.util.left, res.util.right=res.util.right, max.tunnels=max.tunnels, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, block.prob.left=block.prob.left, block.prob.right=block.prob.right, max.instances=max.instances, startstop.duration=startstop.duration, total.tunnels = total.tunnels)
  df <- rbind(df, data)
}

path = "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleStartStop/multiserver/"
files <- list.files(path = path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][3])
  startstop.duration <- as.numeric(strsplit(f, "_")[[1]][4])
  total.tunnels <- max.tunnels * max.instances
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
  data <- data.frame(res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, res.util.left=res.util.left, res.util.right=res.util.right, max.tunnels=max.tunnels, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, block.prob.left=block.prob.left, block.prob.right=block.prob.right, max.instances=max.instances, startstop.duration=startstop.duration, total.tunnels = total.tunnels)
  df <- rbind(df, data)
}



dfsub1 = subset(df, max.instances == 1 & startstop.duration == 20 & total.tunnels == 4500)
dfsub2 = subset(df, max.instances == 30 & startstop.duration == 20 & total.tunnels == 4500)
dfsub3 = subset(df, max.instances == 60 & startstop.duration == 300 & total.tunnels == 4500)
dfsub <- rbind(dfsub1, dfsub2, dfsub3)


dfsub$max.tunnels = factor(dfsub$max.tunnels, c(4500, 150, 75))
dfsub$max.instances = factor(dfsub$max.instances)
dfsub$relative.blocking.probability <- dfsub$block.prob.mean / subset(dfsub, max.instances == 1)$block.prob.mean
dfsub$relative.blocking.probability.max <- dfsub$block.prob.max / subset(dfsub, max.instances == 1)$block.prob.mean
dfsub$relative.blocking.probability.min <- dfsub$block.prob.min / subset(dfsub, max.instances == 1)$block.prob.mean
dfsub$relative.blocking.probability.right <- dfsub$block.prob.right / subset(dfsub, max.instances == 1)$block.prob.mean
dfsub$relative.blocking.probability.left <- dfsub$block.prob.left / subset(dfsub, max.instances == 1)$block.prob.mean

#or <-  order(dfsub$max.tunnels, decreasing=T)
#dfsub <- dfsub[or, ]


p <- ggplot(dfsub, aes(x=max.tunnels,y=relative.blocking.probability,ymin=relative.blocking.probability.left,ymax=relative.blocking.probability.right))
p <- p + geom_point(stat = "identity", size=2) + geom_errorbar(width=1)
p <- p + scale_x_discrete() + scale_y_continuous(limits = c(0, 2))
p + theme(text = element_text(family="Liberation Sans Narrow", size=20)) + xlab("individual instance tunnel capacity") + ylab("relative increase of\nblocking probability")
ggsave("blocking-comparison.pdf", width=12, height=10, useDingbat=F)

