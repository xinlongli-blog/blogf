#!/bin/bash
#创建：2022.03.13,参考文档https://blog.csdn.net/anqixiang/article/details/90312089
#目的：部署MySQL MHA主从架构数据库
#需要：4台数据库，1台主机，2台备机，1台管理机，除管理机外都mysql 5.7(下载地址https://mirrors.aliyun.com/mysql/)
#可以用setup_mysql.sh 5.7部署，自动安装到/usr/local/mysql目录
#配置：配置文件在conf/mysql.conf中，根据实际情况修改ip地址,root密码，mysql数据库下root密码等信息。
#使用：把automha.tar.gz上传到/root下，解压。执行./automha.sh -S
#自动部署mha到4台主机，执行完成，mha已经在运行。

#其他：setup_mysql.sh脚本：部署mysql 
#      reset_mysql.sh  自动停止mysql并重新部署mysql。
#      reset_all.sh, 修改ip，自动删除所有automha文件，并重新部署mysql。执行完成后，主库要执行mysql <createdb.sql 创建测试库db1 db2.

#update: 2022.04.01
#update: 2022.03.13.
#update: 2022.03.15. 增加my.cnf的日志过滤等内容
#update: 2022.03.16. 修正了切换时vip要用括号括起来的错误，sed替换vip时加上双信号,管理机启动参数不清除故障主机配置信息,增加GTID模式
#update: 2022.03.17. 测试了centos7.9，增加禁用防火墙,mysql命令前加路径
#update: 2022.04.01 重新编写linux7的安装包。使用el7的mysql rpm，mha0.58，perl el7的包
#	linux7 上用的mariadb-libs-5.5.68-1.el7.x86_64
#	缺省的系统上安装了mariadb-libs-5.5.68-1.el7.x86_64,这是perl-DBD需要的。测试安装看，没有问题。
#	如果要改用mysql发布的libs，需要安装的rpm包有：
#	mysql-community-libs-5.7.36-1.el7.x86_64
#	mysql-community-libs-compat-5.7.36-1.el7.x86_64
#	mysql-community-common-5.7.36-1.el7.x86_64

#	perl-DBD等下载地址：	https://centos.pkgs.org/
#	mysql-el7下载地址：https://mirrors.aliyun.com/mysql/
#update: 2022.04.03. 配置与oracle相同的事务模式,autocommit=0，transaction_isolation=read-committed
#                    binlog_format使用缺省row,不做修改 
#配置光盘挂载
#[root@mysql01 ~]# cat /etc/yum.repos.d/iso.repo 
#[iso]
#name=iso
#baseurl=file:///mnt
#enabled=1
#gpgcheck=0


#加载配置文件
source /root/conf/automha.conf
cecho(){
        echo -e "\033[$1m$2\033[0m"
}
##############################################################


#初始化环境(50秒)
INIT(){

ln -s $Mysql_Base/bin/mysqlbinlog /usr/bin/mysqlbinlog
ln -s $Mysql_Base/bin/mysql /usr/bin/mysql
cat >> /etc/hosts <<EOF
${Master_Ip}		${Master_hostname}
${Bk_Host_1_Ip}		${Bk_Host_1_hostname}
${Bk_Host_2_Ip}		${Bk_Host_2_hostname}
${Manager_Host}		${Manager_Host_hostname}	
EOF

	#实现免密登陆
	mount /dev/sr0 /mnt
	mkdir /etc/yum.repos.d/bak
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
	cat > /etc/yum.repos.d/iso.repo <<EOF
[iso]
name=iso
baseurl=file:///mnt
enabled=1
gpgcheck=0
EOF
	yum -y install expect
	bash $Script_Path/Pssh.sh root $Master_Ip $System_Root_Pwd 
	bash $Script_Path/Pssh.sh root $Bk_Host_1_Ip $System_Root_Pwd 
	bash $Script_Path/Pssh.sh root $Bk_Host_2_Ip $System_Root_Pwd 
	bash $Script_Path/Pssh.sh root $Manager_Host $System_Root_Pwd 

        #安装Perl依赖包
        yum -y remove mariadb-libs
	mv /etc/my.cnf.rpmsave /etc/my.cnf
        yum -y install $Soft_Path/mysql*.rpm
#        yum -y install perl-DBD-mysql  perl-DBI
        yum -y install $Soft_Path/perl-*.rpm
        rpm -ivh $Soft_Path/mha4mysql-node-0.58-0.el7.centos.noarch.rpm

	#关闭防火墙
	service firewalld stop
	systemctl disable firewalld
}

