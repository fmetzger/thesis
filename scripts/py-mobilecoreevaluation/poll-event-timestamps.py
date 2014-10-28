#!/usr/bin/python
# -*- coding: utf-8 -*-

import pymysql
import sys
from decimal import *
import datetime

try:

  fields = {
    'ts_create_all': {
      'query' : "SELECT timestamp AS ts_create FROM gtp WHERE event_type = 0 ORDER BY timestamp ASC",
      'name' : 'All Create Timestamps',
      'enabled': False,
    },
    'ts_create_successful': {
      'query' : "SELECT timestamp AS ts_create FROM gtp WHERE cause_value = 128 AND event_type = 0 ORDER BY timestamp ASC",
      'name' : 'Successful Create Timestamps',
      'enabled': True,
    },
    'ts_delete_all': {
      'query' : "SELECT timestamp_event_requested AS ts_delete FROM gtp WHERE event_type = 2 ORDER BY timestamp_event_requested ASC",
      'name' : 'All Delete Timestamps',
      'enabled': False,
    },
    'ts_delete_successful': {
      'query' : "SELECT timestamp_event_requested AS ts_delete FROM gtp WHERE cause_value = 128 AND event_type = 2 ORDER BY timestamp_event_requested ASC",
      'name' : 'Successful Delete Timestamps',
      'enabled': False,
    },
    'ts_update_all': {
      'query' : "SELECT timestamp_event_requested AS ts_update FROM gtp WHERE event_type = 1 ORDER BY timestamp_event_requested ASC",
      'name' : 'All Update Timestamps',
      'enabled':False,
    },
    'ts_update_successful': {
      'query' : "SELECT timestamp_event_requested AS ts_update FROM gtp WHERE cause_value = 128 AND event_type = 1 ORDER BY timestamp_event_requested ASC",
      'name' : 'Successful Update Timestamps',
      'enabled':False,
    },
      'ts_create_umts': {
      'query' : "SELECT timestamp AS ts_create FROM gtp WHERE event_type = 0 AND rat_type='1' ORDER BY timestamp ASC",
      'name' : 'All Create Timestamps from umts connections (useless: ~1k results)',
      'enabled': False,
    },
      'ts_create_gprs': {
      'query' : "SELECT timestamp AS ts_create FROM  gtp WHERE event_type = 0 AND rat_type='2' ORDER BY timestamp ASC",
      'name' : 'All Create Timestamps from gprs connections (useless: ~1k results)',
      'enabled': False,
    },
      '__OLD_ts_create_firstflow_gprs': {
      'query' : "SELECT timestamp_tunnel_start AS ts_create FROM (SELECT * FROM flows ORDER BY timestamp_tunnel_start ASC) AS tmp_sorted WHERE rat='GERAN' GROUP BY timestamp_tunnel_start,imsi",
      'name' : 'First occurence of a tunnel create timestamps from gprs connections from the flow table',
      'enabled': False,
    },
    'ts_create_firstflow_gprs': {
      'query' : "SELECT timestamp_tunnel_start AS ts_create FROM (SELECT * FROM flows ORDER BY id ASC) AS tmp_sorted GROUP BY timestamp_tunnel_start,imsi WHERE rat='GERAN'",
      'name' : 'First occurence of a tunnel create timestamps from gprs connections from the flow table',
      'enabled': False,
    },
    'ts_create_firstflow_umts': {
      'query' : "SELECT timestamp_tunnel_start AS ts_create FROM (SELECT * FROM flows WHERE rat='UTRAN' ORDER BY timestamp_tunnel_start ASC) AS tmp_sorted GROUP BY timestamp_tunnel_start,imsi",
      'name' : 'First occurence of a tunnel create timestamps from gprs connections from the flow table',
      'enabled': False,
    },
      'PERS_ts_create_firstflow_gprs': {
      'query' : "SELECT timestamp_tunnel_start FROM (SELECT DISTINCT (timestamp_tunnel_start, imsi) FROM flows as f) AS flow_starts WHERE (SELECT rat FROM flows WHERE flows.timestamp_tunnel_start = flow_starts.timestamp_tunnel_start AND flows.imsi = flow_starts.timestamp_tunnel_start ORDER BY id LIMIT 1) = 'GERAN'",
      'name' : 'First occurence of a tunnel create timestamps from gprs connections from the flow table',
      'enabled': False,
    },
      'PERS_ts_create_firstflow_umts': {
      'query' : "SELECT timestamp_tunnel_start FROM (SELECT DISTINCT (timestamp_tunnel_start, imsi) FROM flows ) AS flow_starts WHERE (SELECT rat FROM flows WHERE flows.timestamp_tunnel_start = flow_starts.timestamp_tunnel_start AND flows.imsi = flow_starts.imsi ORDER BY id LIMIT 1) = 'UTRAN'",
      'name' : 'First occurence of a tunnel create timestamps from gprs connections from the flow table',
      'enabled': False,
    },
      'PERS_ts_create_firstflow_radiotype': {
      'query' : "SELECT timestamp_tunnel_start,(SELECT f2.rat FROM flows as f2 WHERE f2.id = MIN(f.id)) FROM flows as f GROUP BY f.timestamp_tunnel_start, f.imsi ORDER BY MIN(f.id) ASC",
      'name' : 'First occurence of a tunnel create timestamps from gprs connections from the flow table (DISTINCT may not be necessary anymore)',
      'enabled': False,
    },

  }
  # ts_update_successfull done, dont touch them!

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
          start = datetime.datetime.now()
          print str(start) + ": " + query_tmp
          cur.execute(query_tmp)
          rows = cur.fetchall()
          if len(rows) == 0:
            break
          for row in rows:     
            main = Decimal(row[0] >> 32)
            rest = Decimal(float(row[0] & (2**32 - 1)) / 2**32)
            floatValue = main + rest
            rowcounter += 1
            f.write(str(floatValue))
            if (len(row) > 1):
              f.write(" " + row[1])
            f.write("\n")
          offsetsize += query_limit
          f.flush()
        
        stop = datetime.datetime.now()
        print "Fetched " + str(rowcounter) + " records in " + str((stop-start).total_seconds()/3600) + " hours"
        f.close()

    except IOError as e:
      print 'error opening out/' + fieldname
      continue

    cur.close()

  con.close()
  
except pymysql.Error, e:

  print "Error %s: %s" % (e.args[0],e.args[1]) 
  sys.exit(1)