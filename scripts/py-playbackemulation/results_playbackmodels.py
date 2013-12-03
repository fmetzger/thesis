# -*- coding: utf-8 -*-
"""
Created on Thu Nov 24 12:23:11 2011

@author: fm
"""

import results_helpermethods
import results_classes

################################################################################
def stallingbuffersizealg(frame_list, frame_timestamps, download_timestamps, download_bytes, video_filesize):
    """
    starts playback immediately but pauses everytime the buffer would become
    negative, creating gabs
    resumes at once without prebuffering any frames
    """
  
    # get our data/timestamp lists

    frame_ts_tmp = results_helpermethods.offset_simple(frame_timestamps[:], 0.0)
    frame_bytes = results_helpermethods.genframebyteswithoverhead_old(video_filesize, frame_list)
    dl_ts_tmp = results_helpermethods.convtimestampstofloats(download_timestamps)
    dl_ts_tmp.pop(0)
    dl_bytes_tmp = download_bytes[:]

    totaloffset = 0
    offset = 0.500
    
    bufferlevel = results_helpermethods.calcbufferlevel(frame_ts_tmp, frame_bytes, dl_ts_tmp, dl_bytes_tmp)
    
    while results_helpermethods.hasnegative(bufferlevel) == True:
      # create initial buffer
      

      # get the index of the first negative value
      for i in range(len(bufferlevel.level)):
        if bufferlevel.level[i] < 0:
          firstneg = i
          negts = bufferlevel.timestamps[i]
          break
      
      # find the closest frame timestamp before the negative buffer
      for i in range(len(frame_ts_tmp)):
        if negts < frame_ts_tmp[i]:
          offsetindex = i - 1
          break
      
      totaloffset += offset
      for i in range(offsetindex, len(frame_ts_tmp)):
        frame_ts_tmp[i] += offset
      
      bufferlevel = results_helpermethods.calcbufferlevel(frame_ts_tmp, frame_bytes, dl_ts_tmp, dl_bytes_tmp)

    return bufferlevel, frame_ts_tmp, totaloffset

################################################################################


