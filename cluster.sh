#!/bin/bash

cluster="/opt/tomcat/conf/server.xml"
echo "========================================="
echo "请输入IP地址,若输入错误请按CTRL+u重新输入"
echo -n "Please input a IP address:"
read IP 
echo "您输入的IP地址$IP将替换server.xml-->Channel节点-->Receiver中的address值(目录位置/opt/tomcat/conf/server.xml 124行)"
sed -i '/transport.nio.NioReceiver/{n;s/".*"/"'"$IP"'"/}' ${cluster}
exit 0
