#!/bin/bash
# wrinten by Chinge_Yang
# 2015-08-26

# 手机号码：变量间用英文","隔开
#UserNumber="13702775677"
UserNumber="$1"
# 发送时间
SendDate=$(date +"%F %T")
# 短信发送接口
SendSmsApi="http://test.citytsm.com/send_sms/send_sms_api.php"
# 企业号
SpCode="222929"
# 登录用户
LoginName="517161239"
# 登录密码
Password="a22a0a_TSM"
# 20位长度序列号
SerialNumber=$(date +%Y%m%d%H%M%S%N|awk '{print substr($0,1,20)}')
ScheduleTime=""
ExtendAccessNum=""
f="1"
# 警报状态：警报项目
TRIGGER_CONTENT="$2"
TRIGGER_STATUS=$(echo "$TRIGGER_CONTENT"|awk -F'：' '{print $1}')
TRIGGER_NAME=$(echo "$TRIGGER_CONTENT"|awk -F'：' '{print $2}')
# 警报严重性
TRIGGER_SEVERITY="$3"
# 短信内容
MessageContent="zabbix监控报警于时间$SendDate 状态：$TRIGGER_STATUS 严重性：$TRIGGER_SEVERITY 详情：http://zabbix.citytsm.com "
# post数据
PostData="SpCode=$SpCode&LoginName=$LoginName&Password=$Password&MessageContent=$MessageContent&UserNumber=$UserNumber&SerialNumber=$SerialNumber&ScheduleTime=&ExtendAccessNum=&f=$f"

BaseDir="/usr/local/zabbix"
LogDir=$BaseDir/log
ErrorLog=$LogDir/send_sms.err
SendLog=$LogDir/send_sms.log

echo "$TRIGGER_CONTENT" > /tmp/zabbix_debug.log
curl -d "$PostData" $SendSmsApi 2>> $ErrorLog

printf "$SendDate\t$1\t$2\t$3\t\n" >> $SendLog

exit 0
