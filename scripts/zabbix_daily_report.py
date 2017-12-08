#!/usr/bin/env python
# _*_coding:utf-8_*_
'''
 * Created on 2016/11/17 14:20.
 * @author: Chinge_Yang.
'''

import time, os
import urllib
import urllib.request
import http.cookiejar
import pymysql
import smtplib
from email.mime.text import MIMEText

# screen 聚合图形名
screens = ["MongoDB server"]
# 图片保存目录
save_graph_path = "/home/wwwroot/html/zabbix/reports/%s" % time.strftime("%Y%m%d")

# 创建每日报告目录
if not os.path.exists(save_graph_path):
    os.makedirs(save_graph_path)

# zabbix host
zabbix_host = "172.30.47.200/zabbix"
# zabbix login username
username = "admin"
# zabbix login password
password = "zabbix@Sunq"

# graph width
width = 600
# graph height
height = 100

# graph Time period, s
period = 86400  # one day

# zabbix DB
dbhost = "127.0.0.1"
dbport = 3306
dbuser = "zabbix"
dbpasswd = "Zabbix@Sunq8"
dbname = "zabbix"


def mysql_query(sql):
    try:
        conn = pymysql.connect(host=dbhost, user=dbuser, passwd=dbpasswd, port=dbport, connect_timeout=20)
        conn.select_db(dbname)
        cur = conn.cursor()
        count = cur.execute(sql)
        if count == 0:
            result = 0
        else:
            result = cur.fetchall()
        return result
        cur.close()
        conn.close()
    except pymysql.Error as e:
        print("mysql error:", e)


def get_graph(zabbix_host, username, password, screen, width, height, period, save_graph_path):
    screenid_list = []
    global html
    html = ''
    for i in mysql_query("select screenid from screens where name='%s'" % (screen)):
        for screenid in i:
            graphid_list = []
            for c in mysql_query("select resourceid from screens_items where screenid='%s'" % (int(screenid))):
                for d in c:
                    graphid_list.append(int(d))
            for graphid in graphid_list:
                login_opt = urllib.parse.urlencode({
                    "name": username,
                    "password": password,
                    "autologin": 1,
                    "enter": "Sign in"}).encode('utf-8')


                get_graph_opt = urllib.parse.urlencode({
                    "graphid": graphid,
                    "screenid": screenid,
                    "width": width,
                    "height": height,
                    "period": period}).encode('utf-8')

                cj = http.cookiejar.LWPCookieJar()
                cookie_support = urllib.request.HTTPCookieProcessor(cj)  
                opener = urllib.request.build_opener(cookie_support, urllib.request.HTTPHandler)  
                urllib.request.install_opener(opener)  
                login_url = r"http://%s/index.php" % zabbix_host
                save_graph_url = r"http://%s/chart2.php" % zabbix_host
                opener.open(login_url, login_opt).read()
                data = opener.open(save_graph_url, get_graph_opt).read()
                filename = "%s/%s.%s.png" % (save_graph_path, screenid, graphid)
                html += '<img width="600" height="250" src="http://%s/%s/%s/%s.%s.png">' % (
                zabbix_host, save_graph_path.split("/")[len(save_graph_path.split("/")) - 2],
                save_graph_path.split("/")[len(save_graph_path.split("/")) - 1], screenid, graphid)

                f = open(filename, "wb")
                f.write(data)
                f.close()



if __name__ == '__main__':
    for screen in screens:
        get_graph(zabbix_host, username, password, screen, width, height, period, save_graph_path)
