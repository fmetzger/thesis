#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
ytdl_refactored.py



Required python packages:
python-gdata
python-matplotlib
python-numpy

"""

import urllib2
import urllib
import os
import subprocess
import sys
import string
import re
import socket
import datetime
from datetime import datetime
import gdata.youtube
import gdata.youtube.service


print "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
print "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
print "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"



class Tools:
    """
    The class Tools contains several @classmethod functions.
    You can call these functions without initializing a Tools object, just as
    simple as Tools.write("filename","Hello Tools").
    
    The private helper function works like a wrapper for subprocess.Popen().
    It returns the processes std out.
    """
        
    def __init__(self):
        # ?
        pass
    
    @classmethod
    def chdir(self, directory):
        if os.access(directory, os.F_OK) is False:
            os.mkdir(directory)
        os.chdir(directory)
    
    @classmethod
    def pwd(self):
        return os.getcwd()
    
    @classmethod
    def __helper(self, pstring):
        run = subprocess.Popen(pstring, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        return run.stdout.read()
    
    @classmethod
    def traceroute(self, ip, interface=None):
        if interface is not None:
            return self.__helper("traceroute -i " + interface + " " + ip)
        else:
            return self.__helper("traceroute " + ip)
    
    @classmethod
    def lft(self, ip, opt=""):
        return self.__helper("lft " + opt + " " + ip)
    
    @classmethod
    def ping(self, ip, interface=None):
        if interface is not None:
            return self.__helper("ping -c 10 -I " + interface + " " + ip)
        else:
            return self.__helper("ping -c 10 " + ip)
    
    @classmethod
    def whob(self, ip, opt=""):
        return self.__helper("whob " + opt + " " + ip)
    
    @classmethod
    def mediainfo(self, mfile):
        return self.__helper("mediainfo " + mfile)
    
    @classmethod
    def mplayer(self, mfile):
        # remove all vstats file beforehand                    
        filelist = os.listdir(".")
        for vfile in filelist:
            if "vstats_" in vfile:
                os.remove(vfile)
        
        os.system("mplayer " + mfile)
    
    
    @classmethod
    def curl(self, url, user_agent, interface=None):
        download_start = datetime.now()

        url = str(url)
        user_agent = str(user_agent)
        print "url is " + url
        
        if interface is not None:
            os.system("curl \"" + url + "\" " + "--interface " + interface + " --location --retry 10 --retry-delay 1 --user-agent \"" + user_agent + "\" --trace-time --trace-ascii curltrace > curlout")
        else:
            print "foo"
            os.system("curl \"" + url + "\" --location --retry 10 --retry-delay 1 --user-agent \"" + user_agent + "\" --trace-time --trace-ascii curltrace > curlout")
            print "bar"
        download_end = datetime.now()
        return download_end - download_start
                
    @classmethod
    def tcpdump(self, hostname, interface=None):
        if interface is not None:
            args = ["tcpdump", "-i", interface, "-w", "capture.log", "host", hostname]
        else:
            #args = ["tcpdump",  "-w", "capture.log", "host", hostname]args = ["tcpdump",  "-w", "capture.log", "host", hostname]
            #dont filter for hostname at the moment
            args = ["tcpdump",  "-w", "capture.log"]
        return subprocess.Popen(args)
    
    @classmethod
    def getIPAddrsList(self, hostname):
        (hostnamelist, aliaslist, ipaddrslist) = socket.gethostbyname_ex(hostname)
        return ipaddrslist
    
    @classmethod
    def ytBrowser(self, video_id):
        write = ""
        
        # gather data from gdata API
        yt_service = gdata.youtube.service.YouTubeService()
        yt_service.ssl = False
        entry = yt_service.GetYouTubeVideoEntry(video_id=video_id)
        
        write += "video_title: " + entry.media.title.text + "\n"
        
        vc = '0'
        if hasattr(entry.statistics, 'view_count'):
            vc = entry.statistics.view_count
        write += "video_viewcount: " + vc + "\n"
        
        vr = 'N/A'
        if hasattr(entry, 'rating') and hasattr(entry.rating, 'average'):
            vr = entry.rating.average
        write += "video_rating: " + vr + "\n"
        
        write += "video_url: " + entry.media.player.url + "\n"
        return write
    
    @classmethod
    def write(self, fname, write):
        f_out = open(fname, 'w')
        f_out.write(write)
        f_out.close()

class Video:
    """
    The video class    represents a YouTube video.
    It is created using a YouTube video ID and an user agent string.
    On initialization, the Video object loads the HTML source and 
    saves all found    URLs and hostnames in private fields.
    
    You can call several functions on a video object, 
    i.e. get it's YouTube URL, it's YouTube ID, etc.
    
    The agent argument stands for a user agent string used to request the 
    HTML source code of the webpage containing the YouTube video.
    
    Some example user agent strings:
    """
    
    def __init__(self, video_id, agent='Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; de-de) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27'):
        self.user_agent = agent
        self.vid = video_id
        self.siteString = self.__getHTMLString()
        self.urls = self.__getURLs()
        self.hostnames = self.__getHostnames()
    
    def getVideoID(self):
        return self.vid
    
    def getHTMLString(self):
        return self.siteString
    
    def __getHTMLString(self):
        headers = { 'User-Agent':self.user_agent }
        request = urllib2.Request(self.getURL(), None, headers)
        response = urllib2.urlopen(request)
        return response.read()
    
    def getURL(self):
        # get the full url of the video
        # returns http://www.youtube.com/watch?v=<video_id>
        return "http://www.youtube.com/watch?v=" + self.vid
    
    def getURLs(self):
        return self.urls
        """    
    def __getURLs(self):
        # find all video urls
        u = []

        # format changed Q2/Q3 2011
        strings = string.split(self.siteString, "flashvars=\"")[1]
        strings = string.split(strings,"\"")[0]