#修改配置文件，设置半同步，开启binlog日志
CONFIG(){
	cp $Mysql_Conf $Mysql_Conf.bak							#备份配置文件
	echo "[mysqld]" > $Mysql_Conf	

	if [ ${Repl_Gtid} == "ON" ];then
		sed -i "/\[mysqld\]/a gtid_mode=ON" $Mysql_Conf					#设置GTID模式
		sed -i "/\[mysqld\]/a enforce-gtid-consistency=ON" $Mysql_Conf			#设置GTID consistency
	fi
	sed -i "/\[mysqld\]/a master-info-repository=table" $Mysql_Conf			#把master info保存在表里
	sed -i "/\[mysqld\]/a relay-log-info-repository=table" $Mysql_Conf		#把slave log info保存在表里	
	sed -i "/\[mysqld\]/a relay_log_purge=off" $Mysql_Conf				#关闭中继日志自动清除
	sed -i "/\[mysqld\]/a binlog-format=row" $Mysql_Conf				#缺省的ROW	
	sed -i "/\[mysqld\]/a log-bin=${HOSTNAME}-bin" $Mysql_Conf
	sed -i "/\[mysqld\]/a log-bin-index=${HOSTNAME}-bin.index" $Mysql_Conf
	sed -i "/\[mysqld\]/a rpl-semi-sync-slave-enabled=1" $Mysql_Conf		#从库半同步
	sed -i "/\[mysqld\]/a rpl-semi-sync-master-enabled=1" $Mysql_Conf		#主库半同步
	sed -i "/\[mysqld\]/a plugin-load='rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so'" $Mysql_Conf	#加载主从半同步模块
	sed -i "/\[mysqld\]/a #replication settings#" $Mysql_Conf

	sed -i "/\[mysqld\]/a server_id=$Server_Id" $Mysql_Conf
	sed -i "/\[mysqld\]/a symbolic-links=0" $Mysql_Conf
	sed -i "/\[mysqld\]/a collation_server=utf8_unicode_ci" $Mysql_Conf #字符集
	sed -i "/\[mysqld\]/a character_set_server=utf8" $Mysql_Conf  #字符集
	sed -i "/\[mysqld\]/a log_error_verbosity=2" $Mysql_Conf			#告警日志只记录warning，error
	sed -i "/\[mysqld\]/a log_timestamps=SYSTEM" $Mysql_Conf			#修改错误日志时间戳为系统时间
	sed -i "/\[mysqld\]/a explicit_defaults_for_timestamp=ON" $Mysql_Conf		#timestamp
	sed -i "/\[mysqld\]/a transaction_isolation = READ-COMMITTED" $Mysql_Conf	#试用read-committed模式
	sed -i "/\[mysqld\]/a autocommit=0" $Mysql_Conf					#关闭自动提交
	sed -i "/\[mysqld\]/a basedir=${Mysql_Base}"					#base
	sed -i "/\[mysqld\]/a datadir=${Mysql_Data}"					#datadir
	sed -i "/\[mysqld\]/a #basic settings#"  $Mysql_Conf


}

##############################################################


#搭建MHA
SETUP(){
#初始化


#执行MASTER(数据库只读，mysqldump导出）
cecho 36 "部署主库 $Master_Ip"
MASTER
#复制安装介质和数据备份到其它服务器
cecho 36 "复制安装介质和数据备份到其它服务器"
ln -s /root/automha*.tar.gz /root/automha*.tar.gz
scp /root/automha*.tar.gz /root/dump.db $Bk_Host_1_Ip:/root >/dev/null 2>&1
scp /root/automha*.tar.gz /root/dump.db $Bk_Host_2_Ip:/root >/dev/null 2>&1
scp /root/automha*.tar.gz /root/dump.db $Manager_Host:/root >/dev/null 2>&1

cecho 36 "部署备用服务器1 ${Bk_Host_1_Ip}"
ssh $Bk_Host_1_Ip -t "cd /root; tar zxvf automha*.tar.gz; ./automha.sh  -B" 
cecho 36 "部署备用服务器2 ${Bk_Host_2_Ip}"
ssh $Bk_Host_2_Ip -t "cd /root; tar zxvf automha*.tar.gz; ./automha.sh  -B" 
cecho 36 "部署管理机并启动MHA ${Manager_Host}"
ssh $Manager_Host -t "cd /root; tar zxvf automha*.tar.gz; ./automha.sh  -C " 
cecho 36 "检查MHA"
ssh $Manager_Host -t "cd /root; ./automha.sh -T " 
exit;
}