################################################################################
def faststallingbuffersizealg(frame_list, frame_timestamps, download_timestamps, download_bytes, video_filesize):
    """
    starts playback immediately but pauses everytime the buffer would become
    negative, creating gaps
    resumes at once without prebuffering any frames
    """
  
    # get our data/timestamp lists

    frame_ts_tmp = results_helpermethods.offset_simple(frame_timestamps[:], 0.0)
    frame_bytes = results_helpermethods.genframebyteswithoverhead_old(video_filesize, frame_list)
    dl_ts_tmp = results_helpermethods.convtimestampstofloats(download_timestamps)
    dl_ts_tmp.pop(0)
    dl_bytes_tmp = download_bytes[:]
    stalls = []
    """
    # upscale frame sizes to make sure sum(frame_bytes)==sum(dl_bytes_tmp)
    scalefactor = sum(dl_bytes_tmp)*1.0/sum(frame_bytes)
    print str(scalefactor)
    for i in range(len(frame_bytes)):
      frame_bytes[i] = frame_bytes[i]*scalefactor;
    """
    i = 0
    j = 0
    bufferlevel = results_classes.Bufferlevel()
    offset = 0

    lastplayedbackframe = 0
    bufferlevel.timestamps.append(0)
    bufferlevel.level.append(0)
    s = results_classes.Stall()
    s.type = "Stall"
    s.start = bufferlevel.timestamps[-1]
    while(i<len(frame_ts_tmp)):
    # Get to be achieved bufferlevel
      # play bytes until buffer gets empty
      while(True):
        if(i==len(frame_ts_tmp)):
          if(j==len(dl_ts_tmp)): # finished
            break
          else: # only buffers remaining; should not happen
            #print "Strange error has occured; ran out of frames earlier than of buffer"
            break
        elif(j==len(dl_ts_tmp)): # only frames left
          if(s.type == "Stall"):
            s.end = lastplayedbackframe + offset
            stalls.append(s)
            s = results_classes.Stall()
            s.type = "Playback"
            s.start = lastplayedbackframe + offset
          while(i<len(frame_ts_tmp)):
            frame_ts_tmp[i] = frame_ts_tmp[i] + offset
            bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes[i])
            bufferlevel.timestamps.append(frame_ts_tmp[i])
            lastplayedbackframe = frame_ts_tmp[i]-offset
            i = i + 1
          break
        if frame_ts_tmp[i]+offset < dl_ts_tmp[j]: # next event is a frame-playback event
          if(bufferlevel.level[-1] - frame_bytes[i] < 0): # dont let the buffer get negative
            if(s.type == "Playback"):
              s.end = lastplayedbackframe + offset
              stalls.append(s)
              s = results_classes.Stall()
              s.type = "Stall"
              #s.start = bufferlevel.timestamps[-1]
              s.start = lastplayedbackframe + offset
            offset = offset + (dl_ts_tmp[j]-(frame_ts_tmp[i]+offset))+0.001
            break
          if(s.type == "Stall"):
            s.end = lastplayedbackframe + offset
            stalls.append(s)
            s = results_classes.Stall()
            s.type = "Playback"
            s.start = lastplayedbackframe + offset
          frame_ts_tmp[i] = frame_ts_tmp[i] + offset # update frame timestamp with offset
          bufferlevel.timestamps.append(frame_ts_tmp[i])
          bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes[i]) # decrease buffer level
          lastplayedbackframe = frame_ts_tmp[i]-offset
          i = i + 1 # increase current frame counter
        elif frame_ts_tmp[i]+offset > dl_ts_tmp[j]: # next event is a buffer increase event
          bufferlevel.timestamps.append(dl_ts_tmp[j])
          bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j]) # increase buffer level
          j = j + 1 # increase current packet counter
        else: # both types of events occur at the same time
          if(bufferlevel.level[-1] - frame_bytes[i] + dl_bytes_tmp[j] < 0): # dont let the buffer get negative
            if(s.type == "Playback"):
              s.end = lastplayedbackframe + offset
              stalls.append(s)
              s = results_classes.Stall()
              s.type = "Stall"
              s.start = lastplayedbackframe + offset
            offset = offset + (dl_ts_tmp[j]-(frame_ts_tmp[i]+offset))+0.001
            break
          if(s.type == "Stall"):
            s.end = lastplayedbackframe + offset
            stalls.append(s)
            s = results_classes.Stall()
            s.type = "Playback"
            s.start = lastplayedbackframe + offset
          frame_ts_tmp[i] = frame_ts_tmp[i] + offset # update frame timestamp with offset
          bufferlevel.timestamps.append(dl_ts_tmp[j])
          bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j] + frame_bytes[i]) # increase and decrease buffer
          lastplayedbackframe = frame_ts_tmp[i]-offset
          i = i + 1 # increase both counters
          j = j + 1
        
    s.end = bufferlevel.timestamps[-1]
    stalls.append(s)
#    print "Stalling amounts to a total of " + str(offset) + " seconds."
    
    return bufferlevel, frame_ts_tmp, offset, stalls
################################################################################


def scalingbufferalg(frame_list, frame_timestamps, download_timestamps, download_bytes, video_filesize):
    
    # get our data/timestamp lists
    frame_timestamps = results_helpermethods.offset_simple(frame_timestamps[:], 0.0)
    
    
    packet_sizes = download_bytes[:]
    
    frame_sizes = results_helpermethods.genframebyteswithoverhead(frame_list, packet_sizes)
    
    
    packet_timestamps = results_helpermethods.convtimestampstofloats(download_timestamps)
    packet_timestamps.pop(0)
    

    # EWMA scaling factor for videobitrate (0<a>1)
    alpha = 0.2
    # EWMA scaling factor for transmission rate
    beta = alpha    
    # buffer scaling factor/or function (range?)
    gamma = 10.0
    
    eventqueue = results_classes.LoggingScaleQueue(alpha, beta, gamma)
    
    for x in range(len(frame_timestamps)):
        timestamp = frame_timestamps[x]
        size = -1 * frame_sizes[x]
        event = results_classes.FrameEvent(timestamp, size)
        
        eventqueue.addEvent(event)
        
    for x in range(len(packet_timestamps)):
        timestamp = packet_timestamps[x]
        size = packet_sizes[x]
        event = results_classes.PacketEvent(timestamp, size)
        
        eventqueue.addEvent(event)
        
    eventqueue.processEvents()
    
    playback_phase_list = eventqueue.playback_phase_list
    bufferlevel = eventqueue.bufferlevel
    