#        strings = string.split(strings,'\"};')[0]
        strings = string.split(strings,"&amp;")
        
        for s in strings:
            if "url_encoded_fmt_stream_map" in s:        # previously was fmt_stream_map
#                s = re.split(": \"\d\d|", s)[1]
                s = string.split(s, "url%3D")
                
                for rawurl in s:
                    if "http" in rawurl:
                        url = urllib.unquote(rawurl)
                        url = urllib2.unquote(url).replace("%3A",":").replace("%2F","/").replace("%3D","=").replace("%26","&").replace("%3F", "?").replace("%2C", ",")
                        url = url.rstrip(",")
                        print url
                        u.append(url)
        return u
        """        
        
    def __getURLs(self):
        # find all video urls
        u = []

        strings = string.split(self.siteString,"PLAYER_CONFIG")[1]  #extract the swfConfig first

        strings = string.split(strings,"});")[0]
        a_strings = string.split(strings,'url=')

        for i in range(len(a_strings)):
          if i != 0:
            index = a_strings[i].index('fallback_host')
            strings = a_strings[i][0:index-6] #i-6 = das letzte \u0026 (ampersand) entfernen
            url = urllib.url2pathname(strings).replace('\/','/').replace("\u0026","&")
            #print i,url
            u.append(url)
        return u
    
    def getHostnames(self):
        return self.hostnames
    
    def __getHostnames(self):
        hostnames = []
        for s in self.urls:
            hostname = s.split("//")[1].split("/")[0]
            hostnames.append(hostname)
        return hostnames
    
    def saveHTML(self):
        Tools.write("video.html", self.siteString)
    

class ExperimentManager:
    """
    The ExperimentManager manages everything for you.
    Just give him your prefered video id and your running network interfaces
    and the ExperimentManager will perform some serious measurments
    containing downloading, tracerouting, media analysis 'n stuff.
    
    Example user agent strings (captured and/or from en.wikipedia.org/ ):    
    user_agent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
    user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:2.0.0) Gecko/20110214 Firefox/4.0.0'
    user_agent = 'Mozilla/5.0 (X11; U; Linux i586; en-US; rv:1.7.3) Gecko/20040924 Epiphany/1.4.4 (Ubuntu)'
    user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.10) Gecko/2009042316 Firefox/3.0.10'
    user_agent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; de-de) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27'
    user_agent = 'Mozilla/5.0 (Ubuntu; X11; Linux x86_64; rv:8.0) Gecko/20100101 Firefox/8.0'
    user_agent = 'Mozilla/5.0 (Windows NT 6.1; rv:8.0) Gecko/20100101 Firefox/8.0'
    """
    def __init__(self, video_id, user_agent = 'Mozilla/5.0 (Windows NT 6.1; rv:8.0) Gecko/20100101 Firefox/8.0', interface=None):    
        self.user_agent = user_agent
        self.video = Video(video_id, self.user_agent)
        self.interface = interface
        self.__run()
    
    def __curlOK(self):
        """
        Here happens some renaming action after a successful download.
        Because we don't need every bit of information, we filter it a bit.
        """
        write = ""
        pattern = re.compile('^\d\d:\d\d:')
        
        f_in = open("curltrace", 'r')
        for line in f_in:
            if pattern.match(line):
                write += line
        return write
    
    def __run(self):
        """
        The »run the experiment« function
        Here happens the magic:
        - get urls and hostnames from video
        - measure download time 
        - get additional info using mediaplayer, mediainfo
        - measurements using ping, traceroute, whob
        perform all steps on each given networking interface
        """
        urls = self.video.getURLs()
        hostnames = self.video.getHostnames()
        
        Tools.chdir(self.video.getVideoID())
        
        path = Tools.pwd()
        
        Tools.chdir(path)

        if self.interface is not None:
            print "---> using interface " + self.interface + "\n"
            Tools.chdir(self.interface)
        
        
        
        # do this for every URL
        for u in urls:
            print "---> using URL " + u + "\n"
            
            #host = re.search('http\:\/\/([a-zA-Z0-9\.]*)\/',u).group(1)
            host = re.search('http\:\/\/([a-zA-Z0-9\.-]*)\/',u)
            if host is not None:
                host = host.group(1)
                print host
            prefix = str(urls.index(u))

            # run tcpdump
            #tcpdump = Tools.tcpdump(i, host)
            tcpdump = Tools.tcpdump(host, self.interface)
            
            # download using curl
            
            download_duration = Tools.curl(u, self.user_agent, self.interface)
                
            # stop tcpdump again
            tcpdump.terminate()
                
            # generic log file with additional data from gdata API
            write = "url : " + u + "\n"
            write += "file_size: " + str(os.path.getsize("curlout")) + "\n"
            write += "download_duration: " + str(float(download_duration.seconds) + float(download_duration.microseconds) / 1000000) + "\n"
                
            write += Tools.ytBrowser(self.video.getVideoID())
                
            Tools.write(prefix + ".log", write)                
            
            
            
                            
            # fs = os.path.getsize("curlout")
            if os.path.getsize("curlout") is not 0:
                # print "---> Logfile saved"
                
                # write downloadlog
                Tools.write(prefix + ".downloadlog", self.__curlOK())
                # print "---> Downloadlog saved"
                
                # generate framelog
                Tools.mplayer("curlout  -lavdopts vstats -vo null -ao null -speed 10")
                
                # assume that the vstats_* file is the one we want
                filelist = os.listdir(".")
                for vfile in filelist:
                    if "vstats_" in vfile:
                        os.rename(vfile, prefix + ".framelog")
                        
                    if "capture.log" in vfile:
                        os.rename(vfile, prefix + ".dump")
                # print "---> mediaplayer logfile saved"
                

                # aks mediainfo for extended information
                Tools.write(prefix + ".mediainfo", Tools.mediainfo("-f curlout"))
                # print "---> mediainfo logfile saved"
                
                # check for 302's (redirects)
                # store all additional URLs and hostnames from 302's
                f_302check = open(prefix + ".downloadlog",'r')
                for line in f_302check:
                    if "== Info: Issue another request to this URL:" in line:
                        
                        url302 = line.split(": \'")[1].rstrip("\'")
                        urls.append(url302)
                        
                        hostname302 = url302.split("//")[1].split("/")[0]
                        hostnames.append(hostname302)
                        # self.video.hostnames.append(hostname302)
                        
                        print "Got redirected to " + url302
                        print "Redirection hostname " + hostname302
                
                # TODO: delete remnant files (curlout, curltrace)
                
            else:
                os.rename("curltrace",prefix+".downloaderrorlog")
                print "Download resulted in a zero size file, check the error log for details.\n\n"
        
        # check every hostname in hostnamelist
        # run traceroute, ping, whob for every ip we find
        # save results in files
        for hn in hostnames:
            str_traceroute = ""
            str_ping = ""
            str_whob = ""
            
            prefix = str(hostnames.index(hn))
            
            for ip in Tools.getIPAddrsList(hn):
                
                # traceroute
                str_traceroute += Tools.traceroute(ip, self.interface) + "\n\n"
                
                # ping
                str_ping += Tools.ping(ip, self.interface) + "\n\n"
                
                # whob
                str_whob += Tools.whob(ip) + "\n\n"
                
                # lft
                # Tools.lft(ip, "-D " + i))
            
            Tools.write(prefix + ".traceroute", str_traceroute)
            print str_traceroute
            Tools.write(prefix + ".ping", str_ping)
            print str_ping
            Tools.write(prefix + ".whob", str_whob)    
            print str_whob


video_id = sys.argv[1]
iList = sys.argv[2:]

em = ExperimentManager(video_id, iList)


# TODO: command line options for tcpdump, modules for other streamers, default option with no given interface

