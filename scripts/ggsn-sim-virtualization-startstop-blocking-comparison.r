library(ggplot2)
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


df$total.tunnels <- df$max.tunnels * df$max.instances

dfsub <- subset(df, total.tunnels <= 5000 & startstop.duration %in% c(60, 300) &  max.instances %in% c(40, 100))

dfsub$startstop.levels <- factor(dfsub$startstop.duration, levels=c(60,300), ordered=T)
levels(dfsub$startstop.levels)<- c("1min", "5min")

label_full_name <- function(variable, values) {
  sprintf("%s instances", as.character(values))
}

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


p <- ggplot(dfsub, aes(x = res.util.mean,y = block.prob.mean,shape = as.factor(max.tunnels), color = startstop.levels))
p <- p + geom_point(size=4) + facet_grid(~ max.instances, labeller = label_full_name)
p <- p + scale_x_continuous(name = "concurrent tunnels served on average") + scale_y_log10(name = "blocking probability")
p <- p + scale_shape(name = "individual instance\ntunnel capacity", solid=T, guide = guide_legend(nrow = 3))
p <- p + scale_color_manual(values=cbPalette)
p <- p + labs(colour = "start/stop duration") + theme(text = element_text(family="Liberation Sans Narrow", size=20)) 
p

ggsave("R-virtualized-startstop-tunnelusage-blocking-comparison.pdf", width=12, height=6, useDingbats=F)
embed_fonts("R-virtualized-startstop-tunnelusage-blocking-comparison.pdf")
