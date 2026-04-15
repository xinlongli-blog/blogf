#!/bin/bash

# set home
WORKHOME="/data/keepalived/"
LOGFILE=${WORKHOME}"log/switch.log"

echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S") $1" >> ${LOGFILE}
