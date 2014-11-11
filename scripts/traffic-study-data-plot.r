library(ggplot2)
library(extrafont)

# data sources:
# cisco global visual networking index 2012-2017
#http://www.cisco.com/c/en/us/solutions/collateral/service-provider/ip-ngn-ip-next-generation-network/white_paper_c11-481360.html
#http://www.cisco.com/c/en/us/solutions/collateral/service-provider/visual-networking-index-vni/VNI_Hyperconnectivity_WP.html
# cisco mobile vni 2013-2018
# http://www.cisco.com/c/en/us/solutions/collateral/service-provider/visual-networking-index-vni/white_paper_c11-520862.html
# sandvine internet phenomena report Q1/2 2014
# https://www.sandvine.com/downloads/general/global-internet-phenomena/2014/1h-2014-global-internet-phenomena-report.pdf


df <- data.frame()
# unit: exabyte
#traffic.total <- c(43.570, 55.553, 68.892, 83.835, 101.055, 120.643)
year <- c(2012, 2013, 2014, 2015, 2016, 2017)


traffic.video.managed <- c(8.835, 11.686, 14.640, 17.609, 20.414, 22.946)
tmp <- data.frame(traffic = traffic.video.managed, year = year, source="Cisco", type = "managed video")
df <- rbind(df, tmp)

traffic.video.internet <- c(14.818, 19.855, 25.800, 32.962, 41.916, 52.752)
tmp <- data.frame(traffic = traffic.video.internet, year = year, source="Cisco", type = "internet video")
df <- rbind(df, tmp)

traffic.filesharing <- c(6.201, 7.119, 7.816, 8.266, 8.478, 8.667)
tmp <- data.frame(traffic = traffic.filesharing, year = year, source="Cisco", type = "filesharing")
df <- rbind(df, tmp)

traffic.web <- c(5.173, 6.336, 7.781, 9.542, 11.828, 14.494)
tmp <- data.frame(traffic = traffic.web, year = year, source="Cisco", type = "web, email, and data")
df <- rbind(df, tmp)

traffic.business <- c(8.522, 10.530, 12.822, 15.417, 18.372, 21.724)
tmp <- data.frame(traffic = traffic.business, year = year, source="Cisco", type = "business")
df <- rbind(df, tmp)

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


p <- ggplot(df, aes(x=year, y=traffic, fill =as.factor(type))) + geom_bar(stat="identity", position="dodge")
p <- p + scale_x_continuous(breaks = year) + ylab("traffic (exabytes per month)")
p <- p + labs(fill = "traffic type") + theme(text = element_text(family="Linux Biolinum", size=20))
p <- p + scale_fill_manual(values=cbPalette)
p
ggsave("r-cisco-vni-2013.pdf", width=12, height=8, useDingbat=F)
embed_fonts("r-cisco-vni-2013.pdf")


###############
## netvine

df <- data.frame()

types <- c("other", "tunneling", "marketplaces", "communications", "filesharing", "web browsing", "real time entertainment")

ratio.2009 <- c(0.098, 0.046, 0, 0, 0.151, 0.387, 0.318)
tmp <- data.frame(ratio = ratio.2009, year = "2009", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2010 <- c(0.148, 0, 0, 0.031, 0.192, 0.202, 0.427)
tmp <- data.frame(ratio = ratio.2010, year = "2010", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2011 <- c(0.138, 0, 0.038, 0.023, 0.143, 0.166, 0.492)
tmp <- data.frame(ratio = ratio.2011, year = "2011", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2012 <- c(0.097, 0, 0.04, 0.03, 0.12, 0.127, 0.586)
tmp <- data.frame(ratio = ratio.2012, year = "2012", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2013 <- c(0.119, 0, 0.0395, 0, 0.0893, 0.1040, 0.6486)
tmp <- data.frame(ratio = ratio.2013, year = "2013", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2014.1h <- c(0.1035, 0.0452, 0.0623, 0, 0.0675, 0.1306, 0.5909)
tmp <- data.frame(ratio = ratio.2014.1h, year = "2014, 1h", source="Netvine", types=types)
df <- rbind(df, tmp)

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(df, aes(x=year, y=ratio, fill =as.factor(types))) + geom_bar(stat="identity", position="dodge")
p <- p + ylab("aggregate traffic ratio")
p <- p + labs(fill = "traffic type") + theme(text = element_text(family="Linux Biolinum", size=20))
p <- p + scale_fill_manual(values=cbPalette)
p
ggsave("r-netvine-phenomena-fixed.pdf", width=12, height=8, useDingbat=F)
embed_fonts("r-netvine-phenomena-fixed.pdf")

# netvine mobile

df <- data.frame()

types <- c("other", "tunneling", "marketplaces", "social networking", "web browsing", "real time entertainment")

ratio.2012 <- c(0.079, 0.103, 0.054, 0.105, 0.160, 0.499)
tmp <- data.frame(ratio = ratio.2012, year = "2012", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2013 <- c(0.0765, 0.0877, 0.0948, 0.2189, 0.1468, 0.3753)
tmp <- data.frame(ratio = ratio.2013, year = "2013", source="Netvine", types=types)
df <- rbind(df, tmp)

ratio.2014.1h <- c(0.0938, 0.0953, 0.0853, 0.2287, 0.1363, 0.3607)
tmp <- data.frame(ratio = ratio.2014.1h, year = "2014, 1h", source="Netvine", types=types)
df <- rbind(df, tmp)

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

p <- ggplot(df, aes(x=year, y=ratio, fill =as.factor(types))) + geom_bar(stat="identity", position="dodge")
p <- p + ylab("aggregate traffic ratio")
p <- p + labs(fill = "traffic type") + theme(text = element_text(family="Linux Biolinum", size=20))
p <- p + scale_fill_manual(values=cbPalette)
p
ggsave("r-netvine-phenomena-mobile.pdf", width=12, height=8, useDingbat=F)
embed_fonts("r-netvine-phenomena-mobile.pdf")
