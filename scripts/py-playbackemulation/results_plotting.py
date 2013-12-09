# -*- coding: utf-8 -*-
"""
Created on Thu Nov 24 10:56:52 2011

@author: fm
"""

import matplotlib.pyplot as plt
import pylab
import matplotlib
import csv

import results_helpermethods

################################################################################ 
def plotbinneddownloadbytes(download_timestamps, download_bytes, video_id, sub_video_id, binsize):
    """ plot binned download bytes over time """
    ts_floats = results_helpermethods.convtimestampstofloats(download_timestamps)
    ts_bins = results_helpermethods.genbinnedtimestamplist(ts_floats[-1], binsize)
    bytes_bins = results_helpermethods.bindownloadbytes(download_timestamps, download_bytes, ts_bins, binsize)
    
    # rescale bytes_bins to MBytes
    kbytes_bins = []
    for bytes in bytes_bins:
      kbytes_bins.append(float(bytes)/1000)
    
    f0 = pylab.figure()
    plt.plot(ts_bins,kbytes_bins, 'ro')
    plt.xlabel('time (seconds)')
    plt.ylabel('data (Kbytes/' + str(binsize*1000)+ 'ms)')
#    plt.xlim(0, 50)
    plt.title(video_id +' received bytes')
    plt.grid(True)
    plt.savefig(sub_video_id+"binneddl")
    plt.show()
################################################################################

def plotadditiveframedownloadbytes(download_timestamps, download_bytes, video_filesize, frame_list, frame_timestamps, video_id, sub_video_id):

    f_additivesizes_mod = results_helpermethods.genadditiveframebyteswithoverhead(frame_list, video_filesize)

    bytes_additive = results_helpermethods.genadditivedownloadbytes(download_bytes)
    
    ts_floats = results_helpermethods.convtimestampstofloats(download_timestamps)
    
    #scale to MBytes
    kbytes_additive = []
    m_f_additivesizes_mod = []
    for byte in bytes_additive:
      kbytes_additive.append(float(byte)/1000)
    for byte in f_additivesizes_mod:
      m_f_additivesizes_mod.append(float(byte)/1000)
    
    with open('buffer.csv', 'wb') as f:
        writer = csv.writer(f)
        writer.writerow(["timestamp", "size", "type"])
        i = 0
        for ts in frame_timestamps:
            writer.writerow([ts, m_f_additivesizes_mod[i], "frame"])
            i += 1
        i = 0
        for ts in ts_floats:
            #print(kbytes_additive[i])
            writer.writerow([ts, kbytes_additive[i], "segment"])
            i += 1


    f1 = pylab.figure()
    plt.hold(True)
    #plt.plot(f_times,f_additivesizes, ls='--', label='played frames', linewidth=0.5)
    plt.plot(frame_timestamps,m_f_additivesizes_mod, 'r.',ls='-', linewidth=0.5, label='played frames')
    plt.plot(ts_floats, kbytes_additive, 'g.', ls='-', label='received data', linewidth=0.5)          
    plt.xlabel('time (seconds)')
    plt.ylabel('data (KBytes)')
    plt.legend(loc=4)
    #plt.xlim(0, 2000)
    plt.title(video_id +' downloaded vs played data')
    plt.grid(True)
    plt.savefig(sub_video_id+"dlvsplayed")
    plt.show()

################################################################################
def plotdlvsfrrate(download_timestamps, download_bytes, video_filesize, frame_list, video_id, sub_video_id, binsize):
    """ 
    plot the download rate (in 1s bins) 
    as well as the avg frame rate per frame
    """
      
    ts_floats = results_helpermethods.convtimestampstofloats(download_timestamps)
    ts_bins = results_helpermethods.genbinnedtimestamplist(ts_floats[-1], binsize)
    bytes_bins = results_helpermethods.bindownloadbytes(download_timestamps, download_bytes, ts_bins, binsize)
    
    # rescale bytes_bins to MBytes
    kbytes_bins = []
    for bytes in bytes_bins:
      kbytes_bins.append(float(bytes)/1000)
      
    # frames    
    fbytes_overhead = results_helpermethods.genframebyteswithoverhead(frame_list, video_filesize)
    f_rates_bins = []    

    #framelist_temp = self.framelist[:]
    for binsum in bytes_bins:
      fsum = 0
      fnum = 0
      while(True):
        if len(fbytes_overhead) > 0:
          if (fsum + int(fbytes_overhead[0])) <= binsum:
              fnum += 1              
              fsum += int(fbytes_overhead[0])
              fbytes_overhead.pop(0)
          else:
            break
        else:
            break
      fsum = float(fsum) / 1000.0    
#      print "binsim: "+str(binsum)+" sum: "+str(fsum)+ " num: "+str(fnum)
      if fsum == 0:
          f_rates_bins.append(0)
      elif fnum == 0:
          f_rates_bins.append(0)
      else:
          f_rates_bins.append(float(fsum)/float(fnum))
      
    
    f0 = pylab.figure()
    plt.hold(True)
    plt.plot(ts_bins,kbytes_bins, 'r.')
    plt.plot(ts_bins,kbytes_bins, 'r-')
    plt.plot(ts_bins, f_rates_bins, 'g.')
    plt.plot(ts_bins, f_rates_bins, 'g-')
    plt.xlabel('time (seconds)')
    plt.ylabel('data (Kbytes/' + str(binsize*1000)+ 'ms)')
#    plt.xlim(0, 50)
    plt.title(video_id +' received bytes')
    plt.grid(True)
    plt.savefig(sub_video_id+"binneddl")
    plt.show()
################################################################################


################################################################################
def plotbufferseconds(bufferlevel, video_id, sub_video_id, subtitlestring):
    """ plots the currently filled buffer size in seconds """
    f2 = pylab.figure()
    plt.hold(True)
    plt.plot(bufferlevel.timestamps,bufferlevel.levelseconds, 'r.')
    plt.xlabel('time (seconds)')
    plt.ylabel('buffer level (seconds)')
    plt.title(video_id +' buffer fill level ' + subtitlestring)
    plt.grid(True)
    plt.savefig(sub_video_id+"bufferlevel_seconds")
    plt.show()
################################################################################


################################################################################
def plotbuffer(bufferlevel, video_id, sub_video_id, subtitlestring=""):
    """ plots the currently filled buffer size """

    # rescale buffer to MBytes
    buffer_mbytes = []
    for byte in bufferlevel.level:
      buffer_mbytes.append(byte/1000)
      
    # plot it
    f2 = pylab.figure()
    plt.hold(True)
    plt.plot(bufferlevel.timestamps,buffer_mbytes, 'r.')
    plt.xlabel('time (seconds)')
    plt.ylabel('buffer level (KBytes)')
    plt.title(video_id +' buffer fill level ' + subtitlestring)
    plt.grid(True)
    plt.savefig(sub_video_id+"bufferlevel_bytes")
    plt.show()
################################################################################
