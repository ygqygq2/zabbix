#!/bin/bash
#Create on 2016-07-06
#@author: Chinge_Yang

function redis () {
    #列出redis所有监听端口
    port=($(sudo netstat -ntlp | awk -F "[ :]+" '/redis/ && /0.0.0.0/ {print $5}'))
    #针对redis集群，去除相差10000的端口
    for p in `seq 0 $((${#port[@]}-1))`;do
        if [ ${port[p]} -gt 10000 ];then
            [[ $(echo ${port[@]} | grep -w "$((${port[p]}-10000))") ]] && unset port[p]
        fi
    done
    printf '{\n'
    printf '\t"data":[\n'
    for key in ${!port[@]};do
    if [[ "${#port[@]}" -gt 1 && "${key}" -ne "$((${#port[@]}-1))" ]];then
        printf "\t\t\t{\"{#REDISPORT}\":\"${port[${key}]}\"},\n"
    else
        printf "\t\t\t{\"{#REDISPORT}\":\"${port[${key}]}\"}\n"
    fi
    done
    printf '\t ]\n'
    printf '}\n'
}

$1

