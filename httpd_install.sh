#!/bin/bash 
 
 
###### variables ################### 
GLOABLE_VARIABLE_FILE="/root/global_variables.sh" 
SOURCE_FILENAME="httpd-2.2.13.tar.gz" 
UNPACK_DIR_NAME="httpd-2.2.13"
 
 
 
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
        info "apache file %s is ${GREEN_OK}.\n" "${SOURCE_FILENAME}" 
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

install_apr() 
{
local apr_FILENAME="apr-1.4.2.tar.gz"
local apr_DIR="apr-1.4.2"
if [ ! -d /opt/apr ]
    then
	info "Unpack the apr file %s\n" "${apr_FILENAME}"
	tar -zxf ${SOURCE_DIR}/${apr_FILENAME}  -C  ${UNPACK_DIR}
	if [[ $? == 0 ]]
    	    then
        	info "unpack %s done.${GREEN_OK}\n" "${apr_FILENAME}"
    	else
            error "unpack %s failed.\n"  "${apr_FILENAME}"
            exit $?
    	fi
        cd ${UNPACK_DIR}/${apr_DIR}
	echo "============================================================="
	echo 
    	info "Now configure the apr,this will take serveral minutes...\n"
	echo "============================================================="
	sleep 2
    	./configure --prefix=${INSTALL_ROOT}/apr
    	if [[ $? == 0 ]]
    	    then
		echo "============================================================================================="
		echo
        	info "apr configure ${GREEN_OK}. Now make and make install. this will take serveral minutes... \n"
		echo "============================================================================================="
		sleep 2
        	make && make install
        	if [[  $? == 0 ]]
        	    then
            		info "apr installed ${GREEN_OK}.\n"
			sleep 2
        	else
		    echo "====================="
	 	    echo
                    error "apr not installed.\n "
		    echo "====================="
		    sleep 2
            	    exit 0
        	fi
    	else
	    echo "========================================="
	    echo
            error "Configurr is not complete.\n"
	    echo "========================================="
	    sleep 2
            exit 0
	fi
    else
	info "apr has been installed..${GREEN_OK}.\n"
	sleep 2
fi
}
 
install_apr_util() 
{
local apr_util_FILENAME="apr-util-1.3.10.tar.gz"
local apr_util_DIR="apr-util-1.3.10"
if [ ! -d /opt/apr-util ]
    then
	info "Unpack the apr-util file %s\n" "${apr_util_FILENAME}"
	tar -zxf ${SOURCE_DIR}/${apr_util_FILENAME}  -C  ${UNPACK_DIR}
	if [[ $? == 0 ]]
    	    then
        	info "unpack %s done.${GREEN_OK}\n" "${apr_util_FILENAME}"
    	else
        	error "unpack %s failed.\n"  "${apr_util_FILENAME}"
        	exit $?
    	fi
    	cd ${UNPACK_DIR}/${apr_util_DIR}
	echo "================================================================"
	echo 
    	info "Now configure the apr-util,this will take serveral minutes...\n"
	echo "================================================================"
	sleep 2
    	./configure  --prefix=${INSTALL_ROOT}/apr-util --with-apr=/opt/apr
    	if [[ $? == 0 ]]
    	    then
		echo "=================================================================================================="
		echo 
        	info "apr-util configure ${GREEN_OK}. Now  make and make install. this will take serveral minutes... \n"
		echo "=================================================================================================="
		sleep 2
        	make && make install
        	if [[  $? == 0 ]]
        	    then
            		info "apr-util installed ${GREEN_OK}.\n"
			sleep 2
        	else
            	    error "apr-util not installed.\n "
            	    exit $?
        	fi
    	else
	    echo "==============================="
	    echo
            error "Configure is not complete.\n"
	    echo "==============================="
            exit $?
	fi
    else
	info "apr-util has been installed..${GREEN_OK}.\n"
	sleep 2
fi
}
 
install_httpd()
{
local httpd_conf="/opt/apache2/conf/httpd.conf"
local CONFIG_VARIABLE="--prefix=${INSTALL_ROOT}/apache2 --enable-so  --enable-dav --enable-cgi --enable-deflate --enable-headers --enable-expires --enable-proxy --enable-vhost-alias --enable-cache --enable-disk-cache --enable-mem-cache --enable-rewrite --enable-usertrack --enable-ssl --with-apr=/opt/apr --with-apr-util=/opt/apr-util"
if [ ! -d /opt/apache2 ]
then
    cd ${UNPACK_DIR}/${UNPACK_DIR_NAME}
    info "Add the apache user ...\n"  
    useradd -s /sbin/nologin ${USER} 
    info "Add user apache done.\n" 
    info "Now configure the apache,this will take serveral minutes...\n" 
    sleep 2
    ./configure ${CONFIG_VARIABLE} 
    if [[ $? == 0 ]]  
    then 
	echo "=============================================================================================="
	echo
        info "apache configure ${GREEN_OK}. Now make and make install.this will take serveral minutes... \n"
	echo "=============================================================================================="
        make && make install 
        if [[ $? == 0 ]]  
        then 
            info "apache installed ${GREEN_OK}.\n" 
	    sed -i 's/User daemon/User webadm/' ${httpd_conf}
	    sed -i 's/Group daemon/Group webadm/' ${httpd_conf}
	    sed -i '388 s/^#*//' ${httpd_conf}
	    sed -i '/application\/x-gzip/a\AddType text\/html \.shtml' ${httpd_conf}
	    sed -i '/application\/x-gzip/a\AddOutputFilter INCLUDES \.shtml' ${httpd_conf}
	    sleep 2
	    if ! grep -q apachectl /etc/rc.local
	    	then
                    echo '/opt/apache2/bin/apachectl -k start' >> /etc/rc.local
	    fi
        else 
	    echo "==========================="
	    echo
            error "apache not installed.\n " 
	    echo "==========================="
	    sleep 2
            exit $?  
        fi  
    else 
	echo "=============================="
	echo
        error "Configure is not complete.\n"   
	echo "=============================="
	sleep 2
        exit $?  
    fi  
else
info "apache has been installed..${GREEN_OK}.\n"
sleep 2
exit
fi
}

#### main ####
####Check the apr if has been installed####
check_install()
{
if [ -d /opt/apr ]
then
echo "The apr has been installed!"
echo "Now Exiting!!!!!!"
sleep 3
exit
fi

####Check the apr-util if has been installed####
if [ -d /opt/apr-util ]
then
echo "The apr-util has been installed!"
echo "Now Exiting!!!!!!"
sleep 3
exit
fi

####Check the apache if has been installed####
if [ -d /opt/apache2 ]
then
echo "The apche has been installed!"
echo "Now Exiting!!!!!!"
sleep 3
exit
fi
}

#### Check the file ####
check_source 
unpack_file 
 
#### install apr ####
install_apr
 
#### install apr-util ####
install_apr_util
 
#### install httpd ####
install_httpd
