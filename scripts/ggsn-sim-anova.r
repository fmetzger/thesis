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

tmp$max.instances.levels <- factor(tmp$max.instances, levels=unique(df$max.instances), ordered=T)
var.test(tmp$max.instances.levels, tmp$block.prob)

######################################
library(compute.es)
library(lsr)
library(heplots)

df$total.tunnels <- df$max.instances*df$max.tunnels
df$max.tunnels.levels <- factor(df$max.tunnels, levels=unique(df$max.tunnels), ordered=T)
df$max.instances.levels <- factor(df$max.instances, levels=unique(df$max.instances), ordered=T)
df$start.duration.levels <- factor(df$start.duration, levels=unique(df$start.duration), ordered=T)

dfsub <- subset(df, total.tunnels <=5000)
dfsub <- subset(dfsub, start.duration != 20)

##
pb.tunnels.model <- aov(block.prob~max.tunnels.levels, data=dfsub)
summary(pb.tunnels.model)
etaSquared(pb.tunnels.model, anova=T)
omega.squared(pb.tunnels.model)

pb.instances.model <- aov(block.prob~max.instances.levels, data=dfsub)
summary(pb.instances.model)
etaSquared(pb.instances.model, anova=T)
omega.squared(pb.instances.model)

pb.start.model <- aov(block.prob~start.duration.levels, data=dfsub)
summary(pb.start.model)
etaSquared(pb.start.model, anova=T)
omega.squared(pb.start.model)
##

util.tunnels.model <- aov(res.util~max.tunnels.levels, data=dfsub)
summary(util.tunnels.model)
etaSquared(util.tunnels.model, anova=T)
omega.squared(util.tunnels.model)

util.instances.model <- aov(res.util~max.instances.levels, data=dfsub)
summary(util.instances.model)
etaSquared(util.instances.model, anova=T)
omega.squared(util.instances.model)

util.start.model <- aov(res.util~start.duration.levels, data=dfsub)
summary(util.start.model)
etaSquared(util.start.model, anova=T)
omega.squared(util.start.model)
##

oneway.test(block.prob ~ max.tunnels.levels, data=dfsub)

cor(dfsub$max.tunnels, dfsub$block.prob, use="complete.obs", method="pearson")
cor(dfsub$max.instances, dfsub$block.prob, use="complete.obs", method="pearson")
cor(dfsub$start.duration, dfsub$block.prob, use="complete.obs", method="pearson")

cor(dfsub$max.tunnels, dfsub$res.util, use="complete.obs", method="pearson")
cor(dfsub$max.instances, dfsub$res.util, use="complete.obs", method="pearson")
cor(dfsub$start.duration, dfsub$res.util, use="complete.obs", method="pearson")

# omega squared calculation, adapted from:
# http://www.estudiosfonicos.cchs.csic.es/metodolo/1/.Rprofile
omega.squared <- function (model) {
  if (class(model)[1]=="aov") {
    df.factors=0
    for (i in 2:dim(model$model)[2]) {
      df.factors=df.factors+length(levels(model$model[,i]))-1
    }
  }
  if (class(model)[1]=="lm") {
    df.factors=summary(model)$fstatistic[2]
  }
  
  nvariables = dim(model$model)[2]
  nobservations = dim(model$model)[1]
  ncontrasts = 0
  for (i in 2:nvariables) {
    ncontrasts = ncontrasts + length(as.factor(levels(as.factor(model$model[,i]))))-1
  }
  endeffects = ncontrasts+1
  startresiduals = ncontrasts+2
  sseffects = sum(model$effects[2:endeffects]^2)
  ssresiduals = sum(model$effects[startresiduals:nobservations]^2)
  
  omega.sq = (sseffects-(df.factors*(ssresiduals/model$df.residual)))/(sseffects+ssresiduals+(ssresiduals/model$df.residual))
  attr(omega.sq,"names") <- NULL
  return(omega.sq)
}

