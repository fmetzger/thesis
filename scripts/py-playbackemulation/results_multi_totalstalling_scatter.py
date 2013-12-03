# -*- coding: utf-8 -*-
"""
Created on Thu Oct 13 09:18:44 2011

@author: fm
"""

import sys
import os
import os.path

import subprocess
import string

from numpy import *

import matplotlib.pyplot as plt

import pylab

###############################################################################
# confs 
#algs = ["ytfa"]
algs = ["ytfa","ffh5","nnbs","stbs"]
algnames = ["YouTube Flash", "Firefox 4 HTML5", "Initial Playback Delay", "Playback Stalling"]
#pltlinestyles = ['rx', 'gx', 'bx', 'kx']
colors = ['r', 'g', 'b', 'k']
pltlinestyles = ['rx']
normalized = True

###############################################################################
# parses all subfolders in the current folder plots all the



rootfolder = sys.argv[1]
tmproot = rootfolder

subvideoid = sys.argv[2]
if len(sys.argv) > 3:
    algs = [sys.argv[3]]
else:
    pass # list already preset
    
tmpdirs = os.listdir(os.path.abspath(rootfolder))
dirs = list()
for d in tmpdirs:
    t =  os.path.join(rootfolder,d)
    dirs.append(t)
#    print t


xvals = []
yvals = []

i = 0

while(i < 4):
    i += 1
    for d in dirs:
        if os.path.isdir(d):
          subdirs = os.listdir(d)
          for sd in subdirs:
              sdt = d + "/" + sd
              if sdt not in dirs:
                dirs.append(sdt)
#                print sdt
#              else:
#                print "already in"

        

#for d in dirs:
#    print d
  
i = 0

for alg in algs:

    vals = []


    
      

    for d in dirs:
    #  print os.path.abspath(d)
      if os.path.isdir(d):
#        print "isdir"


        if (str(subvideoid)+".log") in os.listdir(d):
            print "Calculating values for " + d
        
            dirsplit = string.split(d, "/")   # check only the deepest subfolder
            dirsplit = string.split(dirsplit[-2],"_")
	    # iterate reverse to avoid tripping over underscores in the video id
            videoid = dirsplit[-3]
            qostype = dirsplit[-2]
            qosparam = dirsplit[-1]
            
            command =  "python ytresults_commandline.py "+ d + " " + subvideoid + " " + alg + " statm"
            results_cli = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            results = results_cli.communicate()
        
            #print results
            
            ### parse output
            time = None
            totaltime = None
            for line in results:
              if line is not None:
                  if "time_stall_total=" in line:
                    s = string.split(line, "time_stall_total=")[1]
                    s = string.split(s, "\n")[0]
                    time = float(s)
                    print time
                    if time < 0:
                        print "Calculated time is negative. Something went wrong, skipping!"
                        continue
                    
                  if "time_play_total=" in line:
                      s = string.split(line, "time_play_total=")[1]
                      s = string.split(s, "\n")[0]
                      totaltime = float(s)
                      print totaltime
            if time is not None:
                if normalized:
                    time = time / totaltime
                    print time
                vals.append((float(qosparam), time))
            else:
                print "No result time present, file may be missing. Skipping."
        
    print len(vals)
    
    
    vals = sorted(vals, key=lambda x: x[0])
    
    
#    xvals.append([])
#    yvals.append([])
#xvals.append([])
#yvals.append([])
    
#    for tup in vals:
#        xvals[i].append(tup[0])
#        yvals[i].append(tup[1])
#    i += 1

    xvals.append([])
    yvals.append([])
    for tup in vals:
      xvals[i].append(tup[0])
      yvals[i].append(tup[1])
    i += 1
    

###############################################################################
# plotting

f = pylab.figure()
plt.hold(True)

for i in range(0, len(xvals)):
    print str(xvals[i]) + ": " + str(yvals[i])

for i in range(0, len(algs)):
    #plt.plot(xvals[0], yvals[0], 'r-', xvals[1], yvals[1], 'g-', xvals[2], yvals[2], 'g-', xvals[3], yvals[3], 'k-')
#    plt.plot(xvals[i], yvals[i], pltlinestyles[i], label=algnames[i])
     plt.scatter(xvals[i], yvals[i], marker='x', color=colors[i], label=algnames[i])


if qostype == "delay":
    plt.xlabel('additional latency (ms)')    
elif qostype == "loss":
    plt.xlabel('additional packet loss ratio')
else:
    plt.xlabel("unknown QoS type")
    

if normalized:
    plt.ylabel('total stalling time (relative to video duration)')
else:
    plt.ylabel('total stalling time (s)')
#    plt.xlim(0, 50)
algorithms = ','.join(str(n) for n in algs)
#plt.title(qostype + "series")
plt.grid(True)
#plt.savefig(self.sub_video_id+"bufferlevel_seconds")
#plt.figlegend()
plt.legend(loc="best")
plt.show()
        

"""      
    if os.path.exists(d + "/" + subvideoid + ".log"):
      myG = Graphs (d, subvideoid)
      (bufferlevels, frame_timestamps, total_offset) = myG.stallingbuffersizealg()
#      (bufferlevels, frame_timestamps, total_offset) = myG.nonnegativebuffersizealg()
      print "Total offset for " + d + " is " + str(total_offset)
      
      # resolve 3rd dir field (_-seperated)
      value = float(d.split("_")[-1])
      values.append((value, float(total_offset)))
      xvals.append(float(value))
    

values = sorted(values, key=lambda val: val[0])
xvals = sorted(xvals)
# xvals.sort(lambda a,b: cmp(int(a), int(b)))
yvals = []
for v in values:
  yvals.append(v[1])

f2 = pylab.figure()
plt.hold(True)
plt.plot(xvals, yvals, 'bo')  # points: 'r.'
plt.plot(xvals, yvals, 'k--', markerfacecolor='green')
#plt.xlabel('delay (ms)')
plt.ylabel('total stalling time (seconds)')
#plt.ylim(0, 3)
#plt.title("video quality metrics")
plt.grid(True)
plt.savefig("delaygraph")
plt.show()
"""
