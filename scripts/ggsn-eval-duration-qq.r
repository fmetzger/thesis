library(ggplot2)
#library(extrafont)
library(sysfonts)
library(Cairo)

servingtimes <- scan("/home/fm/svn/ursa/out/duration", dec=".")
st_dongle <- scan("/home/fm/svn/ursa/out/duration_dongles", dec=".") 
#st_regularphone <- scan("/home/fm/svn/ursa/out/duration_regularphone", dec=".")
st_smartphone <- scan("/home/fm/svn/ursa/out/duration_smartphone", dec=".")
#st_symbian <- scan("/home/fm/svn/ursa/out/duration_symbian", dec=".")
st_ios <- scan("/home/fm/svn/ursa/out/duration_ios", dec=".")
st_android <- scan("/home/fm/svn/ursa/out/duration_android", dec=".")

servingtimes_sampled <- sample(servingtimes, length(servingtimes)*0.01) # take a sample to not need to work with the whole dataset
st_dongle_sampled <- sample(st_dongle, length(st_dongle)*0.01)
#st_regularphone_sampled <- sample(st_regularphone, length(st_regularphone)*0.01)
st_smartphone_sampled <- sample(st_smartphone, length(st_smartphone)*0.01)
#st_symbian_sampled <- sample(st_symbian, length(st_symbian)*0.01)
st_ios_sampled <- sample(st_ios, length(st_ios)*0.01)
st_android_sampled <- sample(st_android, length(st_android)*0.01)

d <- data.frame()
t <- as.data.frame(qqplot(servingtimes_sampled, st_dongle_sampled, plot.it=FALSE))
t$type <- "dongle"
d <- rbind(d, t)
t <- as.data.frame(qqplot(servingtimes_sampled, st_smartphone_sampled, plot.it=FALSE))
t$type <- "smartphone"
d <- rbind(d, t)
t <- as.data.frame(qqplot(servingtimes_sampled, st_android_sampled, plot.it=FALSE))
t$type <- "Android"
d <- rbind(d, t)
t <- as.data.frame(qqplot(servingtimes_sampled, st_ios_sampled, plot.it=FALSE))
t$type <- "iOS"
d <- rbind(d, t)

#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(d) + geom_abline(intercept=0, slope=1, size=1, color="#999999") + geom_line(aes(x=x, y=y, color=type), size=1)
p <- p + scale_x_log10(limits=c(0.1,1000000)) + scale_y_log10(limits=c(0.1,1000000))
p <- p + ylab("duration distribution of subcategory") + xlab("total duration distribution")
p <- p + scale_color_manual(values=cbPalette, name="")
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p

#ggsave("R-duration-qq-category-comparison.pdf", width=12, height=8, useDingbats=F)
#embed_fonts("R-duration-qq-category-comparison.pdf")
ggsave("R-duration-qq-category-comparison.pdf", width=12, height=8, device=cairo_pdf)
