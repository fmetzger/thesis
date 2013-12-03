# -*- coding: utf-8 -*-
"""
Created on Wed Nov 23 16:18:56 2011

@author: fm
"""

import math

###############################################################################
class Frame:
  number = 0
  size = 0
  avgrate = 0
  ftype = 'N'
  time = 0.0
###############################################################################


###############################################################################  
class Bufferlevel:
  def __init__(self):
    self.timestamps = [0.0]
    self.level = [0.0]
    self.levelseconds = []
###############################################################################

###############################################################################
class Stall:
    """ used for statistics about stalls """
    def __init__(self, stype="", start = 0.0, end = 0.0):
        self.type = stype          # either Stall or Playback
        self.start = start
        self.end = end
###############################################################################    
    
    
###############################################################################
class EWMA:
    """ moving average """
    def __init__(self, weight, initialvalue = 1.0, allowdoubletimestamps=True):
        self.weight = weight
        self. historicvalue = initialvalue
        self.parsedevents = list()
        self.allowdoubletimestamps = allowdoubletimestamps
    
    def addValue(self, event):
        if self.allowdoubletimestamps == False:
            if event.timestamp in self.parsedevents:
                return      # already parsed and we dont parse double entries
                
        self.historicvalue = self.weight*math.fabs(event.eventsize) + (1.0-self.weight)*self.historicvalue
        self.parsedevents.append(event.timestamp)
        
    def getAvg(self):
        return self.historicvalue
        
###############################################################################




###############################################################################


def nullDecision(eventQueue):
    return True
    
def scalingDecision(scaleQueue):
    vidEWMA = scaleQueue.vidEWMA.getAvg()
    transEWMA = scaleQueue.transEWMA.getAvg()
    value = (vidEWMA / transEWMA) * scaleQueue.gamma
    print "vidEWMA: " + str(vidEWMA)
    print "transEWMA: " + str(transEWMA)
    print "Deciding value is " + str(value)
    if value > 10:
        return True
        
    return False
         

class EventQueue():
    """
    playstate is NOTSTARTED|PLAYING|STALLED|COMPLETED
    """
    def __init__(self, decisionAlg):
        self.framequeue = list()     # test with a list first
        self.framelist = list()
        self.packetqueue = list()
        
        self.decisionAlg = decisionAlg
        
        print "base class constructor called"
        self.playstate = "NOTSTARTED"
    
        self.currentBufferSize=0
        self.totaldownloadeddata = 0
        
    def addEvent(self, bufferevent):
        if isinstance(bufferevent, FrameEvent):
            self.framequeue.append(bufferevent)
            self.framelist.append(bufferevent)
            
        elif isinstance(bufferevent, PacketEvent):
            self.packetqueue.append(bufferevent)
        else:
            raise Exception("Attempted to add unknown event type.")
        
        
        
    def pauseFrameEvents(self, stallevent):
        """
        change state to STALLED
        readd the causing event to the queue
        """
        print "stall occured, pausing all frame events"
        self.playstate = "STALLED"
        self.framequeue.append(stallevent)
                
                
    def resumeFrameEvents(self, resumeevent):
        """
        set state to playing again
        add the stalled duration to all remaining frame events
        """
        print "resume decision made"
        self.playstate = "PLAYING"
        self.framequeue = sorted(self.framequeue, key=lambda event: event.timestamp, reverse=True)
        delta = resumeevent.timestamp - self.framequeue[-1].timestamp
        
        tmp_framequeue = list()
        for event in self.framequeue:
            event.timestamp += delta
            tmp_framequeue.append(event)
        self.framequeue = tmp_framequeue
        
    def getNextEvent(self):
        
        event = None
        print len(self.packetqueue)
        print len(self.framequeue)
        
        if self.playstate == "PLAYING":
            if len(self.packetqueue) == 0 or  self.framequeue[-1].timestamp < self.packetqueue[-1].timestamp:
                event = self.framequeue.pop(-1)
            else:
                event = self.packetqueue.pop(-1)
        
        elif self.playstate == "STALLED" or self.playstate == "NOTSTARTED":
            event = self.packetqueue.pop(-1)
                
        elif len(self.packetqueue) == 0 and len(self.framequeue) == 0:
            self.playstate = "COMPLETED"
            
        return event
        
    def processEvents(self):
        """ prepare the event lists and process them """
        self.framelist = sorted(self.framelist, key=lambda event: event.timestamp, reverse=True)
        self.framequeue = sorted(self.framequeue, key=lambda event: event.timestamp, reverse=True)
        self.packetqueue = sorted(self.packetqueue, key=lambda event: event.timestamp, reverse=True)
        
        print len(self.framequeue)
        print len(self.packetqueue)
        
        while len(self.framequeue) > 0 or len(self.packetqueue) > 0:
            self.getNextEvent().processEvent(self, self.decisionAlg)
            
    def updateBufferLevel(self, value):
        self.currentBufferSize += value
        if value > 0:
            self.totaldownloadeddata += value




