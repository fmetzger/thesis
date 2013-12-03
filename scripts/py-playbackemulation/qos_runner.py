#!/usr/bin/python

import os
import sys
import time


emu_reset = "ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc del dev eth0 root'"

# tc code taken from http://www.linuxfoundation.org/collaborate/workgroups/networking/netem

# outbound traffic auf 10mbit
# sudo tc qdisc add dev eth0 root handle 1: tbf rate 10mbit latency 1ms burst 1540
# inbound traffic auf 10mbit
# sudo tc qdisc change dev eth2 root handle 1: tbf rate 10mbit latency 100ms burst 1540

video_id = sys.argv[1] #"hPUGNCIozp0"
downrate = sys.argv[2]
uprate   = sys.argv[3]
burst    = sys.argv[4]

#reset eth0 and eth2
os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc del dev eth0 root'") # reset!
os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc del dev eth2 root'") # reset!



#down/up rate
#11.4.2011 - Measure without bandwith-limit (10 times)
#os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc add dev eth2 root handle 1: tbf rate "+str(downrate)+"kbit latency 6000ms burst "+str(burst)+"kb'")
#os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc add dev eth0 root handle 1: tbf rate "+str(uprate)+"kbit latency 6000ms burst "+str(burst)+"kb'")

#initial delay
# with down/up rate: os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc add dev eth0 parent 1:1 netem delay 0ms 0ms'") #
os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc add dev eth0 root netem delay 0ms 0ms'") #

#os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc add dev eth2 root handle 1: tbf rate 10mbit latency 5001ms burst 10kb'")

delay = 0

while delay <= 5000:
  # reconfigure tc via ssh
  # ssh -i ~/.ssh/id_dsa.key root@netfpga
  #  os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc change dev eth0 parent 1:1 netem delay " + str(delay) + "ms 0ms'") # no jitter in these runs!
  os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc change dev eth0 root netem delay " + str(delay) + "ms 0ms'") # no jitter in these runs! and without bandwith

  print "Starting run with " + str(delay) +"ms delay"
  os.system("./ytdl.py " + video_id)
  os.rename(video_id, video_id+"_delay_"+str(delay))
  delay = delay + 100
  

os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc del dev eth0 root'") # reset!
os.system("ssh -i ~/.ssh/id_dsa root@netfpga \'tc qdisc del dev eth2 root'") # reset!
