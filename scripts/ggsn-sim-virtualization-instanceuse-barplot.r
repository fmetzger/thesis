library(ggplot2)
library(reshape2)
library(plyr)


df <- data.frame()

path <- "/home/fm/Documents/projekte/ggsn-sim/results/combined/"
files <- list.files(path = path, pattern="instance_use_distribution.*csv")
for (f in files) {
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][4])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][5])
  start.up <- as.numeric(strsplit(f, "_")[[1]][6])
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, sep=";")
  
  data <- data[,!(names(data) %in% c("V1", "V2"))]
  
  x <- colMeans(data)
  x <- melt(x)
#  norm <- max(x)
#  x <- x / norm
  colnames(x) <- "mean"

  # 95% confidence intervals
  sdev <- t(numcolwise(function(x) sd(x))(as.data.frame(t(apply(data, 1, cumsum)))))
  colnames(sdev) <- "stddev"
  sample.size <- nrow(data)
  error <- qnorm(0.975)*sdev/sqrt(sample.size)
  left  <- x-error
  colnames(left) <- "left"
  right <- x+error
  colnames(right) <- "right"
  means <- cbind(x,sdev,left,right)
  
  means$N <- seq(1:nrow(means))
  means$max.tunnels <- max.tunnels
  means$max.instances <- max.instances
  means$start.up <- start.up
  df <- rbind(df, means)
}


#dfsub <- subset(df, max.instances %in% c(30, 60))
#dfsub <- subset(dfsub, max.tunnels %in% c(150, 300))
#dfsub <- subset(df, max.instances %in% c(30, 60))
#dfsub <- subset(dfsub, max.tunnels %in% c(75, 150))
#dfsub <- subset(dfsub, start.up %in% c(300))

dfsub1 <- subset(df, start.up %in% c(300) & max.tunnels %in% c(150) & max.instances %in% c(30))
dfsub2 <- subset(df, start.up %in% c(300) & max.tunnels %in% c(150) & max.instances %in% c(60) & N < 34)
dfsub3 <- subset(df, start.up %in% c(300) & max.tunnels %in% c(300) & max.instances %in% c(30) & N < 18)
dfsub4 <-  subset(df, max.tunnels %in% c(300) & max.instances %in% c(60) & N < 18)

dfsub <- rbind(dfsub1,dfsub2,dfsub3,dfsub4)

facet.label = function(variable, value) {
  value <- as.character(value)
  if (variable=="max.instances") { 
    value[value=="30"] <- "30 instances"
    value[value=="60"] <- "60 instances"
  }
  if (variable=="max.tunnels") { 
    value[value=="150"] <- "tunnel capacity: 150"
    value[value=="300"] <- "tunnel capacity: 300"
  }
  
  return(value)
}


p <- ggplot(dfsub, aes(x=N, y=mean, ymin=left, ymax=right)) + geom_bar(stat="identity", position="dodge")
p <- p + geom_errorbar(position="dodge", width=0.25) + facet_grid(max.instances ~ max.tunnels, scales="free_x", space="free_x", labeller = facet.label)
p + theme(text = element_text(family="Liberation Sans Narrow", size=20)) + ylab("relative duration") + xlab("number of active instances")
ggsave("R-virtualized-instanceuse-barplot.pdf", width=12, height=10, useDingbat=F)
