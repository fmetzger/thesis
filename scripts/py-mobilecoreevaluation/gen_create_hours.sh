#!/bin/bash

awk -F" " 'function abs(x){return ((x < 0.0) ? -x : x)} BEGIN{begintime="1302386400"}; {print $1, abs(int((($1-begintime)/3600)))%24}' ts_create_all > ts_create_all_hours

sort ts_create_all_hours -t ' ' -nk 2 > ts_create_all_sorted