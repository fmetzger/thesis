library(ggplot2)
#library(extrafont)
library(sysfonts)
library(Cairo)

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
year <- c(2014, 2015, 2016, 2017, 2018, 2019)


traffic.video <- c(1377.497, 2399.765, 4104.719, 6840.211, 10950.770, 17454.028)
tmp <- data.frame(traffic = traffic.video, year = year, source="Cisco", type = "video")
df <- rbind(df, tmp)

traffic.webdatavoip <- c(918.204, 1379.822, 2003.961, 2791.530, 3665.435, 4684.122)
tmp <- data.frame(traffic = traffic.webdatavoip, year = year, source="Cisco", type = "web, data, and voip")
df <- rbind(df, tmp)

traffic.filesharing <- c(35.574, 74.694, 141.316, 245.650, 391.052, 593.533)
tmp <- data.frame(traffic = traffic.filesharing, year = year, source="Cisco", type = "filesharing")
df <- rbind(df, tmp)

traffic.audiostreaming <- c(193.756, 323.915, 521.071, 801.106, 1157.536, 1623.894)
tmp <- data.frame(traffic = traffic.audiostreaming, year = year, source="Cisco", type = "audio streaming")
df <- rbind(df, tmp)


cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


p <- ggplot(df, aes(x=year, y=traffic, fill =as.factor(type))) + geom_bar(stat="identity", position="dodge")
p <- p + scale_x_continuous(breaks = year) + ylab("traffic (exabytes per month)")
p <- p + labs(fill = "traffic type") + theme(text = element_text(size=20))
p <- p + scale_fill_manual(values=cbPalette)
p
#ggsave("r-cisco-vni-2013.pdf", width=12, height=8, useDingbat=F)
ggsave("r-cisco-vni-2014.pdf", width=12, height=8)
#embed_fonts("r-cisco-vni-2013.pdf")

