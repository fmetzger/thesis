#!/usr/bin/python
# -*- coding: utf-8 -*-

import pymysql
import sys
from decimal import *

# exclude zero value time_stamp_event_requested fields
try:
  fields = {
    'time_act': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp  WHERE event_type = 0 AND timestamp_event_requested > 0  AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel activation time (no meaningful result for this metric (75k records with non-empty timestamps; theory 1: network-initiated creates are not measured by METAWIN or dont have request timestamps )',
      'enabled': False,
    },
      'time_act_successful': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp WHERE event_type = 0 AND cause_value = 128 AND timestamp_event_requested > 0 AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel activation time of successful events (no meaningful result for this metric (36k records with non-empty timestamps)',
      'enabled': False,
    },
      'time_act_alternate': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp  WHERE event_type = 0 AND timestamp_event_requested > 0  AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel activation time (no meaningful result for this metric (75k records with non-empty timestamps)',
      'enabled': True,
    },
      'time_act_successful_alternate': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp WHERE event_type = 0 AND cause_value = 128 AND timestamp_event_requested > 0 AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel activation time of successful events',
      'enabled': True,
    },
      'time_deact': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp  WHERE event_type = 2 AND timestamp_event_requested > 0 AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel deactivation time',
      'enabled': False,
    },
      'time_deact_successful': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp  WHERE event_type = 2 AND cause_value = 128 AND timestamp_event_requested > 0 AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel deactivation time of successful events',
      'enabled': True,
    },
      'time_update': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp  WHERE event_type = 1 AND timestamp_event_requested > 0 AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel update time',
      'enabled': False,
    },
      'time_update_successful': {
      'query' : "SELECT timestamp_event_finished AS t_finished, timestamp_event_requested AS t_requested FROM gtp  WHERE event_type = 1 AND cause_value = 128 AND timestamp_event_requested > 0 AND timestamp_event_finished > 0 ORDER BY timestamp ASC",
      'name' : 'tunnel update time of successful events',
      'enabled': False,
    },
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