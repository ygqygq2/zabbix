#!/bin/sh 
#Create by zijin 2014.09.28
##Need "grant select on mysql.* to zabbix@localhost identified by 'zabbix_agent'"
#Mysql5.6
# mysql_config_editor set --login-path=local --host=localhost --user=zabbix -p
MYSQL_SOCK="/tmp/mysql.sock" 
MYSQL_PWD="zabbix_server"
MYSQL_ADMIN="/usr/local/mysql/bin/mysqladmin"
ARGS=1 
if [ $# -ne "$ARGS" ];then 
    echo "Please input one arguement:" 
fi 
case $1 in 
    Uptime) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK status|cut -f2 -d":"|cut -f1 -d"T"` 
        echo $result 
        ;; 
    Com_update) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_update"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Slow_queries) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK status |cut -f5 -d":"|cut -f1 -d"O"` 
        echo $result 
        ;; 
    Com_select) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_select"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_rollback) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_rollback"|cut -d"|" -f3` 
        echo $result 
         ;; 
    Questions) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK status|cut -f4 -d":"|cut -f1 -d"S"` 
        echo $result 
        ;; 
    Com_insert) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_insert"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_delete) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_delete"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_commit) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_commit"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Bytes_sent) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Bytes_sent" |cut -d"|" -f3` 
        echo $result 
        ;; 
    Bytes_received) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Bytes_received" |cut -d"|" -f3` 
        echo $result 
        ;; 
    Com_begin) 
        result=`sudo ${MYSQL_ADMIN} --login-path=local -S $MYSQL_SOCK extended-status |grep -w "Com_begin"|cut -d"|" -f3` 
        echo $result 
        ;;                
        *) 
        echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin)"
        ;; 
esac 
