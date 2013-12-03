from time import time
import urllib
import xml.etree.ElementTree as ET
import sys
import results_classes
import math

def getManifestURL(base_url):
	return base_url + "Manifest"

def getStreamURL(base_url, pattern, bitrate, time):
	return base_url+pattern.replace('{bitrate}', str(bitrate)).replace('{start time}', str(time))

base_url = sys.argv[1]
video_name = sys.argv[2]

url_start = time()
[path,httpmessage] = urllib.urlretrieve(getManifestURL(base_url))
url_end = time()

dl_size = int(httpmessage["Content-Length"])
last_avg = dl_size/(url_end-url_start)

print "dl time: " + str(url_end-url_start)
print "size: " + str(dl_size)
print "speed: " + str(last_avg/1024) + " kb/s"

tree = ET.parse(path)
root = tree.getroot()

duration = int(root.attrib['Duration'])
print "length: "+str(duration)

streamindices = root.findall('StreamIndex')

foundvideo = False
foundaudio = False

def parsestream(stream):
	chunks = int(stream.attrib['Chunks'])
	container = {}
	container['url']=stream.attrib['Url']
	container['qlevels']=[]
	for q in stream.findall('QualityLevel'):
		container['qlevels'].append(int(q.attrib['Bitrate']))
	container['chunks']=[]
	container['chunkstotal']=[]
	curtime=0
	for c in stream.findall('c'):
		container['chunkstotal'].append(curtime)
		container['chunks'].append(int(c.attrib['d']))
		curtime += int(c.attrib['d'])
	if len(container['chunks']) != chunks:
		print "Chunk count not matching!"
		exit(-1)
	return container

for index in streamindices:
	if index.attrib['Type'] == 'video' and not foundvideo:
		foundvideo = True
		print "Found video!"
		video = parsestream(index)
	
	if index.attrib['Type'] == 'audio' and not foundaudio:
		foundaudio = True
		print "Found audio!"
		audio = parsestream(index)
	
if not foundvideo or not foundaudio:
	print "Error video or audio stream not found!"
	exit(-1)

video['qlevels'].sort()
audio['qlevels'].sort()

# naive optimization algorithm
def optimize(video, audio, totalband):
	result = [len(video)-1, len(audio)-1]
	while (result[0] > 0 or result[1] > 0) and (totalband < video[result[0]] + audio[result[1]]):
		result[1] -= 1
		if (result[1] < 0):
			result[1] = len(audio)-1
			result[0] -= 1
	print str(result)
	return result

order = 15
listtimes = []
listdls = []

audioindex = 0
videoindex = 0
qualitylevel = [0,0]

#
# Simple model not depending on the playback behaviour but just on
# the average download speeds -- averages are calculated using moving
# average.
#
# Download is done using urllib. curl or similar tools would introduce
# unnecessary overhead. Downloadlog is generated internally.
#
# Framelog is also generated internally, the generated framelog assumes
# non-variable bitrate chunks -- not realistic, but there are no better ways.
#

curtime = 0

audlstamps = []
audlsizes = []
audlq = []
viddlstamps = []
viddlsizes = []
viddlq = []

while audioindex < len(audio['chunkstotal']) or videoindex < len(video['chunkstotal']):
	if audioindex < len(audio['chunkstotal']):
		if videoindex < len(video['chunkstotal']) and video['chunkstotal'][videoindex] < audio['chunkstotal'][audioindex]:
			cur = video
			q = qualitylevel[0]
			curindex = videoindex
			videoindex += 1
		else:
			cur = audio
			q = qualitylevel[1]
			curindex = audioindex
			audioindex += 1
	else:
		cur = video
		q = qualitylevel[0]
		curindex = videoindex
		videoindex += 1
	cururl = getStreamURL(base_url, cur['url'], cur['qlevels'][q], cur['chunkstotal'][curindex])
	print cururl
	url_start = time()
	[path,httpmessage] = urllib.urlretrieve(cururl)
	url_end = time()
	
	curtime += url_end - url_start
	if cur == video:
		viddlstamps.append(curtime)
		viddlsizes.append(int(httpmessage["Content-Length"]))
		viddlq.append(video['qlevels'][q])
	else:
		audlstamps.append(curtime)
		audlsizes.append(int(httpmessage["Content-Length"]))
		audlq.append(audio['qlevels'][q])
	
	if len(listtimes) >= order:
		listtimes.pop(0)
	if len(listdls) >= order:
		listdls.pop(0)
	
	listtimes.append(url_end - url_start)
	listdls.append(int(httpmessage["Content-Length"]))
	
	avg = sum(listdls)/sum(listtimes)*8
	print str(avg/1024/1024)+" Mb/s"
	qualitylevel = optimize(video['qlevels'], audio['qlevels'], avg)

class Chunk:
	def __init__(self, startt, lent, lenb, q, tstamp):
		self.startt = startt
		self.lent = lent
		self.lenb = lenb
		self.q = q
		self.tstamp = tstamp
	def tostr(self):
		return '[startt: '+str(self.startt)+'; lent: '+str(self.lent)+'; lenb: '+str(self.lenb)+'; q: '+str(self.q)+'; tstamp: '+str(self.tstamp)+']'

posaudio = 0
posvideo = 0
curtime = 0
endv = video['chunks'][0]
enda = audio['chunks'][0]

videosize = sum(viddlsizes)+sum(audlsizes)

dl_bytes = []
dl_stamps = []
# Frames generated with 25fps
frate = 25
flen = 1.0/frate
timescale = 10000000
frames = []
frame_stamps = [0]

fnumber = 0

from datetime import timedelta

