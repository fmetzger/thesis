#!/usr/bin/python
# -*- coding: utf-8 -*-

from decimal import *

#files = ["out/ts_create_successful", "out/ts_create_all", "out/ts_delete_successful", "out/ts_delete_all", "out/ts_update_successful", "out/ts_update"]
#files = ["out/ts_create_successful"]
files = ["out/PERS_ts_create_firstflow_radiotype_sorted"]


## cutting will break at large gaps
## e.g., when 2^32 unix timestamps occur, which should not be possible
## (but does happen)

blocksize = 7200 # 2h blocks
cyclelength = 86400 # 1 day
numblocks = cyclelength/blocksize # should be 12 for 2h blocks per day
totaldelta = 0

for filename in files:
	with open(filename,'r') as f:
		print filename

		#first_timestamp = Decimal(f.readline())
		first_timestamp = 1302472800 # Mo 11 Apr 2011 00:00:00 CEST
		last_timestamp = 1303077600 # Mo 18 Apr 2011 00:00:00 CEST upper limit

		iteration = 1

		lines = f.readlines()
		f_out = open(filename+"_0",'w')

		for l in lines:
			x = l.split(' ')[0]
			dec = Decimal(x)
			if (dec >= first_timestamp) and (dec <= last_timestamp):
				if (dec - first_timestamp) < (blocksize*iteration):
					f_out.write(l)
				else:
					f_out.close()
					f_out = open(filename+"_"+str(blocksize*iteration),'w')
					iteration += 1
					print str(blocksize*iteration)
		f_out.close()





