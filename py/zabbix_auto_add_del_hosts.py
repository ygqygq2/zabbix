#!/usr/bin/env python  
# -*- coding: utf-8 -*-  
#zabbix的自动发现功能有时由于网络等原因自动添加主机比较慢  
#或者不能添加地址段内所有的主机，基于此，写此脚本根据单IP  
#和单IP应用来添加删除主机。  
#在zabbix2.0.3/4上测试通过  
 
import re,urllib,urllib2,cookielib  
import MySQLdb  
 
zabbix_server = '192.168.1.2' 
 
class web_form:  
    post_data=""#登陆提交的参数  
    def __init__(self):  
        '''''初始化类，并建立cookies值''' 
        cj = cookielib.CookieJar()  
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))  
        opener.addheaders = [('User-agent', 'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:19.0) Gecko/20100101 Firefox/19.0')]  
        urllib2.install_opener(opener)  
 
    def login(self,loginurl):  
        '''''模拟登陆,获取认证的后的session''' 
        req = urllib2.Request(loginurl,self.post_data)  
        _response = urllib2.urlopen(req)  
        for i in str(_response.info()).split('\n'):  
            if 'Set-Cookie' in i:  
                sid = i.split("=")[1].split(";")[0][16:]  
                break 
        _d=_response.read()  
        return _d,sid  
 
    def getpagehtml(self,pageurl):  
        '''''获取目标网站任意一个页面的html代码''' 
        req2=urllib2.Request(pageurl,self.post_data)  
        _response2=urllib2.urlopen(req2)  
        status = _response2.code  
        _d2=_response2.read()  
        return _d2  
 
def center(sql):  
    try:  
        center_ip = zabbix_server  
        center_user = 'root' 
        center_passwd = '123456789' 
        conn = MySQLdb.connect(host = center_ip,user = center_user,passwd = center_passwd,connect_timeout=10)  
        cursor = conn.cursor()   
        cursor.execute(sql)  
        alldata = cursor.fetchall()  
        cursor.close()  
        conn.close()  
        return alldata  
    except Exception,e:  
        return '0' 
 
def operation(action,hostip,post_dirc):  
    boss = web_form()  
    #参递一个post参数  
    url = "http://%s/zabbix" % zabbix_server  
    boss.post_data = urllib.urlencode({"autologin":"1","enter":"Sign in","name":"admin","password":"zabbix"})  
    login,sid = boss.login("%s/index.php" % url)#首先登陆zabbix，获取认证的sid  
    if action == 'add':#添加主机  
        sql = "SELECT hostid FROM zabbix.hosts WHERE host='%s'" % hostip  
        hostid = center(sql)  
        if len(hostid) != 0:  
            print "Server %s is already in zabbix status !" % hostip  
        else:  
            post_form = {'form':'创建主机','form_refresh':'2','host':hostip,'interfaces[1][dns]':'','interfaces[1][interfaceid]':'1','interfaces[1][ip]':hostip,'interfaces[1][isNew]':'true','interfaces[1][port]':'10050','interfaces[1][type]':'1','interfaces[1][useip]':'1','inventory_mode':'-1','ipmi_authtype':'-1','ipmi_password':'','ipmi_privilege':'2','ipmi_username':'','macros[0][macro]':'','macros[0][value]':'','mainInterfaces[1]':'1','newgroup':'','proxy_hostid':'0','save':'存档','sid':sid,'status':'0','visiblename':hostip}  
            post_form = dict(post_form,**post_dirc)  
            boss.post_data=urllib.urlencode(post_form)  
            add_host = boss.getpagehtml("%s/hosts.php" % url)  
            sql = "SELECT hostid FROM zabbix.hosts WHERE host='%s'" % hostip  
            hostid = center(sql)  
            if len(hostid) != 0:  
                print "Add %s in zabbix success !" % hostip  
            else:  
                print "Add %s in zabbix failure !" % hostip  
    elif action == 'del':#删除主机  
        sql = "SELECT hostid FROM zabbix.hosts WHERE host='%s'" % hostip  
        hostid = center(sql)#从zabbix服务器端数据库取出要删除ip的hostid号  
        if len(hostid) != 0:  
            hostid = hostid[0][0]  
            a = 'hosts[%s]' % hostid  
            boss.post_data=urllib.urlencode({'form_refresh':'1','go':'delete','goButton':'确认 (1)',a:hostid,'sid':sid})  
            del_host = boss.getpagehtml("%s/hosts.php" % url)  
            hostid = center(sql)  
            sql = "SELECT hostid FROM zabbix.hosts WHERE host='%s'" % hostip  
            if len(hostid) != 0:  
                print "Delete %s from zabbix failure !" % hostip  
            else:  
                print "Delete %s from zabbix success !" % hostip  
        else:  
            print "Server %s not in zabbix status !" % hostip  
 
def main(block,action,hostip):#根据IP的应用，确定需要添加到zabbix中的组和需要应用的模板  
    if block == "adb" or block == "ldb" or block == "ccs":  
        sql = "SELECT groupid,name FROM zabbix.groups WHERE name IN ('WD_ADB_LDB','Linux servers')" 
        groupdata = center(sql)  
        sql = "SELECT hostid,HOST FROM zabbix.hosts WHERE HOST IN ('linux_Server','MySQL_status','Linux_disk_io')" 
        templates = center(sql)  
    elif "_s" in block:  
        sql = "SELECT groupid,name FROM zabbix.groups WHERE name IN ('Linux servers','WD_SLAVE')" 
        groupdata = center(sql)  
        sql = "SELECT hostid,HOST FROM zabbix.hosts WHERE HOST IN ('linux_Server','MySQL_status','Slave_Status','Linux_disk_io')" 
        templates = center(sql)  
    else:  
        sql = "SELECT groupid,name FROM zabbix.groups WHERE name IN ('Linux servers','WD_GS')" 
        groupdata = center(sql)  
        sql = "SELECT hostid,HOST FROM zabbix.hosts WHERE HOST IN ('linux_Server','Linux_disk_io')" 
        templates = center(sql)  
    templatesdirc = {}  
    groupdirc = {}  
    for i in groupdata:  
        groups = 'groups[%s]' % str(i[0])  
        groupdirc[groups] = str(i[0])  
    for i in templates:  
        groups = 'templates[%s]' % str(i[0])  
        templatesdirc[groups] = str(i[1])  
    post_dirc = dict(groupdirc,**templatesdirc)  
    operation(action,hostip,post_dirc)  
 
if __name__=="__main__":  
    block = 'adb_s' 
    hostip = '6.6.6.6' 
    action = 'add' 
    action = 'del' 
    main(block,action,hostip) 