#!/bin/bash
# wrinten by Chinge_Yang
# 2015-08-26

# 手机号码：变量间用英文","隔开,通常以20个号码做为上限，不重复，不强制限制
#UserNumber="13702775677"
UserNumber="$1"
# 发送时间
SendDate=$(date +"%F %T")
# 短信发送接口
SendSmsApi="http://sms.citytsm.com/msgHttp/json/mt"
# 登录用户
Account="12219102373861"
# 登录密码
Password="B]54F338&4RQ%"
#时间戳，短信发送当前时间毫秒数，生成数字签名用，有效时间1分钟，强烈建议实时生成
Time_tmp=$(date +%s%N)
Timestamps=${Time_tmp:0:13}
#数字签名：(接口密码、手机号、时间戳32位MD5加密生成)
password=$(echo -n "${Password}${UserNumber}${Timestamps}"|md5sum|awk '{print $1}')
# 警报状态：警报项目
TRIGGER_CONTENT="$2"
TRIGGER_STATUS=$(echo "$TRIGGER_CONTENT"|awk -F'：' '{print $1}')
TRIGGER_NAME=$(echo "$TRIGGER_CONTENT"|awk -F'：' '{print $2}')
# 警报严重性
TRIGGER_SEVERITY="$3"
# 短信内容,UTF-8编码
MessageContent="【通卡联城监控】${TRIGGER_NAME}于时间$SendDate 状态：$TRIGGER_STATUS 严重性：$TRIGGER_SEVERITY 详情：http://zabbix.citytsm.com"
# post数据
PostData="account=$Account&password=$password&mobile=$UserNumber&content=$MessageContent&timestamps=$Timestamps"

BaseDir="/usr/local/zabbix"
LogDir=$BaseDir/log
ErrorLog=$LogDir/send_sms.err
SendLog=$LogDir/send_sms.log

curl -d "$PostData" $SendSmsApi 2>> $ErrorLog

printf "$SendDate\t$1\t$2\t$3\t\n" >> $SendLog

exit 0
