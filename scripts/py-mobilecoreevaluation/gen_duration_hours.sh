#!/bin/bash

awk -F" " 'function abs(x){return ((x < 0.0) ? -x : x)} BEGIN{begintime="1302386400"}; {print $2, abs(int((($1-begintime)/3600)))%24}' duration_timeofday > duration_hours

sort duration_hours -t ' ' -nk 2 > duration_hours_sorted
