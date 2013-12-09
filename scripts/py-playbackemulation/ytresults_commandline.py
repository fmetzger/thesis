#!/usr/bin/python
"""
Plots the results

"""
import math
import sys
import os

from datetime import datetime, date, time, timedelta
from time import gmtime, strftime

import numpy
import csv

import matplotlib.pyplot as plt
import pylab
import matplotlib


import results_classes
import results_helpermethods
import results_plotting
import results_playbackmodels


# Functions and classes


    
###############################################################################

class Graphs:
  

################################################################################
# constructor
  def __init__(self, vid, svid):
  
    self.video_id = ""   # the subfolder and video id
    self.sub_video_id = ""  # which of the video qualities to process
    
    self.video_framerate = 0
    self.video_filesize = 0  
    self.overall_bitrate = 0 # in kbit/s!

    self.video_width = 0
    self.video_height = 0
    
    self.framelist = []
    self.frame_timestamps = []
    
    self.download_timestamps = []
    self.download_bytes = []
  
  
    self.video_id = vid
    self.sub_video_id = svid
    
    print ("videoid=" + self.video_id)
    os.chdir(self.video_id)
    
    self.loadlog()
        
    self.generateframelist()
    
    self.generatedownloadtraces()
    
    os.chdir("..")
################################################################################


################################################################################
# load generic data from the log
# extract file size and frame

  def loadlog(self):
  
    log_in = open(str(self.sub_video_id) + ".log", 'r')
    for log_in_line in log_in:

      # alternative method to acquire file size
      if log_in_line.startswith("file_size") and self.video_filesize is 0:
        self.video_filesize = int(log_in_line.partition(": ")[2].rstrip())
        print "filesize=" + str(self.video_filesize)
      
    if os.path.exists(str(self.sub_video_id) + ".mediainfo"):
      mediainfo_in = open(str(self.sub_video_id) + ".mediainfo", 'r')
      for mediainfo_line in mediainfo_in:
        if "Frame rate" in mediainfo_line and not "Frame rate mode" in mediainfo_line and self.video_framerate is 0:
          self.video_framerate = float(mediainfo_line.partition(": ")[2].rstrip())
          print "framerate=" + str(self.video_framerate)
        
        if "Overall bit rate" in mediainfo_line and not "Kbps" and not "mode" in mediainfo_line and self.overall_bitrate is 0:
          self.overall_bitrate = float(mediainfo_line.partition(": ")[2].rstrip())
          print "avg_bitrate=" + str(self.overall_bitrate/1000/8) + " kbyte/s"

        if "Width" in mediainfo_line and not "pixels" in mediainfo_line and self.video_width is 0:
          self.video_width = float(mediainfo_line.partition(": ")[2].rstrip())
          print "video_width=" + str(self.video_width)

        if "Height" in mediainfo_line and not "pixels" in mediainfo_line and self.video_height is 0:
          self.video_height = float(mediainfo_line.partition(": ")[2].rstrip())
          print "video_height=" + str(self.video_height)

      mediainfo_in.close()
    else:
      print str(self.sub_video_id) + ".mediainfo file missing. Incomplete or legacy results?"
      raise Exception(str(self.sub_video_id) + ".mediainfo file missing. Incomplete or legacy results?")
      # sys.exit(2)
    
      
################################################################################



################################################################################
# process the frame trace 
  def generateframelist(self):
  
    f_trace_in = open(str(self.sub_video_id) + ".framelog", 'r')
    
    for f_trace_line in f_trace_in:
      f = results_classes.Frame()
      #remove the "frame=" and strip the spaces to begin with the frame number, then partition at the q= and return the first and last datum
      (f_number, sep, f_trace_line) = f_trace_line[6:].lstrip().partition(" q= ") 
      f.number = f_number
      
      (unused, sep,f_trace_line) = f_trace_line.partition("f_size=")
      (f_size, sep, f_trace_line) = f_trace_line.lstrip().partition(" s_size= ")
      f.size = f_size
      
      
      (unused, sep, f_trace_line) = f_trace_line.partition("time= ")
      (f_time, sep, f_trace_line) = f_trace_line.partition(" br=")
      f.time = f_time
      
      (frate,sep,f_trace_line) = f_trace_line.partition("kbits/s avg_br=")
      
      f.avgrate = frate.lstrip()
      
      (unused, sep, f_type) = f_trace_line.partition("type= ")
      f.ftype = f_type[0]
      
      self.framelist.append(f)
      
    self.frame_timestamps = [0]
    for frame in self.framelist:
      self.frame_timestamps.append(frame.time)

    self.video_duration = self.frame_timestamps[-1] #save the last frame timestamp as video duration
    
    f_trace_in.close()
