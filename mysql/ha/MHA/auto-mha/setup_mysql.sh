#!/bin/bash

#安装mysql 5.7数据库,先把mysql5.7 安装包ftp到$STAGE_PATH目录,  然后执行脚本
#初始化密码root为mysql
#安装目录/usr/local/mysql
#字符集utf8
#创建日期 : 2021.07.24. 李曰福 
#修改日期 : 2021.07.25  5.7密码修改为和5.6一样,初始化使用--initialize-insecure
#update: 2022.03.25. setup STAGE_PATH=/root/soft

export MYSQL_HOME=/usr/local/mysql
export STAGE_PATH=/root

if [ $# -ne 1 ]; then
	echo -e "Usage: $0 5.7/5.6\n"
	exit 1;
else
	MYSQL_VER=$1
	if [ $MYSQL_VER = "5.6"  -o  $MYSQL_VER = "5.7" ]; then
		MYSQL_VER=$1
	else
		echo -e "\nNow only support 5.6/5.7, Usage: $0 5.7/5.6\n"
		exit 1;
	fi
		
fi


TAR_FILE="$STAGE_PATH/mysql-${MYSQL_VER}*.tar.gz"
CHK_TAR=`ls $TAR_FILE | wc | awk '{print ($1)}' ` 

if [ $CHK_TAR -lt 1 ]; then
	echo -e "\nPlease put one $TAR_FILE at $STAGE_PATH\n"
	exit 1;
elif [ $CHK_TAR -gt 1 ]; then
	echo -e "\nPlease Just keep one mysql tar file at $STAGE_PATH \n"
	exit 2;
fi

CHK_DIR=`ls $MYSQL_HOME | wc | awk '{print ($1)}' `
if [ $CHK_DIR -gt 0 ];then
	echo -e "\n $MYSQL_HOME is not empty, they will be deleted. ARE YOU SURE ?(Y)"
	read ANSWER
	if [ -z $ANSWER  ];  then
		exit 1;
	elif [  $ANSWER !=  "Y" ];then
		exit 1;
	else
		/etc/init.d/mysql stop
		rm -rf $MYSQL_HOME
		rm -rf `dirname $MYSQL_HOME`/mysql*
	fi
fi

echo -e "\n===============MySQL setup start====================\n"

echo -e "\nNow tar zxvf $TAR_FILE to $MYSQL_HOME ...\n"
grep mysql /etc/passwd >/dev/null 2>&1
if [ $? -gt 0 ]; then
	groupadd mysql
	useradd -g mysql -r -s /bin/false mysql
fi

cd /usr/local
tar zxvf $TAR_FILE >/dev/null 2>&1
ln -s mysql-${MYSQL_VER}* mysql
chown -R mysql:mysql *

cat >/etc/my.cnf<<EOF
[mysqld]
symbolic-links=0
collation_server=utf8_unicode_ci
character_set_server=utf8
basedir=$MYSQL_HOME
datadir=$MYSQL_HOME/data
user=mysql
EOF

cat >> /root/.bash_profile <<EOF
export MYSQL_HOME=/usr/local/mysql
export PATH=$MYSQL_HOME/bin:$PATH
export LD_LIBRARY_PATH=$MYSQL_HOME/lib:$LD_LIBRARY_PATH
EOF


#初始化数据库
echo -e "\nNow initialize MySQL ...\n"
cd $MYSQL_HOME

if [ $MYSQL_VER = "5.7" ];then
	./bin/mysqld --initialize --user=mysql --initialize-insecure > /tmp/init.txt 2>&1
#	PASSWORD=`grep password /tmp/init.txt | awk '{print $(NF)}'`
elif [ $MYSQL_VER = "5.6" ];then
	./scripts/mysql_install_db --user=mysql  >/dev/null 2>&1
fi

echo -e "\nNow start MySQL ...\n"
cp ./support-files/mysql.server /etc/init.d/mysql
chkconfig --add mysql
chkconfig mysql on
./support-files/mysql.server start
sleep 6

#修改密码为mysql
#5.7 使用参数--initialize-insecure后和5.6一样,所以不需要区分5.6，5.7
echo "

"|$MYSQL_HOME/bin/mysqladmin -uroot password mysql >/dev/null 2>&1

#if [ $MYSQL_VER = "5.7" ];then
#	$MYSQL_HOME/bin/mysqladmin -uroot password mysql -p$PASSWORD
#elif [ $MYSQL_VER = "5.6" ];then
#echo "
#
#"|$MYSQL_HOME/bin/mysqladmin -uroot password mysql >/dev/null 2>&1
#fi

cat >> /etc/my.cnf<<EOF
[client]
user=root
password=mysql
EOF

#启动客户端
$MYSQL_HOME/bin/mysql <<EOF
show databases\G
EOF

if [ $? -eq 0 ];then
	echo -e "\nMysql is ready, you can start mysql using '#mysql'.\n"
	echo -e "\n======================MySQL setup done,enjoy :)========================\n"
else
	echo -e "\n Please check error message.\n"
fi


