#!/bin/bash
# wrinten by Chinge_Yang
# 2017-09-30

function urlencode() {
    # centos7 python2.7
    key=$1
    value=$2
    python -c "import urllib; print(urllib.urlencode({\"$key\":\"$value\"}))"
}

# 发送时间
SendDate=$(date +"%F %T")
# 接收人ID，多人空隔隔开，现只支持这个手机号 18666148908
loginIds="$1"
# 服务号名字
serviceNoName="珠海公安大数据（服务号）" # to urlencode
serviceNoName_data=$(urlencode serviceNoName "$serviceNoName")
userAccount="201707191035"
userKey="55b3d4a4110e47d4a1f65a10004c1930"
# 警报状态：警报项目
TRIGGER_CONTENT="$2"
TRIGGER_STATUS=$(echo "$TRIGGER_CONTENT"|awk -F':' '{print $1}')
TRIGGER_NAME=$(echo "$TRIGGER_CONTENT"|awk -F':' '{print $2}')
# 警报严重性
TRIGGER_SEVERITY="$3"
# 短信内容,UTF-8编码
MessageContent="【珠海芯桥Zabbix】${TRIGGER_NAME}于时间$SendDate 状态：$TRIGGER_STATUS 严重性：$TRIGGER_SEVERITY"
MessageContent_data=$(urlencode content "$MessageContent")
# 短信发送接口，get方式
SendSmsApi="http://10.42.187.161:8089/dap-restful/services/restful/\
JXService/sendTextMessage?loginIds=${loginIds}&${serviceNoName_data}\
&${MessageContent_data}&userAccount=${userAccount}&userKey=${userKey}"

BaseDir="/usr/local/zabbix"
LogDir=$BaseDir/logs
ErrorLog=$LogDir/send_sms.err
SendLog=$LogDir/send_sms.log

curl $SendSmsApi 2>> $ErrorLog

printf "$SendDate\t$1\t$2\t$3\t\n" >> $SendLog

exit 0
