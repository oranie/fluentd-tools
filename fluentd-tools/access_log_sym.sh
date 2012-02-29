#!/bin/bash


DIR="/var/log/httpd"
TODAY=`date +%Y-%m-%d`
LOG="access_log.$TODAY"

APACHE_LOG="${DIR}/${LOG}"
SYMLINK="${DIR}/access_log_sym"

SYM_MAKE=`/bin/rm -f ${SYMLINK} && /bin/ln -s ${APACHE_LOG} ${SYMLINK} && echo "make symlink !!"`

if [ -e ${APACHE_LOG} ];
then
    echo "${APACHE_LOG} is HERE!!! symlink remake!!"
    echo $SYM_MAKE
else
    echo "${APACHE_LOG} is not here.......wait 5sec. after remake symlink!"
    /bin/sleep 5
    echo $SYM_MAKE
fi


