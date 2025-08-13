#!/bin/bash
if [ $# -ne 1 ];then
  echo -e "传递时间参数"
  exit 9
fi
Q=$1
E=$(date +%Y.%m.%d)
if [[ "${Q}" == "${E}" ]];then
  logfile="catalina.out"
 else
  logfile="catalina.out.${Q}.*"
fi
logdir="/data/apache-tomcat/logs"
tmpdir="/root/$(date +%Y%m%d)_paylogtmp"
mkdir -p $tmpdir
cp $logdir/catalina.out.${Q}.* $tmpdir && cd $tmpdir
F=`ls $tmpdir/catalina.*|awk -F'/' '{print $4}'`
I=$(ifconfig | awk '/inet /{print $2; exit}')
mv $F $I$F
expect -c "
    spawn scp -r root@192.168.99.41:$logdir/catalina.out.${Q}.* $tmpdir
    expect {
        \"Qwerty1!\" {set timeout 10; send \"root\r\"; exp_continue;}
    }



#expect -c "
#    spawn scp -r root@172.28.249.172:$logdir/catalina.out.${Q}.* $tmpdir
#    expect {
#        \"Yhbl3sqt9!\" {set timeout 10; send \"root\r\"; exp_continue;}
#    }
