# -*- coding: utf-8 -*-
"""
Created on Thu Nov 24 10:23:59 2011

@author: fm
"""

import math

import results_classes

################################################################################  
def convtimestampstofloats(timestamp_list):
    """ convert the time deltas to floats for easier handling """
    download_timestamps_f = []
    for ts in timestamp_list:
        tmp = float(ts.seconds) + float(ts.microseconds) / 1000000
        download_timestamps_f.append(tmp)
      
    download_timestamps_f.insert(0,0)     # insert a zero mark at the beginning
    
    return download_timestamps_f
################################################################################



################################################################################
def genbinnedtimestamplist(duration, binsize):
    """ 
    prearrange a list with 100ms bins with the correct length
    duration should be ts_floats[-1] in seconds
    """
    download_timestamps_binned = []
    
    num_bins = math.ceil(duration / binsize)
    z = 0
    while z < num_bins:
        download_timestamps_binned.append(z*binsize)
        z += 1
      
    return download_timestamps_binned
################################################################################

def genadditiveframebyteswithoverhead(frame_list, video_size):
    frame_bytes_w_overhead = genframebyteswithoverhead(frame_list, video_size)
    additive_frame_bytes_w_overhead = []
    last = 0
    for i in frame_bytes_w_overhead:
      additive_frame_bytes_w_overhead.append(last+i)
      last = additive_frame_bytes_w_overhead[-1]
    return additive_frame_bytes_w_overhead

################################################################################
def genframebyteswithoverhead(frame_list, video_size):
    """ 
    add to every frame a portion of the total file size, 
    to compensate for audio and other (container, metadata, ...) overhead
    """
    
    total_frame_size = 0
    total_download_size = 0    
    
    for s in frame_list:
        total_frame_size += float(s.size)
    
    #for s in packet_list:
    #    total_download_size += float(s)
    
    #delta_size = total_download_size - total_frame_size
    delta_size = video_size - total_frame_size
    
    byte_increase = float(delta_size) / float(len(frame_list))
#    print "Increase by: " + str(byte_increase)
    
    
    frame_bytes_w_overhead = [0]
    
    for f in frame_list:
      new_size = float(f.size) + byte_increase
      frame_bytes_w_overhead.append(new_size)
    
    return frame_bytes_w_overhead
  
################################################################################


################################################################################
def genframebytes(frame_list):
    """ generate an additive list of the played frames """
    frame_bytes = [0]

    for frame in frame_list:
      frame_bytes.append(int(frame.size))
      
    return frame_bytes
################################################################################


################################################################################

		

def genadditiveframebytes_old(frame_list):
    """ generate an additive list of the played frames """

    frame_bytes_additive = [0]

    for frame in frame_list:
      s = frame_bytes_additive[-1] + int(frame.size)
      frame_bytes_additive.append(s)
    return frame_bytes_additive
    
    
################################################################################
def genframebyteswithoverhead_old(video_filesize, frame_list):
    """
    add to every frame a portion of the total file size,
    to compensate for audio and other overhead
    """
    frame_bytes = genframebytes(frame_list)
    delta_size = video_filesize - genadditiveframebytes_old(frame_list)[-1]
    numframes = len(frame_list)
    byte_increase = float(delta_size) / float(numframes)
#    print "Increase by: " + str(byte_increase)
    
    
    frame_bytes_w_overhead = []

    for f_size in frame_bytes:
       frame_bytes_w_overhead.append(f_size+byte_increase)
    
    return frame_bytes_w_overhead
  
################################################################################


################################################################################
def genadditivedownloadbytes(download_bytes):
    """ generate an additive list of the received bytes """
    download_bytes_additive = [0]
    for b in download_bytes:
      download_bytes_additive.append(download_bytes_additive[-1] + b)
    
#    print "Total downloaded bytes: " + str(download_bytes_additive[-1])
    return download_bytes_additive
################################################################################


################################################################################
def bindownloadbytes(download_timestamps, download_bytes, timestamp_bins, binsize):
    """ binned traffic byte sizes into 10ms bins. """
    download_bytes_bins = [0]
    ts_tmp = 0
    ts_floats = convtimestampstofloats(download_timestamps)
    bytes_tmp = download_bytes[:] # copy that list
    
    while len(bytes_tmp) > 0:
      ts_float_tmp = ts_floats.pop(0)
      ts_tmp = int(float(ts_float_tmp) / binsize)
      while len(download_bytes_bins) < ts_tmp:
        download_bytes_bins.append(0)
      download_bytes_bins[ts_tmp-1] += bytes_tmp.pop(0)

    while len(download_bytes_bins) < len(timestamp_bins):
      download_bytes_bins.append(0)
      
    return download_bytes_bins
