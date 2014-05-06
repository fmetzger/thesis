library(lsr)
library(ez)
library(pwr)


path = "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleDimensioning/traditional/"
df <- data.frame()
files <- list.files(path = path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  data$max.tunnels <- max.tunnels
  data$max.instances <- 1
  data$start.duration <- 20
  df <- rbind(df, data)
}

path = "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleMultiserver/multiserver"
files <- list.files(path = path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][3])
  data$max.tunnels <- max.tunnels
  data$max.instances <- max.instances
  data$start.duration <- 20
  df <- rbind(df, data)
}

path = "/home/fm/Documents/projekte/ggsn-sim/results/evaluateFeasibleStartStop/multiserver/"
files <- list.files(path = path, pattern="metrics.*csv")
for (f in files){
  data <- read.table(sprintf("%s/%s", path, f), header=FALSE, colClasses = c("integer", "numeric", "numeric"),  col.names = c("seed", "res.util", "block.prob"), sep=";") 
  max.tunnels <- as.numeric(strsplit(f, "_")[[1]][2])
  max.instances <- as.numeric(strsplit(f, "_")[[1]][3])
  start.duration <- as.numeric(strsplit(f, "_")[[1]][4])
  data$max.tunnels <- max.tunnels
  data$max.instances <- max.instances
  data$start.duration <- start.duration
  df <- rbind(df, data)
}

fit <- aov(block.prob ~ max.tunnels, data=df)
fit
summary(fit)
plot(fit)
oneway.test(block.prob ~ max.tunnels, data=df)
var.test(df$max.tunnels, df$block.prob)

etaSquared(fit, anova=T)

?ezANONVA
?pwr.f2.test
# filter double entries or not?
