#!/bin/sh
dir=`dirname $0`

echo -n "安装 net-snmp"
yum -y install net-snmp net-snmp-devel net-snmp-utils
 
echo -n "安装 curl"
yum -y install curl curl-devel

echo -n "安装 gcc"
yum -y install gcc libgcc 

echo -n "安装 make"
yum -y  install make

yum install fping perl-IPC-Run perl-Getopt-Long OpenIPMI OpenIPMI-devel ipmitool freeipmi libxml2 libxml2-devel

wget http://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.1/zabbix-3.2.1.tar.gz
tar -xzvf $dir/zabbix-3.2.1.tar.gz
cd $dir/zabbix-3.2.1 ; 
./configure --prefix=/usr/local/zabbix --enable-server --enable-agent \
--with-mysql=/usr/local/mysql/bin/mysql_config \
--with-net-snmp=/usr/bin/net-snmp-config --with-libcurl --with-libxml2 \
--enable-java --with-openipmi
make install
useradd -d /home/zabbix -s /sbin/nologin zabbix

