#!/bin/bash 
 
 
###### variables ################### 
GLOABLE_VARIABLE_FILE="/root/global_variables.sh" 
SOURCE_FILENAME="apache-tomcat-6.0.36.tar.gz" 
UNPACK_DIR_NAME="apache-tomcat-6.0.36" 
 
 
#########OK and failed ######## 
GREEN_OK="\e[0;32m\033[1mOK\e[m"  
RED_FAILED="\e[0;31m\033[1mFAILED\e[m" 
 
 
#### source the global variable ##### 
source ${GLOABLE_VARIABLE_FILE} 
 
 
#######lots of  functions ########## 
 
 
error() 
{ 
local FORMAT="$1" 
shift 
printf "${RED_FAILED} - ${FORMAT}\n" "$@" >&1 
} 
 
info() 
{ 
local FORMAT="$1" 
shift 
printf "INFO - ${FORMAT}\n" "$@" >&1 
} 
 
warning() 
{ 
local FORMAT="$1" 
shift 
print "WARNING - ${FORMAT}\n" "$@" >&1 
} 
 
 
check_source() 
{ 
info "Checking source file %s.\n" "${SOURCE_FILENAME}" 
if [ -f ${SOURCE_DIR}/${SOURCE_FILENAME} ] 
    then 
        info "tomcat file %s is ${GREEN_OK}.\n" "${SOURCE_FILENAME}" 
    else 
        error "%s file not found.\n" "${SOURCE_FILENAME}" 
        exit $? 
fi 
} 
 
unpack_file() 
{ 
info "Unpack the source file %s .\n" "${SOURCE_FILENAME}" 
tar -zxf ${SOURCE_DIR}/${SOURCE_FILENAME}  -C  ${UNPACK_DIR} 
if [[ $? != 0 ]] 
    then 
        error "Can not unpack file %s.\n"  "${SOURCE_FILENAME}" 
        exit $? 
    else  
        info "Unpack %s done.${GREEN_OK}\n" "${SOURCE_FILENAME}" 
fi 
} 

install_apache_tomcat()
{
local apache_tomcat_FILENAME="apache-tomcat-6.0.36.tar.gz"
local apache_tomcat_DIR="apache-tomcat-6.0.36"
local tomcat_patch="/opt/tomcat"
local tomcat_profile="/root/profile.conf" 
local apache_tomcat_catalina="/opt/tomcat/bin/catalina.sh"
local java_profile="/etc/profile"
local jdk_bin="jdk-6u38-ea-bin-b04-linux-i586-31_oct_2012-rpm.bin"
local tomcat_xml="/opt/tomcat/conf/server.xml"
info "Unpack the apache-tomcat file %s\n" "${apache_tomcat_FILENAME}"
tar -zxf ${SOURCE_DIR}/${apache_tomcat_FILENAME} -C ${UNPACK_DIR}
if [[ $? == 0 ]]
    then
	info "unpack %s done.${GREEN_OK}\n" "${apache_tomcat_FILENAME}"
    else
	error "unpack %s failed.\n" "${apache_tomcat_FILENAME}"
	exit $?
fi
if [ ! -d /opt/tomcat ]
    then
	mv ${UNPACK_DIR}/${UNPACK_DIR_NAME} ${tomcat_patch}
	if ! grep -q MaxPermSize ${apache_tomcat_catalina}
	    then
		sed -i '1aCATALINA_OPTS="$CATALINA_OPTS -XX:PermSize=128M -XX:MaxPermSize=512M -Xms2048m -Xmx2048m $JPDA_OPTS"' /${apache_tomcat_catalina}
		#sed -i 'N;/\n.*SimpleTcpCluster/!P;D' ${tomcat_xml}
		#sed -i 'SimpleTcpCluster/{n;/-->/d}' ${tomcat_xml}
		#sed -i '/SimpleTcpCluster/d' ${tomcat_xml}
		sed -i '110r /root/cluster.xml' ${tomcat_xml}
		echo "========================================="
		echo "请输入IP地址,若输入错误请按CTRL+u重新输入"
		echo -n "Input a IP address:"
		read IP
		echo "您输入的IP地址$IP已替换server.xml-->Channel节点-->Receiver中的address值(目录位置/opt/tomcat/conf/server.xml 124行)"
		sleep 3
	        echo "若需修改cluster IP,请执行命令sh cluster.sh后,按提示输入IP"
		sed -i '/transport.nio.NioReceiver/{n;s/".*"/"'"$IP"'"/}' ${tomcat_xml}
		sleep 5
		echo "=============================="
		echo
		info "tomcat install ${GREEN_OK}.\n"
		echo "=============================="
		sleep 2
	fi
    else
	echo "=========================================================="
	echo
	info "tomcat has been installed.${GREEN_OK}.\n "
	echo "若需修改cluster IP,请执行命令sh cluster.sh后,按提示输入IP"
	echo "=========================================================="
	sleep 2
fi 
sleep 2
if ! grep -q JAVA_HOME /etc/profile
    then
	echo "" | ${SOURCE_DIR}/${jdk_bin}
	sleep 2
	cat ${tomcat_profile} >>${java_profile}
	source ${java_profile} >>/dev/null 2>&1
        info "java_profile configure ${GREEN_OK}...\n"
	/bin/bash finish.sh
	sleep 2
   else
	info "Java_profile has been configured.${GREEN_OK}.\n"
	/bin/bash finish.sh
	sleep 2
fi
}

####Check the tomcat if has been installed####
#if [ -d /opt/tomcat ]
#then
#echo "The tomcat has been installed!"
#echo "Now Exiting!!!!!!"
#sleep 5
#exit
#fi
 
####apache_tomcat####
install_apache_tomcat