class ScaleQueue(EventQueue):
    def __init__(self, alpha, beta, gamma):
        EventQueue.__init__(self, scalingDecision)
        self.vidEWMA = EWMA(alpha)
        self.transEWMA = EWMA(beta, allowdoubletimestamps=False)
        self.gamma = gamma
        
        
        
class LoggingScaleQueue(ScaleQueue):
    def __init__(self, alpha, beta, gamma):
        ScaleQueue.__init__(self, alpha, beta, gamma)
        self.playback_phase_list = list()
        self.total_stalling_time = 0
        self.frame_timestamp_list = list()
        self.bufferlevel = Bufferlevel()
        
    def processEvents(self):
        s = Stall("Stall", start = 0.0)
        self.playback_phase_list.append(s)        
        EventQueue.processEvents(self)
        
        
    def pauseFrameEvents(self, stallevent):
        EventQueue.pauseFrameEvents(self, stallevent)
        
        self.playback_phase_list[-1].end = stallevent.timestamp
        s = Stall("Stall", start = stallevent.timestamp)
        self.playback_phase_list.append(s)
        
    def resumeFrameEvents(self, resumeevent):
        EventQueue.resumeFrameEvents(self, resumeevent)
        
        self.playback_phase_list[-1].end = resumeevent.timestamp
        s = Stall("Playback", start = resumeevent.timestamp)
        self.playback_phase_list.append(s)
        
    def getNextEvent(self):
        event = EventQueue.getNextEvent(self)
        self.playback_phase_list[-1].end = event.timestamp
        return event
            

class BufferEvent:
    """ 
    assume negative event sizes for buffer drains 
    """
    
    def __init__(self, timestamp, eventsize):
        self.timestamp = timestamp
        self.eventsize = eventsize
        
    def processEvent(self, eventQueue, decisionAlgorithm):
        print "Event at timestamp " + str(self.timestamp) + "; Size: " + str(self.eventsize) + " curr_bufsize: " + str(eventQueue.currentBufferSize) + "; Type: " + str(self)
        
        

class FrameEvent(BufferEvent):
        
    def processEvent(self, eventQueue, decisionAlgorithm):
        cbufsize = eventQueue.currentBufferSize + self.eventsize
        if cbufsize < 0: # roll back the event, drop all future frame events
            eventQueue.pauseFrameEvents(self)
        else:
            eventQueue.updateBufferLevel(self.eventsize)
        
        eventQueue.bufferlevel.timestamps.append(self.timestamp)
        eventQueue.bufferlevel.level.append(eventQueue.currentBufferSize)
        
        
        BufferEvent.processEvent(self, eventQueue, decisionAlgorithm)
        
    
        
        
        
class PacketEvent(BufferEvent):
    
    def processEvent(self, eventQueue, decisionAlgorithm):
        eventQueue.updateBufferLevel(self.eventsize)
        if eventQueue.playstate == "STALLED" or eventQueue.playstate == "NOTSTARTED":
            if decisionAlgorithm(eventQueue) == True:   # decided for restart
                eventQueue.resumeFrameEvents(self)
        
        if isinstance(eventQueue, ScaleQueue):
            self.updateEWMAs(eventQueue)
            
            
        eventQueue.bufferlevel.timestamps.append(self.timestamp)
        eventQueue.bufferlevel.level.append(eventQueue.currentBufferSize)
            
        BufferEvent.processEvent(self, eventQueue, decisionAlgorithm)
        
    def updateEWMAs(self, scaleQueue):
        """
        calculate the video bitrate of the currently downloaded dataset,
        not just of the alreadyy played dataset
        """
        scaleQueue.transEWMA.addValue(self)
        
        tmpsum = 0
        for event in scaleQueue.framelist:
            tmpsum += (-1) * event.eventsize
#            print tmpsum
            if tmpsum > scaleQueue.totaldownloadeddata:
                break
            else:
                scaleQueue.vidEWMA.addValue(event)
        
        