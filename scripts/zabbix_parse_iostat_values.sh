#!/bin/bash

dev=$1

type=$2

#enable debug mode
debug=0

if [[ -z "$dev" ]]; then
  echo "error: wrong input value (device)"
  exit 1
fi

if [[ -z "$type" ]]; then
  echo "error: wrong input value (type),type:['rrqm/s'|'wrqm/s'|'r/s'|'w/s'\
|'rkB/s'|'wkB/s'|'avgrq-sz'|'avgqu-sz'|'await'|'svctm'|'%util'"
  exit 1
fi

columns=`iostat -xN |egrep -o "^Device.*"`

columnsarray=($columns)

column_id=1

for i in "${columnsarray[@]}"
do
        #echo "column: $i"

        if [[ "$i" = "$type" ]]; then

            if [[ $debug -eq 1 ]]; then
                echo "right column (${i}) found...column_id: $column_id "
            fi

            id="$"
            column_id_id=$id$column_id

	    iostat -xN 2 2 > /tmp/iostat.tmp 2>&1
            iostats=`cat /tmp/iostat.tmp|egrep -o "^${dev}[[:space:]]+.*" |sed -n 2p|awk "{print ${column_id_id}}"`
        fi
    column_id=$[column_id + 1]
done

if [ -z "$iostats" ]; then
    echo "error: \"device\" or \"type\" not found (${dev},${type})"
    exit 3
fi

iostats_lines=`wc -l <<< "$iostats"`

if [ $iostats_lines -ne 1 ]; then
    echo "error: wrong output value (${iostats_lines})"
    exit 2
fi

echo $iostats

if [[ $debug -eq 1 ]]; then
    echo "- - - - - - - - - -"
    echo $columns
    iostats_debug=`iostat -xN |egrep -o "^${dev}[[:space:]]+.*"`
    echo $iostats_debug
    echo "- - - - - - - - - -"
fi

exit 0