#配置主服务器（17秒）
MASTER(){	
	cecho 36 "创建测试库"
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd  < /root/createdb.sql
	cecho 36 "安装需要的包。。。"
	INIT
#	Float_Ip=`echo $Vip |sed -r 's/(.)(.*)(.)/\2/'`		#浮动IP（192.168.4.100/24）
	ifconfig $Nic:1 $Vip
	cecho 36 "配置my.cnf。。。"
	CONFIG
	cecho 36 "重启MySQL主库。。。"
	/etc/init.d/mysql stop
	/etc/init.d/mysql start
	#添加客户端访问账户
	cecho 36 "添加同步账户,管理账户，访问账户。。。"
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "grant insert,select on *.* to '$Client_User'@'$Grant_Net' identified by '$Client_Pwd'" > /dev/null 2>&1

	#添加管理主机远程连接数据库的用户(监控用户)
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "grant all on *.* to '$Moni_User'@'$Grant_Net' identified by '$Moni_Passwd'" > /dev/null 2>&1
	#添加主从同步授权用户
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "grant replication slave on *.* to '$Master_User'@'$Grant_Net' identified by '$Master_Passwd'" > /dev/null 2>&1

	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "show grants for $Moni_User@'$Grant_Net'" && echo  "监控用户添加成功"
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "show grants for $Master_User@'$Grant_Net'" && echo  "同步授权用户添加成功"

	#当前数据库快照
	
	cecho 36 "主库flush tables with read lock锁表${Master_Sleep}秒。。。"
	nohup $Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "flush tables with read lock;system sleep ${Master_Sleep};"  &
	cecho 36 "主库mysqldump备份"
	if [ ${Repl_Gtid} == "ON" ];then
		$Mysql_Base/bin/mysqldump -uroot -p$Mysql_Pwd --master-data=2 --set-gtid-purged=off --databases $DBNAME > /root/dump.db #GTID模式
	else
	
		$Mysql_Base/bin/mysqldump -uroot -p$Mysql_Pwd --master-data --databases $DBNAME > /root/dump.db  #log-pos模式
	fi


}

#选择主库
SELECT_MASTER(){		
	if [ ${Repl_Gtid} ==  "ON" ];then
		$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "change master to master_host='$Master_Ip',master_user='$Master_User',master_password='$Master_Passwd',master_auto_position=1"
	else		
		$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "change master to master_host='$Master_Ip',master_user='$Master_User',master_password='$Master_Passwd'"
	fi
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "start slave"
	sleep 5
	$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "select user,host from mysql.user;"
	Io_Thread=`$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "show slave status\G" |grep 'Slave_IO_Running' |awk '{print $2}'`
	Sql_Thread=`$Mysql_Base/bin/mysql -uroot -p$Mysql_Pwd -e "show slave status\G" |grep 'Slave_SQL_Running:' |awk '{print $2}'`
	if [ "$Io_Thread" == "Yes" -a "$Sql_Thread" == "Yes" ];then
		cecho 36 "主从同步成功"
	else 
		cecho 31 "主从同步失败"
		exit $ISERROR
	fi
}

#配置备用主服务器（9秒）
BACKUP_MASTER(){
	cecho 36 "安装备用服务器..."
	INIT
	CONFIG
#	sed -i '/\[mysqld\]/a super_read_only=on' $Mysql_Conf	
# 如果加上super_read_only=on masterha就不能检查状态
	sed -i "/\[mysqld\]/a read_only=on" $Mysql_Conf	
	sed -i "/\[mysqld\]/a relay_log_index=${HOSTNAME}-relay-bin.index" $Mysql_Conf	
	sed -i "/\[mysqld\]/a relay_log=${HOSTNAME}-relay-bin" $Mysql_Conf	
	if [ ${Repl_Gtid} != "ON" ];then
		sed -i "/\[mysqld\]/a relay-log-recovery=1" $Mysql_Conf #使用log pos模式，需要设置relay-log-recovery参数
	fi
	/etc/init.d/mysql stop
	/etc/init.d/mysql start
	$Mysql_Base/bin/mysql < /root/dump.db > /dev/null 2>&1
	$Mysql_Base/bin/mysql -e "select user,host from mysql.user;"
	SELECT_MASTER && cecho 36 "备用主服务器配置成功"
}

