# -*- coding: utf-8 -*-
"""
Created on Wed Nov  9 11:57:24 2011

@author: metzger

reads a batch file of to be tested video streams
calls the appropriate download script file with the correct parameters
"""

import os

if __name__ == "__main__":
    f_in = open("download.list", 'r')
    for line in f_in:    
        print line
        
        data = line.split(" ")
        if data[0] == "youtube":
            os.system("python ytdl.py " + data[1])
            
    
    f_in.close()