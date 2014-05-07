library(ggplot2)

df <- data.frame()

path = "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleDimensioning/traditional/"
files <- list.files(path = path, pattern="metrics.*csv")
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
  data <- data.frame(res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, res.util.left=res.util.left, res.util.right=res.util.right, max.tunnels=max.tunnels, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, block.prob.left=block.prob.left, block.prob.right=block.prob.right, max.instances=1)
  df <- rbind(df, data)
}


path <- "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleMultiserver/multiserver"
files <- list.files(path = path, pattern="metrics.*csv")
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
  data <- data.frame(res.util.mean = res.util.mean, res.util.min=res.util.min, res.util.max=res.util.max, res.util.left=res.util.left, res.util.right=res.util.right, max.tunnels=max.tunnels, block.prob.mean=block.prob.mean, block.prob.max=block.prob.max, block.prob.min=block.prob.min, block.prob.left=block.prob.left, block.prob.right=block.prob.right, max.instances=max.instances)
  df <- rbind(df, data)
}

#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#CC79A7", "#CC79A7", "#CC79A7")
#df2 <- df[order(-as.numeric(factor(df$max.instances))),]

p <- ggplot(df, aes(x=max.tunnels * max.instances, y=block.prob.mean, ymin=block.prob.left, ymax=block.prob.right, color=as.factor(max.instances))) + geom_point(size=3) + geom_errorbar(width=100) + coord_cartesian(xlim=c(0,5200))
p + theme(text = element_text(size=20)) + ylab("blocking probability") + xlab("total supported tunnels") + guides(colour=guide_legend("supported\nvirtual\ninstances")) + scale_colour_brewer(palette="Paired")
ggsave("R-virtualized-blocking.pdf", width=12, height=10)


p <- ggplot(df, aes(x=max.tunnels * max.instances, y=res.util.mean, ymax = res.util.right, ymin=res.util.left, color=as.factor(max.instances))) +  geom_point(size=3) + geom_errorbar(width=100)+ coord_cartesian(xlim=c(0,5200))
p + theme(text = element_text(size=20)) + ylab("concurrent tunnels served on average") + xlab("total supported tunnels") + guides(colour=guide_legend("supported\nvirtual\ninstances")) + scale_colour_brewer(palette="Paired")
ggsave("R-virtualized-tunnelusage.pdf", width=12, height=10)