#    return bufferlevel, frame_ts_tmp, total_stalling_time, playback_phase_list
    return bufferlevel, None, None, playback_phase_list


################################################################################




################################################################################
def firefoxhtml5alg(frame_list, frame_timestamps, download_timestamps, download_bytes, video_filesize):
    """ Firefox 4 HTML 5 Algorithm """
  
    # get our data/timestamp lists
    frame_ts_tmp = results_helpermethods.offset_simple(frame_timestamps[:], 0.0)
    frame_bytes = results_helpermethods.genframebyteswithoverhead_old(video_filesize, frame_list)
    dl_ts_tmp = results_helpermethods.convtimestampstofloats(download_timestamps)
    dl_ts_tmp.pop(0)
    dl_bytes_tmp = download_bytes[:]
    remainingplay = sum(frame_bytes)
    remainingdl = sum(dl_bytes_tmp)
    stalls = []

    # set window size for moving average
    window_size = 1000

    # calculate playback speeds
    playback_speed = results_helpermethods.movingAvg(frame_ts_tmp, frame_bytes, window_size)
    #calculate download speeds
    dl_speed = results_helpermethods.movingAvg(dl_ts_tmp, dl_bytes_tmp, window_size)

    i = 0
    j = 0
    bufferlevel = results_classes.Bufferlevel()
    offset = 0
    tobuffer = -1

    bufferlevel.timestamps.append(0)
    bufferlevel.level.append(0)
    lastplayedbackframe = 0
    s = results_classes.Stall()
    s.type = "Stall"
    s.start = bufferlevel.timestamps[-1]
    while(i<len(frame_ts_tmp)):
      # recalculate buffering end conditions
      if(s.type == "Playback"):
        s.end = bufferlevel.timestamps[-1]
        stalls.append(s)
        s = results_classes.Stall()
        s.type = "Stall"
        s.start = bufferlevel.timestamps[-1]
      if(tobuffer <= 0):
        # mark the starting time of the buffering for end condition (1)
        bufferingstart = offset
        # calculate the amount of "enough data" for buffering end condition (2)
        if(playback_speed[i] < 50000):
          speed = 50000
        else:
          speed = playback_speed[i]
        tobuffer = speed * 30
      # increase offset by one second
      # ( buffering is always done for a second, before checking if end conditions are met )
      offset = offset + 1
      # buffer bytes for a second
      while(j<len(dl_ts_tmp) and dl_ts_tmp[j]<frame_ts_tmp[i]+offset):
        bufferlevel.timestamps.append(dl_ts_tmp[j])
        bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j])
        tobuffer = tobuffer - dl_bytes_tmp[j]
        remainingdl = remainingdl - dl_bytes_tmp[j]
        j = j+1
      # safety margin to compensate for the possibly fluctuating dl-speed
      margin = 1000000
      playthroughmargin = 20
      # check if at least one of the buffering end conditions is met
      # - (1) have been buffering for at least 30 seconds
      # - (2) enough data has been buffered ( ~ 30seconds of media )
      # - (3) whole video has been downloaded
      # - (4) it would take less time to play the remaining part of the video than to download it and at least playthroughmargin seconds are buffered
      if(offset-bufferingstart>=30 or tobuffer<=0 or remainingdl<=0 or (((remainingdl+margin)/dl_speed[j] < remainingplay/playback_speed[i]) and (remainingdl<remainingplay-(playthroughmargin*playback_speed[i])))):
        # set "tobuffer" to some negative value
        # - buffering end conditions need to be recomputated
        tobuffer = -1
        if(s.type == "Stall"):
          s.end = lastplayedbackframe + offset
          stalls.append(s)
          s = results_classes.Stall()
          s.type = "Playback"
          s.start = lastplayedbackframe + offset
        # playback loop
        while(True):
          # no frames left
          if(i==len(frame_ts_tmp)):
            break
          # only frames left
          elif(j==len(dl_ts_tmp)):
            # play the remaining frames
            while(i<len(frame_ts_tmp)):
              frame_ts_tmp[i] = frame_ts_tmp[i] + offset
              remainingplay = remainingplay - frame_bytes[i]
              bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes[i])
              bufferlevel.timestamps.append(frame_ts_tmp[i])
              lastplayedbackframe = frame_ts_tmp[i] - offset
              i = i + 1
            break
          # both frames and buffering events remaining
          #
          # next event is a frame-playback event
          if frame_ts_tmp[i]+offset < dl_ts_tmp[j]:
            if(bufferlevel.level[-1] - frame_bytes[i] < 0): # dont let the buffer get negative
              break
            frame_ts_tmp[i] = frame_ts_tmp[i] + offset # update frame timestamp with offset
            bufferlevel.timestamps.append(frame_ts_tmp[i])
            bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes[i]) # decrease buffer level
            remainingplay = remainingplay - frame_bytes[i]
            lastplayedbackframe = frame_ts_tmp[i] - offset
            i = i + 1 # increase current frame counter
          # next event is a buffer increase event
          elif frame_ts_tmp[i]+offset > dl_ts_tmp[j]:
            bufferlevel.timestamps.append(dl_ts_tmp[j])
            bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j]) # increase buffer level
            remainingdl = remainingdl - dl_bytes_tmp[j]
            j = j + 1 # increase current packet counter
          # both types of events occur at the same time
          else:
            frame_ts_tmp[i] = frame_ts_tmp[i] + offset # update frame timestamp with offset
            bufferlevel.timestamps.append(dl_ts_tmp[j])
            bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j] + frame_bytes[i]) # increase and decrease buffer
            remainingdl = remainingdl - dl_bytes_tmp[j]
            remainingplay = remainingplay - frame_bytes[i]
            lastplayedbackframe = frame_ts_tmp[i] - offset
            i = i + 1 # increase both counters
            j = j + 1
    s.end = bufferlevel.timestamps[-1]
    stalls.append(s)