################################################################################



###############################################################################
def calcBufferlevelsInSeconds(bufferlevel, timestamps, frame_timestamps, frame_list, video_filesize):
    """ """
    frame_ts_tmp = offset_simple(frame_timestamps[:], 0.0)
    frame_bytes = genframebyteswithoverhead(frame_list, video_filesize)
    i=0
    j=0
    k=0
    accumulator = 0
    lastbuf = 0
    lastframe = 0
    lastbufframe = 0
    bufftime = 0
    for i in range(len(bufferlevel.level)):
      diff = bufferlevel.level[i]-lastbuf
      if(diff > 0):
        accumulator = accumulator + diff
      if (bufferlevel.timestamps[i]==timestamps[j]): # frame playback
        bufftime = bufftime - (frame_ts_tmp[j]-lastframe)
        lastframe = frame_ts_tmp[j]
        j = j + 1
      while(k<len(frame_bytes) and frame_bytes[k]<accumulator):
        bufftime = bufftime + (frame_ts_tmp[k]-lastbufframe)
        lastbufframe = frame_ts_tmp[k]
        accumulator = accumulator - frame_bytes[k]
        k = k + 1
      bufferlevel.levelseconds.append(bufftime)
      lastbuf = bufferlevel.level[i]
    return
###############################################################################


################################################################################
def offset_simple(timestamps, offset_seconds):
    """ calculate the offset for playing the video and apply it. """
    timestamps_offset = []
    for time in timestamps:
      timestamps_offset.append(float(time)+offset_seconds)
    
    return timestamps_offset
################################################################################

################################################################################
def hasnegative(bufferlevel):
    """ check for negative values in a list """
    
    finished = False
    for i in range(len(bufferlevel.level)):
      if i > 0 and i < len(bufferlevel.level) - 1 and bufferlevel.level[i] <= 0:
        finished = True
    return finished
################################################################################


################################################################################
def calcbufferlevel(frame_timestamps, frame_bytes, dl_timestamps, dl_bytes):
    """ calculcate and return buffer level using the given lists """
  
  
    # copy the 4 involved lists
    frame_ts_tmp = frame_timestamps[:]
    frame_bytes_tmp = frame_bytes[:]
    dl_ts_tmp = dl_timestamps[:]
    dl_bytes_tmp = dl_bytes[:]
    
    bufferlevel = results_classes.Bufferlevel()
    
    while len(frame_ts_tmp) > 0 and len(dl_ts_tmp) > 0:

      
      if frame_ts_tmp[0] < dl_ts_tmp[0]:
        bufferlevel.timestamps.append(frame_ts_tmp.pop(0))
        bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes_tmp.pop(0))
      
      elif frame_ts_tmp[0] > dl_ts_tmp[0]:
        bufferlevel.timestamps.append(dl_ts_tmp.pop(0))
        bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp.pop(0))
      
      elif frame_ts_tmp[0] == dl_ts_tmp[0]: # merge the events
        bufferlevel.timestamps.append(dl_ts_tmp.pop(0))
        frame_ts_tmp.pop(0)
        bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp.pop(0) - frame_bytes_tmp.pop(0))
        
    # if one is empty, we just fill in the rest
    if len(frame_ts_tmp) == 0 and len(dl_ts_tmp) > 0:
      while len(dl_ts_tmp) > 0:
        bufferlevel.timestamps.append(dl_ts_tmp.pop(0))
        bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp.pop(0))
    elif len(dl_ts_tmp) == 0 and len(frame_ts_tmp) > 0:
      while len(frame_ts_tmp) > 0:
        bufferlevel.timestamps.append(frame_ts_tmp.pop(0))
        bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes_tmp.pop(0))
    
    return bufferlevel
################################################################################



################################################################################
def movingAvg(timestamps, byte_list, window_size):
    """ moving average """
    result = []
    in_avg = 0
    total = 0
    for i in range(len(byte_list)):
      if(in_avg < window_size):
        in_avg = in_avg + 1
        total = total + byte_list[i]
        if(i==0 or (timestamps[i]-timestamps[i-(in_avg-1)])==0):
          result.append(total)
        else:
          result.append(total*1.0/(timestamps[i]-timestamps[i-(in_avg-1)]))
        multiplier = 1
      else:
        total = total - byte_list[i-window_size] + byte_list[i]
        result.append(total*1.0/(timestamps[i]-timestamps[i-in_avg]))
    return result
###############################################################################
