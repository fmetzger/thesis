#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb as mdb
import sys
import array
import numpy
import math
import sys

import time
from collections import OrderedDict
import datetime

con = None

fields = {
    'total_imsis_gtp': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp",
      'enabled': False,
    },
    'total_imsis_flows': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.flows",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices)",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB classified as smartphone/tablet': {
      'query' :"SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': False,
    },    
    'number of distinct imsis with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB classified as iOS': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB classified as Android': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': False,
    },
    'number of distinct imsis with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT COUNT(DISTINCT imsi) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': False,
    },






    'total number of completed tunnels (successful DELETE events)': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2",
      'enabled': False,
    },   
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices)",
      'enabled': False,
    },  
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as smartphone/tablet': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': False,
    },
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': False,
    },
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': False,
    },
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': False,
    },
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as iOS': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': False,
    },
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as Android': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': False,
    },
    'total number of completed tunnels (successful DELETE events) with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE cause_value = 128 AND event_type = 2 AND tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': False,
    },
    


    'total number of GTP tunnel management messages': {
      'query' : "SELECT COUNT(*) FROM data2.gtp",
      'enabled': False,
    },   
    'total number of GTP tunnel management messages with entry in TAC DB': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices)",
      'enabled': False,
    },  
    'total number of GTP tunnel management messages with entry in TAC DB classified as smartphone/tablet': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': False,
    },
    'total number of GTP tunnel management messages with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': False,
    },
    'total number of GTP tunnel management messages with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': False,
    },
    'total number of GTP tunnel management messages with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': False,
    },
    'total number of GTP tunnel management messages with entry in TAC DB classified as iOS': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': False,
    },
    'total number of GTP tunnel management messages with entry in TAC DB classified as Android': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': False,
    },
    'total number of GTP tunnel management messages with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT COUNT(*) FROM data2.gtp WHERE tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': False,
    },
    
    
    'total traffic (bytes)': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows",
      'enabled': True,
    },    
    'total traffic (bytes) with entry in TAC DB': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices)",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as smartphone/tablet': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as iOS': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as Android': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': False,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': False,
    }, 
    
    'total traffic (bytes)': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows",
      'enabled': True,
    },    
    'total traffic (bytes) with entry in TAC DB': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices)",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as smartphone/tablet': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as iOS': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as Android': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': True,
    }, 
    'total traffic (bytes) with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT (SUM(`up_physical_bytes` + `down_physical_bytes`)) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': True,
    }, 
    
    
    'upstream traffic (bytes)': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows",
      'enabled': False,
    },    
    'upstream traffic (bytes) with entry in TAC DB': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices)",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as smartphone/tablet': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as iOS': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as Android': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': False,
    }, 
    'upstream traffic (bytes) with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT SUM(`up_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': False,
    }, 
    

    'downstream traffic (bytes)': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows",
      'enabled': False,
    },    
    'downstream traffic (bytes) with entry in TAC DB': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices)",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as smartphone/tablet': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='1' OR class='3')",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as business phone (blackberry)': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='7')",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as regular / feature phone': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='4')",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as 3G dongle/router': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE class='2' OR class='5')",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as iOS': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='2')",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as Android': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='1')",
      'enabled': False,
    }, 
    'downstream traffic (bytes) with entry in TAC DB classified as Symbian/S40/S60': {
      'query' : "SELECT SUM(`down_physical_bytes`) FROM data2.flows WHERE tac IN (SELECT tac from data2.devices WHERE os='3' OR os='6')",
      'enabled': False,
    }, 
}

fetchsize = 1000


try:
  
  con = mdb.connect(host="127.0.0.1", user="root", passwd="qweasd", port=3306, db="data2");
  cur = con.cursor()

  for fieldname, options in fields.items():
    if options['enabled'] == False:
      continue
    collectedValues = array.array('f')
    
# alle apple TACs
#    query = "SELECT " + options['query'] + " FROM gtp WHERE cause_value = 128 AND event_type = 2 AND timestamp_tunnel_start > 0 AND timestamp_event_requested > timestamp_tunnel_start AND  tac IN (SELECT tac FROM devices WHERE vendor='Apple') LIMIT 1000;"
# alle rat_type 1 (gsm) / 2 (umts); achtung! koennte sich rat_type nicht geaendert haben? reicht rat_type im DELETE aus?
    query = options['query']
    print query
    cur.execute(query)
    
    while True:
      # do not fetch huge result sets at once into memory
      rows = cur.fetchmany(fetchsize)
      if len(rows) == 0:
        break
        
      print "Processing " + str(fetchsize) + " records..."
      
      print fieldname + ": " + str(rows)
    
      print fieldname + ": "
      for row in rows:
        for field in row:
          print(str(field))

  
except mdb.Error, e:

  print "Error %d: %s" % (e.args[0],e.args[1])
  sys.exit(1)

finally:

  if con:
    con.close()