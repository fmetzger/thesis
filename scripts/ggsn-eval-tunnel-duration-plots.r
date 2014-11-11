library(ggplot2)
library(extrafont)

servingtimes <- scan("/home/fm/svn/ursa/out/duration", dec=".")
st_dongle <- scan("/home/fm/svn/ursa/out/duration_dongles", dec=".") 
st_regularphone <- scan("/home/fm/svn/ursa/out/duration_regularphone", dec=".")
st_smartphone <- scan("/home/fm/svn/ursa/out/duration_smartphone", dec=".")
st_symbian <- scan("/home/fm/svn/ursa/out/duration_symbian", dec=".")
st_ios <- scan("/home/fm/svn/ursa/out/duration_ios", dec=".")
st_android <- scan("/home/fm/svn/ursa/out/duration_android", dec=".")


# take 1% samples for easier handling
servingtimes_sampled <- sample(servingtimes, length(servingtimes)*0.005) # take a sample to not need to work with the whole dataset
st_dongle_sampled <- sample(st_dongle, length(st_dongle)*0.005)
st_regularphone_sampled <- sample(st_regularphone, length(st_regularphone)*0.005)
st_smartphone_sampled <- sample(st_smartphone, length(st_smartphone)*0.005)
st_symbian_sampled <- sample(st_symbian, length(st_symbian)*0.005)
st_ios_sampled <- sample(st_ios, length(st_ios)*0.005)
st_android_sampled <- sample(st_android, length(st_android)*0.005)

df <- data.frame()
x <- data.frame(st=servingtimes_sampled, type="total")
df <- rbind(df,x)
x <- data.frame(st=st_dongle_sampled, type="dongle")
df <- rbind(df,x)
x <- data.frame(st=st_regularphone_sampled, type="regular")
df <- rbind(df,x)
x <- data.frame(st=st_smartphone_sampled, type="smartphone")
df <- rbind(df,x)

#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(df, aes(x=st, color=as.factor(type))) + stat_ecdf(size=1) +  scale_x_log10()
p <- p + coord_cartesian(xlim = c(0.5, 1000000)) + geom_hline(yintercept=0.5, color="#999999") + annotation_logticks(sides="b")
p <- p + ylab("cumulative probability") + xlab("tunnel duration (s)") + guides(color=guide_legend("", override.aes = list(size=4)))
p <- p + scale_color_manual(values=cbPalette)
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
ggsave("R-tunnel-duration-device-type.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-tunnel-duration-device-type.pdf")



df <- data.frame()
x <- data.frame(st=servingtimes_sampled, type="total")
df <- rbind(df,x)
x <- data.frame(st=st_symbian_sampled, type="symbian")
df <- rbind(df,x)
x <- data.frame(st=st_android_sampled, type="android")
df <- rbind(df,x)
x <- data.frame(st=st_ios_sampled, type="ios")
df <- rbind(df,x)


p <- ggplot(df, aes(x=st, color=as.factor(type))) + stat_ecdf(size=1) +  scale_x_log10()
p <- p + coord_cartesian(xlim = c(0.5, 1000000)) + geom_hline(yintercept=0.5, color="#999999") + annotation_logticks(sides="b")
p <- p + ylab("cumulative probability") + xlab("tunnel duration (s)") + guides(color=guide_legend("", override.aes = list(size=4)))
p <- p + scale_color_manual(values=cbPalette)
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
ggsave("R-tunnel-duration-operating-system.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-tunnel-duration-operating-system.pdf")



servingtimes_sampled <- sample(servingtimes, length(servingtimes)*0.1) # take a sample to not need to work with the whole dataset
st_dongle_sampled <- sample(st_dongle, length(st_dongle)*0.1)
st_regularphone_sampled <- sample(st_regularphone, length(st_regularphone)*0.1)
st_smartphone_sampled <- sample(st_smartphone, length(st_smartphone)*0.1)
st_symbian_sampled <- sample(st_symbian, length(st_symbian)*0.1)
st_ios_sampled <- sample(st_ios, length(st_ios)*0.1)
st_android_sampled <- sample(st_android, length(st_android)*0.1)

df <- data.frame()
x <- data.frame(st=servingtimes_sampled, type="total")
df <- rbind(df,x)
x <- data.frame(st=st_dongle_sampled, type="dongle")
df <- rbind(df,x)
x <- data.frame(st=st_regularphone_sampled, type="regular")
df <- rbind(df,x)
x <- data.frame(st=st_smartphone_sampled, type="smartphone")
df <- rbind(df,x)
x <- data.frame(st=st_symbian_sampled, type="symbian")
df <- rbind(df,x)
x <- data.frame(st=st_android_sampled, type="android")
df <- rbind(df,x)
x <- data.frame(st=st_ios_sampled, type="ios")
df <- rbind(df,x)

cbPalette <- c( "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(df, aes(x=st, color=as.factor(type), fill=as.factor(type))) + geom_density(adjust=0.5, size=1, alpha=0.3)
p <- p + scale_x_log10(limits=c(0.2, 1000000)) + xlab("tunnel duration (s)")
p <- p + annotation_logticks(sides="b")
p <- p + scale_color_manual(values=cbPalette, name="") + scale_fill_manual(values=cbPalette, name="")
p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
p
ggsave("R-duration-classification-density.pdf", width=12, height=8, useDingbats=F)
embed_fonts("R-duration-classification-density.pdf")
