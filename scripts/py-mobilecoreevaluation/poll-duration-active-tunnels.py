#!/usr/bin/python
# -*- coding: utf-8 -*-

import pymysql
import sys
from decimal import *
import datetime

try:
  fields = {
    'duration_activetunnels': {
      'query' : "SELECT timestamp_tunnel_start, timestamp_event_requested from data2.gtp gtp WHERE EXISTS ( SELECT * FROM data2.flows WHERE imsi=gtp.imsi AND timestamp_tunnel_start=gtp.timestamp_tunnel_start) AND gtp.event_type=2 AND gtp.cause_value=128  AND timestamp_tunnel_start > 0 ",
      'plotStyle' : 'r-',
      'name' : 'duration of tunnels with an active flow',
      'enabled': True,
    }
  }

  query_limit = 1000000
  offsetsize = 0
  con = pymysql.connect(host="127.0.0.1", user="root", passwd="qweasd", port=3306, db="data2")
  
  for fieldname, options in fields.items():
    if options['enabled'] == False:
      continue

    offsetsize = 0
    rowcounter = 0

    try:
      with open('out/'+fieldname, 'w') as f:
      
        query = options['query']
        cur = con.cursor()
        
        
        while True:
          query_tmp = query + " LIMIT " + str(query_limit) + " OFFSET " + str(offsetsize)
          print query_tmp
          cur.execute(query_tmp)
          rows = cur.fetchall()
          if len(rows) == 0:
            break
          for row in rows: # unpack rows
            line = ""
            for field in row: # unpack fields   
              main = Decimal(field >> 32)
              rest = Decimal(float(field & (2**32 - 1)) / 2**32)
              floatValue = main + rest
              line = line + str(floatValue) + " "
            rowcounter += 1
            f.write(line[0:-1] + "\n")
          offsetsize += query_limit
          f.flush()
        
        print "Fetched " + str(rowcounter) + " records"
        f.close()

    except IOError as e:
      print 'error opening out/' + fieldname
      continue

    cur.close()

  con.close()
  
except pymysql.Error, e:

  print "Error %d: %s" % (e.args[0],e.args[1])
  sys.exit(1)