total = 0
totlen = 0
# synchronize audio + video chunks (generate virtual subchunks)
while posvideo < len(viddlstamps):
	if endv < enda:
		cvid = Chunk(curtime, endv-curtime, (endv-curtime)*1.0/video['chunks'][posvideo]*viddlsizes[posvideo], viddlq[posvideo], viddlstamps[posvideo])
		caud = Chunk(curtime, endv-curtime, (endv-curtime)*1.0/audio['chunks'][posaudio]*audlsizes[posaudio], audlq[posaudio], audlstamps[posaudio])
		posvideo+=1
		curtime = endv
		if posvideo < len(video['chunks']):
			endv += video['chunks'][posvideo]
	else:
		caud = Chunk(curtime, enda-curtime, (enda-curtime)*1.0/audio['chunks'][posaudio]*audlsizes[posaudio], audlq[posaudio], audlstamps[posaudio])
		cvid = Chunk(curtime, enda-curtime, (enda-curtime)*1.0/video['chunks'][posvideo]*viddlsizes[posvideo], viddlq[posvideo], viddlstamps[posvideo])
		if enda == endv:
			posvideo += 1
		posaudio+=1
		curtime = enda
		if posaudio < len(audio['chunks']):
			if endv == curtime:
				endv += video['chunks'][posvideo]
			enda += audio['chunks'][posaudio]
	#print 'audio: '+caud.tostr()
	#print 'video: '+cvid.tostr()+'\n'
	totlen += caud.lent
	total += caud.lenb + cvid.lenb
	dl_bytes.append(caud.lenb+cvid.lenb)
	#dl_stamps.append(caud.tstamp)
	(frac, integer) = math.modf(caud.tstamp)
	dl_stamps.append(timedelta(seconds=int(integer), microseconds=int(frac*1000000)))
	# gen frames
	fnum = caud.lent * 1.0 / timescale / flen
	if int(fnum) > 0:
		fsize = ((caud.lenb+cvid.lenb)/fnum)*int(fnum)/int(fnum)
		fnum = int(fnum)
	else:
		fnum = 0
		fsize = 0
	for i in range(0, fnum):
		f = results_classes.Frame()
		f.number = fnumber
		fnumber += 1
		f.size = fsize
		f.avgrate = (caud.q + cvid.q)/1024 # conv to kbits
		f.time = flen
		frames.append(f)
	# generate irregular frame
	if (caud.lenb+cvid.lenb) - fsize*fnum > 0:
		f = results_classes.Frame()
		f.number = fnumber
		fnumber += 1
		f.size = (caud.lenb+cvid.lenb) - fsize*fnum
		f.avgrate = (caud.q + cvid.q)/1024 # conv to kbits
		f.time = caud.lent * 1.0 / timescale - fnum * flen
		frames.append(f)
last = 0
videosize = 0
for f in frames:
	t = f.time
	f.time = last+t
	last = f.time
	frame_stamps.append(f.time)
	videosize += f.size

import results_playbackmodels
import results_plotting
import results_helpermethods
####
def printStallStatsH(stalls):
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
def printStallStatsM(stalls):
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

"""
for model in (["faststall",results_playbackmodels.faststallingbuffersizealg], ["yt_",results_playbackmodels.ytflashalg], ["firefox",results_playbackmodels.firefoxhtml5alg]):
	(bufferlevels, frame_timestamps, total_offset, stalls) = model[1](frames, frame_stamps, dl_stamps, dl_bytes, videosize)
	print "calculating buffer levels using "+model[0]
	modname = model[0]+'_'+video_name
	#outputmode = "plotbuffertime"

	#if (outputmode == "stath"):
	printStallStatsH(stalls)
	#elif (outputmode == "statm"):
	printStallStatsM(stalls)
	#elif (outputmode == "plotbuffer"):
	results_plotting.plotbuffer(bufferlevels, modname, modname, subtitlestring="")
	#elif (outputmode == "plotbuffertime"):
	results_helpermethods.calcBufferlevelsInSeconds(bufferlevels, frame_timestamps, frame_stamps, frames, videosize)
	results_plotting.plotbufferseconds(bufferlevels, modname, modname, subtitlestring="")
	#elif (outputmode == "plotrates"):
	results_plotting.plotdlvsfrrate(dl_stamps, dl_bytes, videosize, frames, modname, modname, 1)
	#elif (outputmode == "plotcumdata"):
	results_plotting.plotadditiveframedownloadbytes(dl_stamps, dl_bytes, videosize, frames, frame_timestamps, modname, modname)
"""

f = open(video_name+'.framelog', 'w')
ssize = 0
for frame in frames:
	ssize += frame.size
	f.write('frame= '+str(frame.number)+' q= 0 f_size= '+str(int(frame.size))+' s_size= '+str(int(ssize/1024))+'kB time= '+str(frame.time)+' br= '+str(frame.avgrate)+'kbits/s avg_br= 0kbits/s type= P\n')
f.close()

from datetime import datetime
now = datetime.now()

f = open(video_name+'.downloadlog', 'w')
ssize = 0
for i in range(0, len(dl_stamps)):
	now = now + dl_stamps[i]
	if (i>0):
		now = now - dl_stamps[i-1]
	f.write(now.strftime("%H:%M:%S.%f")+' <= Recv data, '+str(int(dl_bytes[i]))+' bytes (0x00)\n')
f.close()

f = open(video_name+'.log', 'w')
f.write('url : '+base_url+'\n')
f.write('file_size: '+str(int(sum(dl_bytes))))
f.close()

f = open(video_name+'.mediainfo', 'w')
f.close()


sys.stdout.flush()
