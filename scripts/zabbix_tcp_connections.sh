#!/usr/bin/env bash

tcp_connections=0
netstat_info=$(netstat -an |awk '/^tcp/ {++S[$NF]}END{for(a in S)print a, S[a]}'| grep $1|awk '{print $2}')
# netstat_info=$(ss -an |awk '/^tcp/ {++S[$2]}END{for(a in S)print a, S[a]}'| grep $1|awk '{print $2}')
# ss出来的结果关键字不一样
if [ -z "$netstat_info" ]; then
    echo $tcp_connections
else
    echo $netstat_info
fi
