#!/bin/bash
###SCRIPT_NAME:weixin.sh###
###send message from weixin for zabbix monitor###

CropID='wx762921feb1afe85b'
Secret='OsJDEBvskOig81Y_pp7UotDEjJO3ZeN9LUWk23JuR3unJZw3ueJ7XBNNIu4oEpIV'
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret" 
Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F'"' '{print $4}')
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"

#日志
BaseDir="/usr/local/zabbix"
LogDir=$BaseDir/log
ErrorLog=$LogDir/send_weixin.err
SendLog=$LogDir/send_weixin.log
# 发送时间
SendDate=$(date +"%F %T")
UserID="$1"
# 警报状态：警报项目
TRIGGER_CONTENT="$2"
TRIGGER_STATUS=$(echo "$TRIGGER_CONTENT"|awk -F'：' '{print $1}')
TRIGGER_NAME=$(echo "$TRIGGER_CONTENT"|awk -F'：' '{print $2}')
# 警报严重性
TRIGGER_SEVERITY="$3"
# 内容
MessageContent="【通卡联城监控】${TRIGGER_NAME}于时间$SendDate 状态：$TRIGGER_STATUS 严重性：$TRIGGER_SEVERITY 详情：http://zabbix.citytsm.com"

function body() {
        AppID=44                       	#企业号中的应用id
        PartyID=''                        #部门id，定义了范围，组内成员都可接收到消息
        Msg=$1				#内容
        printf '{\n'
        printf '\t"touser": "'"$UserID"\"",\n"
        printf '\t"toparty": "'"$PartyID"\"",\n"
        printf '\t"msgtype": "text",\n'
        printf '\t"agentid": "'" $AppID "\"",\n"
        printf '\t"text":{\n'
        printf '\t\t"content": "'"$Msg"\""\n"
        printf '\t},\n'
        printf '\t"safe":"0"\n'
        printf '}\n'
}

/usr/bin/curl --data-ascii "$(body "$MessageContent")" $PURL 2>> $ErrorLog

printf "$SendDate\t$1\t$2\t$3\t\n" >> $SendLog

exit 0
