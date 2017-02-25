#!/bin/bash

###### variables ################### 
SOURCE="net-snmp-devel gcc gcc-c++ autoconf ntp make net-snmp net-snmp-devel lrzsz wget nmap lsof libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel bison libtool vim-enhanced readline readline-devel subversion ghostscript gd libtool-l* cmake gd gd-devel libxslt"

#########OK and failed ######## 
GREEN_OK="\e[0;32m\033[1mOK\e[m"  
RED_FAILED="\e[0;31m\033[1mFAILED\e[m" 
 
#######lots of  functions ########## 

error() 
{ 
local FORMAT="$1" 
shift 
printf "${RED_FAILED} - ${FORMAT}" "$@" >&1 
} 
 
info() 
{ 
local FORMAT="$1" 
shift 
printf "INFO - ${FORMAT}" "$@" >&1 
} 
 
warning() 
{ 
local FORMAT="$1" 
shift 
print "WARNING - ${FORMAT}" "$@" >&1 
} 

install_source_dns()
{
local DNS="/etc/resolv.conf"
local YUM_SOURCE="/etc/yum.repos.d/" 
local repopath="`find /etc/yum.repos.d/ -name base.repo | wc -l`"
local repo="`find /etc/yum.repos.d -name "CentOS-Base-sohu.repo" | wc -l`"
local check_mount="`find /media -name CentOS | wc -l`"
select N in 通过本地安装yum源,并开始部署网站环境 通过互联网安装yum源,并开始部署网站环境  退出
do
echo "========================================"
echo "            "Please wait..."            "
echo "========================================"
echo
sleep 2
case $N in
通过本地安装yum源,并开始部署网站环境)
if [[ ${check_mount} -eq 0 ]]
then
    mount /dev/cdrom /media
    if [[ $? == 0 ]]
        then
	    info "cdrom already mount to /media..${GREEN_OK}.\n"
	else
	    info "Please check the drive path..${RED_FAILED}.\n"
	    exit 1
    fi
    if [[ ${repopath} == 0 ]]
        then
    	    for i in /etc/yum.repos.d/*.repo
                do
	    	    mv $i ${i%.repo}.bak >>/dev/null 2>&1
    	    done
cd ${YUM_SOURCE}
`cat >base.repo <<EOF
[base]
name=base
baseurl=file:///media
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
EOF`
	    echo "----------------------------------------------------------------------"
	    echo
	    info "Now configure the Yum souce,this will take serveral minutes...\n"
	    echo "----------------------------------------------------------------------"
	    sleep 5
	    yum install -y ${SOURCE}
	    info "Source configuration completed ${GREEN_OK}.\n"
	    cd -
    elif [[ ${repopath} -eq 1 ]]
        then
	    echo "-----------------------------------------------------------"
	    echo
	    info "yum source has been configureation completed ${GREEN_OK}. \n"
	    echo "-----------------------------------------------------------"
	    cd -
    fi
else
    info "cdrom already mount to /media..${GREEN_OK}.\n"
    echo "----------------------------------------------------------------------"
    echo
    info "Now configure the Yum souce,this will take serveral minutes...\n"
    echo "----------------------------------------------------------------------"
    sleep 5
    yum install -y ${SOURCE}
    info "Source configuration completed ${GREEN_OK}.\n"
    cd -
fi
    /bin/bash /root/httpd_install.sh
    /bin/bash /root/tomcat_install.sh
    break;;
通过互联网安装yum源,并开始部署网站环境)
sleep 1
    if ! grep -q nameserver ${DNS}
        then
	    echo "nameserver 8.8.8.8" >>${DNS}
	    info "DNS modification completion ${GREEN_OK}.\n"
    else
	info "DNS modification completion ${GREEN_OK}.\n"
	sleep 2
    fi
    if [[ ${repo} == 0 ]]
        then
            for i in /etc/yum.repos.d/*.repo
	        do
                    mv $i ${i%.repo}.bak >>/dev/null 2>&1
            done
	    cd ${YUM_SOURCE}
    	    wget http://mirrors.sohu.com/help/CentOS-Base-sohu.repo >>/dev/null 2>&1
    	    if [[ $? == 0 ]]
                then
                    info "sohu Yum source download completed ${GREEN_OK}.\n"
            	    sleep 2
	    	    yum makecache
            	    if [[ $? == 0 ]]
	                then
	            	    echo "----------------------------------------------------------------------"
                    	    echo
                    	    info "Now configure the Yum souce,this will take serveral minutes...\n"
                    	    echo "----------------------------------------------------------------------"
                    	    sleep 3
                    	    yum install -y ${SOURCE}
		    	    info "Source configuration completed ${GREEN_OK}.\n"
		    	    sleep 2
			    cd
	    	    fi
    	    else
        	info "163 Yum souce download ${RED_FAILED}..\n"
        	sleep 2
        	exit 1
            fi
    else
        info "Yum configuration completed ${GREEN_OK}.\n"
	yum makecache
        sleep 2
        if [[ $? == 0 ]]
	    then
        	echo "----------------------------------------------------------------------"
                echo
                info "Now configure the Yum souce,this will take serveral minutes...\n"
                echo "----------------------------------------------------------------------"
                sleep 3
		yum install -y ${SOURCE}
                info "Source configuration completed ${GREEN_OK}.\n"
        fi
    fi
    /bin/bash /root/httpd_install.sh
    /bin/bash /root/tomcat_install.sh
    break;;
*)
        echo "Will now exit.."
	break;;
esac
done
}

################## main ########################## 

#install source_dns
#info "Begin to install source and DNS.\n"
install_source_dns