################################################################################



################################################################################
# process the download trace 
  def generatedownloadtraces(self):
  
    trace_in = open(str(self.sub_video_id) + ".downloadlog",'r')

    self.download_timestamps.append(timedelta()) # append a zero timestamp
    ts_old = None
      
    for trace_line in trace_in:

      # consider only the incoming packets (atm)
      
      if "<=" in trace_line:        # TODO: discern between Recv header and Recv data
        ts_string = trace_line[:15]
        ts = datetime.strptime(ts_string, "%H:%M:%S.%f")
        if ts_old is not None:
          ts_delta = (ts - ts_old) + self.download_timestamps[-1]
          ts_old = ts
          self.download_timestamps.append(ts_delta)

        ts_old = ts

        self.download_bytes.append(int(trace_line.partition(", ")[2].split(" ")[0]))
        
    trace_in.close()
################################################################################

        


################################################################################
  def stallingalgorithm(self, alg):
      stallalgfunc = None
      if (alg == "nnbs"):
        stallalgfunc = results_playbackmodels.nonnegativebuffersizealg
      elif (alg == "stbs"):
        stallalgfunc = results_playbackmodels.faststallingbuffersizealg
      elif (alg == "ytfa"):
        stallalgfunc = results_playbackmodels.ytflashalg
      elif (alg == "ffh5"):
        stallalgfunc = results_playbackmodels.firefoxhtml5alg
      elif (alg == "scal"):
        stallalgfunc = results_playbackmodels.scalingbufferalg
      else:
        print "Algorithm not supported (" + alg + ")"
        sys.exit(2)
        
      (bufferlevels, frame_timestamps, total_offset, stalls) = stallalgfunc(self.framelist, self.frame_timestamps, self.download_timestamps, self.download_bytes, self.video_filesize)
      
      return (bufferlevels, frame_timestamps, total_offset, stalls)
################################################################################



################################################################################
  def plotbuffer(self, bufferlevel, subtitlestring=""):
      results_plotting.plotbuffer(bufferlevel, self.video_id, self.sub_video_id, subtitlestring="")
################################################################################


###############################################################################
  def plotbufferseconds(self, bufferlevel, timestamps, subtitlestring=""):
      results_helpermethods.calcBufferlevelsInSeconds(bufferlevel, timestamps, self.frame_timestamps, self.framelist, self.video_filesize)
      results_plotting.plotbufferseconds(bufferlevel, self.video_id, self.sub_video_id, subtitlestring)

###############################################################################


###############################################################################
  def plotbinneddownloadbytes(self, binsize):
        """ """
        results_plotting.plotbinneddownloadbytes(self.download_timestamps, self.download_bytes, self.video_id, self.sub_video_id, binsize)
###############################################################################


###############################################################################
  def plotadditiveframedownloadbytes(self, frame_timestamps):
        results_plotting.plotadditiveframedownloadbytes(self.download_timestamps, self.download_bytes, self.video_filesize, self.framelist, frame_timestamps, self.video_id, self.sub_video_id)
###############################################################################

###############################################################################
  def plotdownloadvsframerate(self, binsize = 1):
        """ """
        results_plotting.plotdlvsfrrate(self.download_timestamps, self.download_bytes, self.video_filesize, self.framelist, self.video_id, self.sub_video_id, binsize)


###############################################################################
####
  def printStallStatsH(self, stalls):
    print("")
    print("Stalling stats:")
    print("")
    stcnt = 0
    stlen = 0
    plcnt = 0
    pllen = 0
    for i in range(len(stalls)):
      print(stalls[i].type + " from " + str(stalls[i].start) + " to " + str(stalls[i].end) + ". Length: "+str(stalls[i].end-stalls[i].start))
      if(stalls[i].type == "Stall"):
        stcnt = stcnt + 1
        stlen = stlen + (stalls[i].end-stalls[i].start)
      else:
        plcnt = plcnt + 1
        pllen = pllen + (stalls[i].end-stalls[i].start)
    print("")
    print("Number of stalls: "+str(stcnt)+". Total stalling time: "+str(stlen)) 
    print("Number of playbacks: "+str(plcnt)+". Total playback time: "+str(pllen)) 
###############################################################################


