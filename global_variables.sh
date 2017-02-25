#! /bin/bash 

#### global directory variables#########
if [ ! -d unpack_sources ] 
then 
mkdir -p unpack_sources
fi 
PWD=`pwd`
SOURCE_DIR="$PWD/sources"
UNPACK_DIR="$PWD/unpack_sources"
INSTALL_ROOT="/opt"
CONF_SAMPLE="$PWD/conf_samples"
