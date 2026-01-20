#!/bin/bash

#set -e
WORKDIR=$(cd `dirname $0`;pwd)
cecho(){
    echo -e "\033[$1m$2\033[0m"
}

[ $# -ne 3 ] && cecho 31 "没有参数" && exit 1
USERNAME=$1
HOSTIP=$2
PWD=$3
#发送本机公钥到目标主机
if ! rpm -q expect &>/dev/null;then
#	rpm -ivh ${WORKDIR}/../repo/yum/expect-5.45-14.el7_1.x86_64.rpm
	yum -y install expect
fi
[ ! -f ${HOME}/.ssh/id_rsa.pub ] && ssh-keygen -N  '' -f ${HOME}/.ssh/id_rsa     #非交互生成密钥文件
[ -f ${HOME}/.ssh/known_hosts ] && > ${HOME}/.ssh/known_hosts 
echo "StrictHostKeyChecking no" >~/.ssh/config
expect << EOF
    set timeout 300	
    spawn ssh-copy-id ${USERNAME}@${HOSTIP}
    expect "password:" 		{send "${PWD}\r"}
	expect "#"	    		{send "exit\r"}
EOF


