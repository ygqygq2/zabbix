#!/usr/bin/env bash

args="$*"
args_count="$#"

function usage() {
    echo "Usage: $(basename $0) option (-d DIRECOTRY|-t TYPE)"
    echo "TYPE: undone|done|err|right"
}

function check_args() {
    if [ $args_count -lt 4 ]; then
        usage
        exit 55
    fi
}

while getopts ":d:t:" option; do
    case $option in
        d)
        # 要查看文件个数的目录
        dir=$OPTARG
        ;;
        t)
        # 查看要统计的类型,undone|done|right|err
        type=$OPTARG
        ;;
        *)
        usage
        ;;
    esac
done

shift $(($OPTIND - 1)) 

function calculation() {
    case $type in
        undone)
        files_count=$(find $dir -mtime -1 -type f 2>/dev/null|awk '{count++} END {print count}')
        ;;
        done)
        dir="/frsImage/$(date +%Y)/$(date +%F)"
        files_count=$(find $dir -mtime -1 -type f 2>/dev/null|grep 'done_'|awk '{count++} END {print count}')
        ;;
        err)
        dir="/frsImage/$(date +%Y)/$(date +%F)"
        files_count=$(find $dir -mtime -1 -type f 2>/dev/null|grep 'done_err'|awk '{count++} END {print count}')
        ;;
        right)
        dir="/frsImage/$(date +%Y)/$(date +%F)"
        files_count=$(find $dir -mtime -1 -type f 2>/dev/null|grep 'done_'|grep -v 'done_err'|awk '{count++} END {print count}')
        ;;
        *)
        usage
        ;;
    esac
}

check_args
calculation
[ "$files_count" -ge 0 ] 2>/dev/null
until [ $? -eq 0 ]; do
    calculation
done
echo $files_count

exit 0