#配置数据备用服务器（9秒）
DATA_BACKUP(){
	cecho 36 "安装数据备用服务器。。。"
	INIT
	cp $Mysql_Conf $Mysql_Conf.bak		#备份配置文件
	sed -i '/\[mysqld\]/a relay_log_purge=off' $Mysql_Conf	
	sed -i "/\[mysqld\]/a server_id=$Server_Id" $Mysql_Conf
	sed -i '/\[mysqld\]/a rpl-semi-sync-slave-enabled=1' $Mysql_Conf
	sed -i '/\[mysqld\]/a plugin-load="rpl_semi_sync_slave=semisync_slave.so"' $Mysql_Conf
	/etc/init.d/mysql stop
	/etc/init.d/mysql start
	$Mysql_Base/bin/mysql < /root/dump.db
	SELECT_MASTER && cecho 36 "数据备用服务器配置成功"
}

#配置管理主机(35)
MANAGER(){	
	cecho 36 "初始化管理机安装。。。"
	INIT
	yum -y install $Soft_Path/mha4mysql-manager-0.58-0.el7.centos.noarch.rpm
	mkdir `dirname $Mha_Conf`		#创建目录/etc/mha_manager
	touch $Mha_Conf
	#故障切换脚本
	cp $Soft_Path/master_ip_failover  `dirname $Mha_Conf`
	cp $Soft_Path/master_ip_online_change  `dirname $Mha_Conf`
	cp $Soft_Path/send_report  `dirname $Mha_Conf`
	sed -i "34c my \$vip = \"$Vip\"; \# Virtual IP"  `dirname $Mha_Conf`/master_ip_failover			#修改Vip地址,加引号
	sed -i "34c my \$vip = \"$Vip\"; \# Virtual IP"  `dirname $Mha_Conf`/master_ip_online_change		#修改Vip地址,加引号
	sed -i "s/eth0/${Nic}/" `dirname $Mha_Conf`/master_ip_failover
	sed -i "s/eth0/${Nic}/" `dirname $Mha_Conf`/master_ip_online_change
	#写入管理主机的配置文件
	cat >> $Mha_Conf << EOF
[server default]
manager_workdir=`dirname $Mha_Conf`
manager_log=`dirname $Mha_Conf`/manager.log
master_ip_failover_script=`dirname $Mha_Conf`/master_ip_failover 
master_ip_online_change_script=`dirname $Mha_Conf`/master_ip_online_change 
secondary_check_script=/usr/bin/masterha_secondary_check -s "$Bk_Host_1_Ip"  -s "$Bk_Host_2_Ip" --user=root  --master_host="$Master_hostname" --master_ip="$Master_Ip"  --master_port=3306


ssh_port=22
ssh_user=root
repl_user=$Master_User
repl_password=$Master_Passwd
user=$Moni_User
password=$Moni_Passwd
master_binlog_dir=$Mysql_Base/data


[server$Master_ID]
hostname=$Master_hostname
candidate_master=1

[server$Bk_Mst1_ID]
hostname=$Bk_Host_1_hostname
candidate_master=1

[server$Bk_Mst2_ID]
hostname=$Bk_Host_2_hostname
candidate_master=1

EOF


/usr/bin/masterha_check_ssh --conf=$Mha_Conf && masterha_check_repl --conf=$Mha_Conf
[ $? -eq 0 ] && cecho 36 "MHA检查正常"	
cecho 36 "启动MHA。。。"
#nohup /usr/bin/masterha_manager --conf=/etc/mha_manager/app1.cnf --remove_dead_master_conf --ignore_last_failover &	#启动管理服务
nohup /usr/bin/masterha_manager --conf=/etc/mha_manager/app1.cnf --ignore_last_failover &	#启动管理服务,切换时不清楚故障主机配置信息
sleep 10

}

#测试MHA集群
TEST(){
	/usr/bin/masterha_check_status --conf=/etc/mha_manager/app1.cnf 	#查看状态	 
}

#帮助信息
HELP(){
	cat << EOF
Usage: automha.sh [optional]
=======================================================================
optional arguments:

	\?)
	-h	提供帮助信息
	-S	部署整个MHA(在主服务器运行)
	-T	测试集群(在管理机运行)
EXAMPLE:
	automha.sh -S
EOF
}

#############################主程序#############################
[ $# -eq 0 ] && HELP
while getopts :CSHIMBDMT ARGS
do
	case $ARGS in
	S)
		SETUP;;	
	R)
		SELECT_MASTER;;
	H)
		HELP;;
	I)
		INIT;;
	M)
		MASTER;;
	B)
		BACKUP_MASTER;;
	D)
		DATA_BACKUP;;
	C)
		MANAGER;;
	T)
		TEST;;	
	\?)
		cecho 31 "Invalid option:bash `basename $0` [-h]"
	esac
done

