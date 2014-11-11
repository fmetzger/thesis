library(ggplot2)
library(grid) # needed for arrow
library(extrafont)

# used dataset: hPUGNCIozp0_delay_2500, subset 1
# commandline: python ytresults_commandline.py hPUGNCIozp0_delay_2500 1 {nnbs,stbs,ytfa,ffh5} plotcumdata


plotbuffer <- function(csvfilestring){
  # precision too high for automatic numeric conversion, specify it manually
  d <- read.csv(csvfilestring, header=T, sep=",", colClasses=c("numeric", "numeric", "character"))
  
  t1 <- subset(d, type=="frame")
  diff <- diff(t1$size)
  t1$diff <- c(0,diff)
  
  t2 <- subset(d, type=="segment")
  diff <- diff(t2$size)
  t2$diff <- c(0,diff)
  
  d <- rbind(t1,t2)
  
  d <- d[with(d, order(timestamp)), ]
  
  d$sum <- 0
  
  for(i in 1:nrow(d)) {
    row <- d[i,]
    #print(row)
    if (i == 1) {
      d[i,5] <- d[i,4]
    } else {
      if (d[i, 3] == "segment") {
        d[i,5] <- d[i-1,5] + d[i,4]
      } else {  # "frame"
        d[i,5] <- d[i-1,5] - d[i,4]
      }
    }
    # do stuff with row
  }
  
  p <- ggplot(d, aes(x=timestamp, y=sum)) + geom_line(size = 1)
  p <- p + xlab("time (s)") + ylab("buffered data (KiB)") 
  p <- p + theme(text = element_text(family="Linux Biolinum", size=20))
  return(p)
}

p <- plotbuffer("/home/fm/git/thesis/data/streaming-eval-null-strategy.csv")
p
ggsave("R-bufferlevel-stall.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-bufferlevel-stall.pdf")


p <- plotbuffer("/home/fm/git/thesis/data/streaming-eval-flash-strategy.csv")
p
ggsave("R-bufferlevel-flash.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-bufferlevel-flash.pdf")


p <- plotbuffer("/home/fm/git/thesis/data/streaming-eval-startdelay-strategy.csv")
p
ggsave("R-bufferlevel-startdelay.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-bufferlevel-startdelay.pdf")


p <- plotbuffer("/home/fm/git/thesis/data/streaming-eval-firefox-strategy.csv")
p
ggsave("R-bufferlevel-firefox.pdf", width=12, height=8, useDingbat=F)
embed_fonts("R-bufferlevel-firefox.pdf")