###############################################################################
# Machine readable stat output
  def printStallStatsM(self, stalls):
    print("")
    print("Stalling stats:")
    print("")
    stcnt = 0
    stlen = 0
    plcnt = 0
    pllen = 0
    
    num = None
    for i in range(len(stalls)):
      if(stalls[i].type == "Stall"):
        stcnt = stcnt + 1
        num = stcnt
        stlen = stlen + (stalls[i].end-stalls[i].start)
      else:
        plcnt = plcnt + 1
        num = plcnt
        pllen = pllen + (stalls[i].end-stalls[i].start)
        
      print(str(i) + ": " + stalls[i].type + "=" + str(i) + "; start=" + str(stalls[i].start) + "; end:" + str(stalls[i].end) + "; duration="+str(stalls[i].end-stalls[i].start))

    print("")
    print("num_stalls="+str(stcnt))
    print("time_stall_total="+str(stlen)) 
    print("num_playruns="+str(plcnt))
    print("time_play_total="+str(pllen)) 
###############################################################################


###############################################################################
def usage():
  print ""
  print "Usage:"
  print ""
  print "ytresults.py <video_id> <subvideo_id> <algorithm> <output_mode> <mode_options>"
  print "  <video_id> - the subfolder to process"
  print "  <subvideo_id> - quality to process"
  print "  <algorithm> - the buffering algorithm to use"
  print "  <output_mode> - what to output"
  print "  <mode_options> - optional options to the chosen output mode"
  print ""
  print "Output modes:"
  print "  stath: Human readable text stat only output"
  print "  statm: Machine readable and parsable text stat only output"
  print "  plotbuffer: plots the buffer fill level in available video data volume"
  print "  plotbuffertime: plots the buffer fill level in available video time"
  print "  plotrates: plots the download and frame rate sizes (default resolution: 1s)"
  print "  plotcumdata: plots the cumulative transmitted and played data"
  print ""
  print "Supported algorithms; use the abbrevation in braces:"
  print "  1. Non-negative buffer size (nnbs):"
  print "    - The algorithm starts playback only after enough"
  print "      data is buffered to play the media without any "
  print "      extra buffering"
  print "  2. Stalling buffer size (stbs):"
  print "    - The algorithm starts playback as soon as any data"
  print "      is available for playback"
  print "  3. Youtube-flash algorithm (ytfa):"
  print "    - Mimics the buffering behaviour of the youtube flash plugin"
  print "    - Initially buffers until two seconds of media are"
  print "      available for playback"
  print "    - In consequent stalls the algorithm buffers until"
  print "      five seconds of media are available for playback"
  print "  4. Firefox HTML5 algorithm (ffh5):"
  print "    - Mimics the buffering behaviour of Firefox on HTML5 websites"
  print "    - Buffers until at least one of the following buffering"
  print "      end conditions is met:"
  print "      a) has been buffering for at least 30 seconds"
  print "      b) at least 30 seconds of media is buffered"
  print "      c) whole media has been downloaded"
  print "      d) it would take less time to play the remaining"
  print "         part of the media than to download it and at"
  print "         least 20 seconds of media are buffered"
  print ""
  print "Example usage statements:"
  print "  ytresults LJP1DphOWPs 0 ytfa stath"
  print "  ytresults LJP1DphOWPs 2 ffh5 statm"
  print "  ytresults LJP1DphOWPs 1 nnbs plotbuffer"
  print "  ytresults LJP1DphOWPs 4 stbs plotbuffertime"
  print "  ytresults LJP1DphOWPs 2 scal plotcumdata"
  print ""
###############################################################################




if __name__ == "__main__":
  if len(sys.argv) < 5:
    usage()
    sys.exit(2)
    
  foldername = sys.argv[1]
  videosubid = sys.argv[2]
  alg = sys.argv[3]
  outputmode = sys.argv[4]
  if (len(sys.argv) > 5):
    outputmodeoptions = []
    for i in range(5, len(sys.argv)-1):
        outputmodeoptions.append(sys.argv[i])
  
  
  myG = Graphs(foldername, videosubid)
    
  (bufferlevels, frame_timestamps, total_offset, stalls) = myG.stallingalgorithm(alg)
  
  if (outputmode == "stath"):
    myG.printStallStatsH(stalls)
    
  elif (outputmode == "statm"):
    myG.printStallStatsM(stalls)

  elif (outputmode == "plotbuffer"):
    myG.plotbuffer(bufferlevels , sys.argv[3])
    
  elif (outputmode == "plotbuffertime"):
    myG.plotbufferseconds(bufferlevels , frame_timestamps, sys.argv[3])
    
  elif (outputmode == "plotrates"):
    myG.plotdownloadvsframerate()
    
  elif (outputmode == "plotcumdata"):
    myG.plotadditiveframedownloadbytes(frame_timestamps)
  else:      
    print "Output mode not supported (" + outputmode + ")"
    sys.exit(2)    
    
  
    

  

  

  
  
  
