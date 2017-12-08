#!/usr/bin/env bash
##############################################################
# File Name: zabbix_daily_report.sh
# Version: V1.0
# Author: Chinge_Yang
# Blog: http://blog.csdn.net/ygqygq2
# Created Time : 2017-10-10 17:38:00
# Description:
##############################################################

#获取脚本所存放目录
cd `dirname $0`
SH_DIR=`pwd`
ME=$0

python3=/usr/local/python3/bin/python3 
zabbix_web_dir="/home/wwwroot/html/zabbix"
reports_dir="$zabbix_web_dir/reports"
image_dir="$reports_dir/$(date +"%Y%m%d")"
# 旧数据保存天数
keep_days=7

# 每日生成图片
$python3 $SH_DIR/zabbix_daily_report.py

# 生成php展示页面
cat > $image_dir/index.php << EOF 
<?php

// 文件夹路径
\$folder = dirname(__FILE__);
\$files = array();
 
// 遍历文件夹
\$handle = opendir(\$folder);
while(false!==(\$file=readdir(\$handle))){
    if(\$file!='.' && \$file!='..'){
        \$files[] = \$file;
    }
}
 
// 循环显示
if(\$files){
    foreach(\$files as \$k=>\$v){
        echo '<img src="'.\$v.'">';
    }
}
EOF

# 删除旧数据
cd ${reports_dir}
[ $? -eq 0 ] && find ${reports_dir} -mtime +$keep_days -exec rm -rf {} \;
