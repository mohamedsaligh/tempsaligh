#!/bin/sh

# This script invokes the Connect:Direct

CD_HOME=/opt/cdunix

PATH=$PATH:${CD_HOME}/ndm/bin:${CD_HOME}/ndm/cfg/cliapi/
export PATH

NDMAPICFG=${CD_HOME}/ndm/cfg/cliapi/ndmapi.cfg
export NDMAPICFG

LOG_FILE=/logs/cd_send_binary`date +"%Y%m%d"`.log

SOURCE_FILE=""
DEST_FILE=""
NODE=""

PARAM_CNT=$#
if [ $PARAM_CNT -lt 3 ]; then
  echo "`date +%Y%m%d_%H:%M:%S` - Syntax: cd_send_binary.sh [Node] [source file] [dest file]"  >> ${LOG_FILE}
  echo "`date +%Y%m%d_%H:%M:%S` - Example: cd_send_binary.sh node /sourcedir/abspath/20110105151842.pdf /sourcedir/abspath/20110105151842.pdf"  >> ${LOG_FILE}
  echo "`date +%Y%m%d_%H:%M:%S` - CRITICAL cd_send_binary.sh was not started properly "  >> ${LOG_FILE}
  exit 1
else
  NODE=$1
  SOURCE_FILE=$2
  DEST_FILE=$3
fi

sendfile() {
        ret=`${CD_HOME}/ndm/bin/direct << EOC
        submit maxdelay=unlimited
                 MERTDSPROC    process    snode=${NODE}
                 step1    copy from  (file=${SOURCE_FILE}
                                      pnode
                                      SYSOPTS=":datatype=binary:xlate=no:strip.blanks=no:")
                                 to  (file=${DEST_FILE}
                                       snode
                                       DISP=RPL
                                       SYSOPTS="DATATYPE(BINARY) STRIP.BLANKS(NO) XLATE(NO)")
                pend ;
        quit;

        EOC`
        if [ $? -ne 0 ]; then
        #  echo "Sent file: ${SOURCE_FILE} to ondemand failed"
          return 1
        else
          #echo "Sent file:  ${SOURCE_FILE}  to ondemand successed"
          return 0
        fi
}

retValue=0
echo "`date +%Y%m%d_%H:%M:%S` -INFO:transfer [${SOURCE_FILE}] begin .........." >> ${LOG_FILE}
sendfile
retValue=$?
if [ ${retValue} -ne 0 ]; then
        echo "`date +%Y%m%d_%H:%M:%S` -ERROR: transfer [${SOURCE_FILE}] to [${DEST_FILE}] by node [${NODE}] unsuccessfully." >> ${LOG_FILE}
else
        echo "`date +%Y%m%d_%H:%M:%S` -INFO: transfer [${SOURCE_FILE}] to [${DEST_FILE}] by node [${NODE}] successfully." >> ${LOG_FILE}
fi
echo "`date +%Y%m%d_%H:%M:%S` -INFO:transfer [${SOURCE_FILE}] end .........." >> ${LOG_FILE}

exit ${retValue}
