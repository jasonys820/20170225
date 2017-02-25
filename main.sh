#!/bin/bash 
 
#########OK and failed ######## 
GREEN_OK="\e[0;32m\033[1mOK\e[m"  
RED_FAILED="\e[0;31m\033[1mFAILED\e[m" 
 
####### functions ########## 
 
global="/root/global_variables.sh"
source ${global}

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

install_yum() 
{ 
/bin/bash ./yum_install.sh
sleep 2
exit
} 

install_apache_tomcat()
{
if [ ! -d /opt/tomcat ]
then
echo "The tomcat has not been installed!"
echo "Now Exiting!!!!!!"
sleep 5
exit
fi
} 

install_httpd() 
{ 
#info "Now begin to install httpd %s.......\n"
#sleep 5
#/bin/bash ./httpd_install.sh
if [ ! -d /opt/apache2 ]
then
echo "The apache has not been installed!"
echo "Now Exiting!!!!!!"
sleep 5
exit
fi
} 

install_apache_tomcat()
{
if [ ! -d /opt/tomcat ]
then
echo "The tomcat has not been installed!"
echo "Now Exiting!!!!!!"
sleep 5
exit
fi
} 


install_yum
install_httpd
install_apache_tomcat
