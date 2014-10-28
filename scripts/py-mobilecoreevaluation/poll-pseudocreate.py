#!/usr/bin/python
# -*- coding: utf-8 -*-

import pymysql
import sys
from decimal import *

try:
# AND timestamp_event_requested > timestamp_tunnel_start necessary?
# WHERE cause_vaule = 128 only successful?
  fields = {
    'ts_pseudocreate': {
      'query' : "SELECT timestamp_tunnel_start AS ts_create FROM gtp  WHERE event_type = 2 AND timestamp_tunnel_start > 0 ORDER BY timestamp ASC",
      'name' : 'Create TS from the DELETE events',
      'enabled': False,
    },
      'ts_pseudocreate_successful': {
      'query' : "SELECT timestamp_tunnel_start AS ts_create FROM gtp WHERE event_type = 2 AND cause_value = 128 AND timestamp_tunnel_start > 0 ORDER BY timestamp ASC",
      'name' : 'Create TS from successful DELETE events',
      'enabled': True,
    }
  }

  query_limit = 5000000
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
          for row in rows:     
            main = Decimal(row[0] >> 32)
            rest = Decimal(float(row[0] & (2**32 - 1)) / 2**32)
            floatValue = main + rest
            rowcounter += 1
            f.write(str(floatValue)+"\n")
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