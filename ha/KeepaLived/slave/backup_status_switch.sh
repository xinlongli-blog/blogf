#!/bin/bash

# set home
WORKHOME="/data/keepalived/"
LOGFILE=${WORKHOME}"log/switch.log"

# set const
USERNAME="replic_oper"
PASSWORD="replic_oper@123"

# write log
echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  switch: $1" >> ${LOGFILE}

if [ $1 == 'master' ];then
    for loop in 1 2
    do
        status=$(/opt/mysql-3306/bin/mysql -hlocalhost -u${USERNAME} -p${PASSWORD} -e "show slave status\G" | egrep 'Master_Log_File|Read_Master_Log_Pos|Relay_Master_Log_File|Exec_Master_Log_Pos' | awk '{print $2}')
        i=0
        for a in ${status}
        do
            if [ $i -eq 0 ];then
                Master_Log_File=$a
            elif [ $i -eq 1 ];then
                Read_Master_Log_Pos=$a
            elif [ $i -eq 2 ];then
                Relay_Master_Log_File=$a
            elif [ $i -eq 3 ];then
                Exec_Master_Log_Pos=$a
            fi
            let i+=1
        done
        if [ $loop == "2" ];then
            /opt/mysql-3306/bin/mysqladmin -hlocalhost -u${USERNAME} -p${PASSWORD} stop-slave >/dev/null 2>&1
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Master_Log_File: ${Master_Log_File}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Relay_Master_Log_File: ${Relay_Master_Log_File}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Read_Master_Log_Pos: ${Read_Master_Log_Pos}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Exec_Master_Log_Pos: ${Exec_Master_Log_Pos}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  stop slave" >> ${LOGFILE}
            break
        fi
        if [ ${Master_Log_File} == ${Relay_Master_Log_File} ] && [ ${Read_Master_Log_Pos} -eq ${Exec_Master_Log_Pos} ];then
            /opt/mysql-3306/bin/mysqladmin -hlocalhost -u${USERNAME} -p${PASSWORD} stop-slave >/dev/null 2>&1
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Master_Log_File: ${Master_Log_File}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Relay_Master_Log_File: ${Relay_Master_Log_File}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Read_Master_Log_Pos: ${Read_Master_Log_Pos}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  Exec_Master_Log_Pos: ${Exec_Master_Log_Pos}" >> ${LOGFILE}
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  stop slave" >> ${LOGFILE}
            break
        else
            sleep 30
            echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")  sleep 30S" >> ${LOGFILE}
    fi
    done
fi
exit 0