#    print "Stalling amounts to a total of " + str(offset) + " seconds."
    
    return bufferlevel, frame_ts_tmp, offset, stalls
################################################################################




################################################################################
# ytAlgorithm
def ytflashalg(frame_list, frame_timestamps, download_timestamps, download_bytes, video_filesize):
    """ YouTube Flash Player Alg """
  
    # get our data/timestamp lists
    frame_ts_tmp = results_helpermethods.offset_simple(frame_timestamps[:], 0.0)
    frame_bytes = results_helpermethods.genframebyteswithoverhead_old(video_filesize, frame_list)
    dl_ts_tmp = results_helpermethods.convtimestampstofloats(download_timestamps)
    dl_ts_tmp.pop(0)
    dl_bytes_tmp = download_bytes[:]
    stalls = []

    firststalled = True
    secsToBuffer = 0
    i = 0
    j = 0
    bufferlevel = results_classes.Bufferlevel()
    offset = 0

    bufferlevel.timestamps.append(0)
    bufferlevel.level.append(0)
    
    while(i<len(frame_ts_tmp)):
    # Get to be achieved bufferlevel
      if(firststalled == True):
        secsToBuffer = 2
        firststalled = False
      else:
        secsToBuffer = 5
      # init tmp vars
      l = i
      accumulator = 0
      # calculate how many bytes are needed to be buffered
      # based on the timestamps and sizes of the frames
      #print "Accumulating buffer size\n"
      while(frame_ts_tmp[l]+offset<=secsToBuffer+bufferlevel.timestamps[-1]):
        #print str(frame_ts_tmp[l]+offset) + " vs " + str(secsToBuffer+bufferlevel.timestamps[-1])
        accumulator += frame_bytes[l]
        #print "Accumulator: "+str(accumulator)
        l=l+1
      # mark startposition of buffering
      offsetstart = bufferlevel.timestamps[-1]
      # buffer accumulator number of bytes
      s = results_classes.Stall()
      s.type = "Stall"
      s.start = bufferlevel.timestamps[-1]
      while(bufferlevel.level[-1] < accumulator and j<len(dl_ts_tmp)):
        bufferlevel.timestamps.append(dl_ts_tmp[j])
        bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j])

        j = j+1
      # increase offset
      s.end = bufferlevel.timestamps[-1]
      stalls.append(s)
      offset = offset + bufferlevel.timestamps[-1] - offsetstart

      # play bytes until buffer gets empty
      s = results_classes.Stall()
      s.type = "Playback"
      s.start = bufferlevel.timestamps[-1]
      while(True):
        if(i==len(frame_ts_tmp)):
          break
          if(j==len(dl_ts_tmp)): # finished
            break
          #else: # only buffers remaining; should not happen
            #print "Strange error has occured; ran out of frames earlier than of buffer"
        elif(j==len(dl_ts_tmp)): # only frames left
          while(i<len(frame_ts_tmp)):
            frame_ts_tmp[i] = frame_ts_tmp[i] + offset
            bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes[i])
            bufferlevel.timestamps.append(frame_ts_tmp[i])
            i = i + 1
          break
        if frame_ts_tmp[i]+offset < dl_ts_tmp[j]: # next event is a frame-playback event
          if(bufferlevel.level[-1] - frame_bytes[i] < 0): # dont let the buffer get negative
            break
          frame_ts_tmp[i] = frame_ts_tmp[i] + offset # update frame timestamp with offset
          bufferlevel.timestamps.append(frame_ts_tmp[i])
          bufferlevel.level.append(bufferlevel.level[-1] - frame_bytes[i]) # decrease buffer level

          i = i + 1 # increase current frame counter
        elif frame_ts_tmp[i]+offset > dl_ts_tmp[j]: # next event is a buffer increase event
          bufferlevel.timestamps.append(dl_ts_tmp[j])
          bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j]) # increase buffer level
          j = j + 1 # increase current packet counter
        else: # both types of events occur at the same time
          frame_ts_tmp[i] = frame_ts_tmp[i] + offset # update frame timestamp with offset
          bufferlevel.timestamps.append(dl_ts_tmp[j])
          bufferlevel.level.append(bufferlevel.level[-1] + dl_bytes_tmp[j] + frame_bytes[i]) # increase and decrease buffer
          i = i + 1 # increase both counters
          j = j + 1
      s.end = bufferlevel.timestamps[-1]
      stalls.append(s)

