library(ggplot2)

servingtimes <- scan("/home/fm/svn/ursa/out/duration", dec=".")
st_dongle <- scan("/home/fm/svn/ursa/out/duration_dongles", dec=".") 
st_regularphone <- scan("/home/fm/svn/ursa/out/duration_regularphone", dec=".")
st_smartphone <- scan("/home/fm/svn/ursa/out/duration_smartphone", dec=".")
st_symbian <- scan("/home/fm/svn/ursa/out/duration_symbian", dec=".")
st_ios <- scan("/home/fm/svn/ursa/out/duration_ios", dec=".")
st_android <- scan("/home/fm/svn/ursa/out/duration_android", dec=".")

# take 1% samples for easier handling
servingtimes_sampled <- sample(servingtimes, length(servingtimes)*0.01) # take a sample to not need to work with the whole dataset
st_dongle_sampled <- sample(st_dongle, length(st_dongle)*0.01)
st_regularphone_sampled <- sample(st_regularphone, length(st_regularphone)*0.01)
st_smartphone_sampled <- sample(st_smartphone, length(st_smartphone)*0.01)
st_symbian_sampled <- sample(st_symbian, length(st_symbian)*0.01)
st_ios_sampled <- sample(st_ios, length(st_ios)*0.01)
st_android_sampled <- sample(st_android, length(st_android)*0.01)

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

p <- ggplot(df, aes(x=st, color=as.factor(type))) + stat_ecdf() +  scale_x_log10() + coord_cartesian(xlim = c(0.5, 100000))
p + theme(text = element_text(size=20)) + ylab("cumulative probability") + xlab("tunnel duration (s)") + guides(color=guide_legend("", override.aes = list(size=4)))
ggsave("R-tunnel-duration-device-type.pdf", width=12, height=10)

