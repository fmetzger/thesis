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

#df$max.instances = factor(df$max.instances)
#acceptable.tunnel.count = df[with(df, order(max.tunnels)), ]

p <- ggplot(df, aes(x=max.tunnels,y=block.prob.mean,ymin=block.prob.left,ymax=block.prob.right)) +  geom_line() + geom_errorbar(width=100) + coord_cartesian(xlim=c(0,5200), ylim = c(-0.1, 1.1))
p + theme(text = element_text(size=20)) + xlab("total supported tunnels") + ylab("blocking probability")
ggsave("R-monolithic-blocking.pdf", width=12, height=10)

p <- ggplot(df, aes(x=max.tunnels,y=res.util.mean,ymin=res.util.left,ymax=res.util.right)) +  geom_line() + geom_errorbar(width=100) + coord_cartesian(xlim=c(0,5200))
p + theme(text = element_text(size=20)) + xlab("total supported tunnels") + ylab("concurrent tunnels served on average")
ggsave("R-monolithic-tunnelusage.pdf", width=12, height=10)