#    print "Stalling amounts to a total of " + str(offset) + " seconds."
    
    return bufferlevel, frame_ts_tmp, offset, stalls
################################################################################




###############################################################################
def nonnegativebuffersizealg(frame_list, frame_timestamps, download_timestamps, download_bytes, video_filesize):
    """ 
    non negative buffer calc algorithm
    returns the neccessary offset
    """
    
    # get our data/timestamp lists

    frame_ts_tmp = results_helpermethods.offset_simple(frame_timestamps[:], 0.0)
    frame_bytes = results_helpermethods.genframebyteswithoverhead_old(video_filesize, frame_list)
    dl_ts_tmp = results_helpermethods.convtimestampstofloats(download_timestamps)
    dl_ts_tmp.pop(0)
    dl_bytes_tmp = download_bytes[:]
    
    offsetincrement = .1 # start with 100ms increments
    totaloffset = 0.0 # initial offset
    
    # create initial buffer
    bufferlevel = results_helpermethods.calcbufferlevel(frame_ts_tmp, frame_bytes, dl_ts_tmp, dl_bytes_tmp)
    
    while results_helpermethods.hasnegative(bufferlevel) == True:
#      print "Offset " + str(totaloffset) + " seconds not sufficient. Increasing."
      totaloffset = totaloffset + offsetincrement
      frame_ts_tmp = results_helpermethods.offset_simple(frame_ts_tmp, offsetincrement)
      bufferlevel = results_helpermethods.calcbufferlevel(frame_ts_tmp, frame_bytes, dl_ts_tmp, dl_bytes_tmp)
      
      
    #print "Found viable offset with " + str(totaloffset) + "seconds."
    
    stalls = []

    s = results_classes.Stall()
    s.type = "Stall"
    s.start = 0
    s.end = totaloffset
    stalls.append(s)

    s = results_classes.Stall()
    s.type = "Playback"
    s.start = totaloffset
    s.end = bufferlevel.timestamps[-1]
    stalls.append(s)

    return bufferlevel, frame_ts_tmp, totaloffset, stalls
###############################################################################