#!/usr/bin/env bash
#Create by zijin 2014.09.28
##Need "grant REPLICATION CLIENT on *.* to zabbix_select@localhost identified by 'zabbix'"
#Mysql5.6
# mysql_config_editor set --login-path=local --host=localhost --user=zabbix_select -p
MYSQL_SOCK="/tmp/mysql.sock" 
MYSQL_PWD="zabbix"
MYSQL="/usr/local/mysql/bin/mysql"
MYSQL_ADMIN="${MYSQL}admin"
ARGS=1 
if [ $# -ne "$ARGS" ];then 
    echo "Please input one arguement:" 
fi 
case $1 in 
        Slave_Running) 
                slave_is=($(sudo ${MYSQL} --login-path=local -S $MYSQL_SOCK -e "show slave status\G"|egrep "\bSlave_.*_Running\b"|awk '{print $2}'))
                if [ "${slave_is[0]}" = "Yes" -a "${slave_is[1]}" = "Yes" ];then
                     result="1"
                else
                     result="0"
                fi
                echo $result
        ;;
	Seconds_Behind)
                result=$(sudo ${MYSQL} --login-path=local -S $MYSQL_SOCK -e "show slave status\G"|egrep "\bSeconds_Behind_Master\b"|awk '{print $2}')
                echo $result
        ;;
        *) 
                echo "Usage:$0(Slave_Running|Seconds_Behind)" 
        ;; 
esac 


