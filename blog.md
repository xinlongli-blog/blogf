--20220217
192.168.100.28
P20_LifeExt_to_P90_LifeCIRC
SHSQLP20LIFEEXT_SHSQLP30_LIFEMIR
SHSQLP20_LIFEEXT_P30_LIFEDUP

192.168.100.32
P20_LifeExt-100_216_LifeExt
p20_LifeExt_to_249_248_LifeExt
P20_LifeExt-100_216_TYCX_LifeExt stop

#打开等待事件采集器配置项开关，需要修改配置表中对应的采集器配置项
update setup_instruments set enabled ='yes',timed='yes' where name like 'wait%';

#打开等待时间的保存表配置开关，修改配置表中对应的配置项
update setup_consumers set enabled ='yes' where name like '%wait%';

#导出备份
mysqldump -h192.168.88.132 -ulixl -p --single-transaction --skip-opt --databases bioinfo --triggers --routines --events --master-data=2 --delete-master-logs --add-drop-database --create-options --complete-insert --extended-insert --disable-keys --set-charset --tz-utc --quick --log-error=/root/bioinfo_error.txt > /root/bioinfo_backup_20220615.sql

#导入数据
1：mysql -uroot -p < /root/bioinfo_backup_20220615.sql
2：mysql -uroot -p
MySQL [(none)]> source /root/bioinfo_backup_20220615.sql

#截取position位置并导出sql
/usr/local/mysql/bin/mysqlbinlog  --start-position="486" /usr/local/mysql/data/mysql-bin.000138 >/138.sql

mysql -ulixl -p -e "GRANT REPLICATION SLAVE ON *.* TO 'monitor'@'%' IDENTIFIED BY '2&Ru@bbMT';"
alter user 'monitor'@'localhost' identified by '2&Ru@bbMT';

CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000004',MASTER_LOG_POS=154;
#从库回放sql
start slave

# 用户有效期
create user loge@'%' identified by '123456' password expire interval 90 day;
alter user loge@'%' identified by '123456' password expire interval 90 day;
# 禁用过期，永久不过期：
create user loge@'%' identified by '123456' password expire never;
alter user loge@'%' identified by '123456' password expire never;
# 手动强制某个用户密码过期
ALTER USER 'loge'@'%' PASSWORD EXPIRE;

ALTER USER 'test'@'%' identified BY '123' PASSWORD EXPIRE;
# 用户重命名
rename user 'chenhh'@'%' to 'zhoujielun'@'%';

create user 'zabbix'@'%' identified by 'zabbix';

create user 'lixl'@'%' IDENTIFIED BY 'lixl';
grant all privileges on *.* to lixl@'%' with grant option; 
revoke shutdown on *.* from 'lixl'@'%';
FLUSH PRIVILEGES; 
做生活的高手
create user 'readonly'@'%' IDENTIFIED BY 'readonly@123';

# with grant option 通过在grant语句的最后使用该子句，就允许被授权的用户把得到的权限继续授给其它用户
grant select on `evoicecs`.* to readonly@'%' with grant option; 
FLUSH PRIVILEGES;

create user 'proxysql'@'%' IDENTIFIED BY 'proxysql';
GRANT ALL PRIVILEGES ON `sign`.* TO 'proxysql'@'%'
FLUSH PRIVILEGES;

CREATE DATABASE `sign` /*!40100 DEFAULT CHARACTER SET utf8 */
create database pos_node default charset utf8 collate utf8_general_ci;
GRANT ALL PRIVILEGES ON `pos_node`.* TO 'us_pos_payment'@'%'

#8.1
CREATE DATABASE `Test_database` CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci';

grant all on lis.* to 'us_lis'@'%';

create user 'repl'@'%' IDENTIFIED BY '2&Ru@bbMT';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
change master to master_host='17.16.10.129' ,master_user='repl',master_password='repl',master_auto_position=1;
ALTER USER 'repl'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'repl';

change master to master_host='17.16.10.131' ,master_user='orchestrator',master_password='Orc@1234',master_auto_position=1;
ALTER USER 'orchestrator'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'Orc@1234';
CREATE USER 'pmm'@'127.0.0.1' IDENTIFIED BY '2&Ru@bbMT' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'127.0.0.1';


CREATE USER pmm WITH SUPERUSER ENCRYPTED PASSWORD '2&Ru@bbMT';


create user 'root'@'%' IDENTIFIED BY 'qwerty1!';
grant all privileges on *.* to root@'%' with grant option; 
revoke shutdown on *.* from 'root'@'%';
FLUSH PRIVILEGES; 
alter user 'root'@'localhost' identified by 'Cmbjx3ccwtn9';
alter user 'root'@'localhost' identified by 'P@ssw0rd001!';
alter user 'root'@'localhost' identified by 'superpercona';
update user set authentication_string=password('Cmbjx3ccwtn9') where user='root' and host='localhost'; --5.7.27
Cmbjx3ccwtn9

alter user 'root'@'%' identified by 'qwerty1!';

CREATE USER 'pmm'@'%' IDENTIFIED BY 'pass' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'%';
FLUSH PRIVILEGES;

create user 'csdev'@'%' IDENTIFIED BY '2&Ru@bbMT';
GRANT ALL PRIVILEGES ON `csdev`.* TO 'csdev@'%';

#某张表只读指定字段 update类似 grant update(empno,job) on testg.emp to readonly;
grant select(empno,job) on testg.emp to readonly;
flush privileges;

#修改库字符集
ALTER DATABASE testg DEFAULT CHARACTER SET utf8mb4

#当用户对同一数据库同时具备 USAGE 和 GRANT OPTION 两种权限时，就会出现冲突。此时便可以查看到该数据库以及库下所有表的信息，但无法查看表内具体数据。
GRANT USAGE ON *.* TO 'hjm'@'%';
GRANT USAGE ON `test`.* TO 'hjm'@'%' WITH GRANT OPTION;
#回收GRANT OPTION 权限
REVOKE GRANT OPTION on test.* from 'hjm'@'%' ;

#字符排序
CREATE DATABASE `pos_secondarywriting` CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';
select schema_name,default_character_set_name,default_collation_name from information_schema.schemata where schema_name = 'pos_secondarywriting';

#获取cpu搞sql
top -u mysql -H 查看sql thread id
select p.* 
from information_schema.processlist p,performance_schema.threads t 
where t.PROCESSLIST_ID=p.id and THREAD_OS_ID in (27244) ***sql thread id

#lock
SELECT  r.trx_id，waiting_trx_id,  r.trx_mysql_thread_idwaiting_thread, r.trx_query waiting_query,  b.trx_id，blocking_trx_id, b.trx_mysql_thread_id，blocking_thread,  
b.trx_query，blocking_query
FROM performance_schema.data_lock_waits w
INNER JOIN information_schema.innodb_trx b  ON b.trx_id = w.blocking_engine_transaction_idINNER JOIN information_schema.innodb_trx r  ON r.trx_id = w.requesting_engine_transaction_id;

SELECT  waiting_trx_id, waiting_pid,  waiting_query,  blocking_trx_id, blocking_pid, blocking_query
FROM sys.innodb_lock_waits;

CREATE USER 'pmm'@'%' IDENTIFIED BY 'perca!1U9N' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'%';

# 5.7 PROCEDURE 权限
grant select on mysql.proc to 'us_testg'@'%'

# 8.0
grant select on *.* to us_testg@'%'

# 8.0.20 PROCEDURE 权限
# https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html
GRANT show_routine on *.* TO 'us_testg'@'%'  
/**
SHOW_ROUTINE (added in MySQL 8.0.20)
Enables a user to access definitions and properties of all stored routines (stored procedures and functions), even those for which the user is not named as the routine DEFINER. This access includes:
The contents of the Information Schema ROUTINES table.
The SHOW CREATE FUNCTION and SHOW CREATE PROCEDURE statements.
The SHOW FUNCTION CODE and SHOW PROCEDURE CODE statements.
The SHOW FUNCTION STATUS and SHOW PROCEDURE STATUS statements.
Prior to MySQL 8.0.20, for a user to access definitions of routines the user did not define, the user must have the global SELECT privilege, which is very broad. As of 8.0.20, SHOW_ROUTINE may be granted instead as a privilege with a more restricted scope that permits access to routine definitions. (That is, an administrator can rescind global SELECT from users that do not otherwise require it and grant SHOW_ROUTINE instead.) This enables an account to back up stored routines without requiring a broad privilege.**/
revoke show_routine on *.* from 'us_testg'@'%' 

revoke ALL privileges ON *.* from `us_testg`@`%`

#备份权限5.7x
alter user 'root'@'localhost' identified by 'P@ssw0rd001!';
CREATE USER 'bkpuser'@'%' IDENTIFIED BY 'P3QaaQPhby)D';
GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO'bkpuser'@'%';
FLUSH PRIVILEGES;

#备份权限8.0x
CREATE USER 'bkpuser'@'%' IDENTIFIED BY 'Password001';
GRANT BACKUP_ADMIN, PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'bkpuser'@'%'; 
GRANT SELECT ON performance_schema.log_status TO 'bkpuser'@'%';
GRANT SELECT ON performance_schema.keyring_component_status TO bkpuser@'%';
FLUSH PRIVILEGES;

#复制权限
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'

#pt主从数据一致性校验
pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=area.checksums --create-replicate-table --databases=area --tables=haha h=192.168.88.129,u=lixl,p=lixl,P=3306
./pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=testa.checksums --create-replicate-table --databases=testa  h=172.18.100.59,u=root,p=Cmbjx3ccwtn9,P=3308


#修复不一致数据 打印主从表信息不一致语句 --execute参数直接修复 生产不建议
pt-table-sync --replicate=area.checksums h=192.168.88.129,u=lixl,p=lixl h=192.168.88.129,u=lixl,p=lixl --print
./pt-table-sync --replicate=testa.checksums h=172.18.100.59,P=3308,u=root,p='Cmbjx3ccwtn9' h=172.18.100.74,P=3306,u=root,p='Cmbjx3ccwtn9' --print

#修复主从错误 error-numbers报错编码
#注意、此工具可以修复io sql线程均为yes状态、但是不能彻底恢复、通过校验数据完整性需要手工修复
pt-slave-restart --user=root --password='qwerty1!' --socket=/data/mysql8/socket/mysql.sock --error-numbers=1062
./pt-slave-restart --user=root --password='Cmbjx3ccwtn9' --socket=/data/mysql/mysql_sock/mysql.sock --error-numbers=1050

#主从延迟监控 在主库上创建后台update进程
pt-heartbeat -ulixl -plixl -D area --create-table --update --daemonize

#server-id指向主库 其他从库 --interval 1s
pt-heartbeat -ulixl -plixl -D area --table=heartbeat --master-server-id=1  --monitor -h 192.168.88.133 --interval=1

#在线ddl
pt-online-schema-change --user=lixl --password=lixl --host=192.168.88.129 --alter="modify column comn decimal(8,2)" D=jobdata,t=emp --execute --nocheck-replication-filters
ALTER TABLE `test11` modify COLUMN  `ucid` bigint(20) NOT NULL DEFAULT 0 COMMENT '线索ucid';
ALTER TABLE li_pb_input_item MODIFY COLUMN READONLY VARCHAR(12) NOT NULL AFTER id
ALTER TABLE li_pb_input_item RENAME TO li_pb_input_item_up

gh-ost \
--max-load=Threads_running=20 \
--critical-load=Threads_running=50 \
--critical-load-interval-millis=5000 \
--chunk-size=1000 \
--user="root" \
--password='Cmbjx3ccwtn9' \
--host='172.18.100.74' \
--port=3306 \
--database="pos_payment" \
--table="t_payment_transaction_history" \
--verbose \
--alter="engine=innodb" \
--assume-rbr \
--cut-over=default \
--cut-over-lock-timeout-seconds=1 \
--dml-batch-size=10 \
--allow-on-master \
--concurrent-rowcount \
--default-retries=10 \
--heartbeat-interval-millis=2000 \
--panic-flag-file=/tmp/ghost.panic.flag \
--postpone-cut-over-flag-file=/tmp/ghost.postpone.flag \
--timestamp-old-table \
--execute 2>&1 | tee /tmp/t_payment_transaction_history.log

-- pt-online-schema-change --user=percona --password=percona --host=172.18.100.59 --port=3308 --alter="modify column ROWVERSION decimal(8,2)" D=partition_1,t=ats_choudan_tmp --execute --dry-run --nocheck-replication-filters

#添加主键id自增无符号
ALTER TABLE pay_detail_copy_1 ADD COLUMN id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

alter table _cps_approve_info_del add column t2 varchar(12)
AS400_to_P20_LifeMir20210913 VRIDER VCNTRS
AS400-100_216_LifeMir  VRIDER
AS400-99_11_LifeMir VRIDER
AS400_DATAJRN-100_216_LifeMir VRIDER
AS400_to_100_98_LifeMir VRIDER
AS400_to_99_10_LifeMir VRIDER VCNTRS
AS400_to_99_13_LifeMir VRIDER VCNTRS
AS400_to_100_99_LifeMir VCNTRS
AS400_to_P30_LifeMir20191223 VCNTRS

#plugin_clone https://dev.mysql.com/doc/refman/8.0/en/clone-plugin-remote.html

[mysqld]
plugin-load-add=mysql_clone.so
or
INSTALL PLUGIN clone SONAME 'mysql_clone.so';

select plugin_name,plugin_status from information_schema.plugins where plugin_name like 'clone';

#本地克隆
mysql> CREATE USER clone_user@'%' IDENTIFIED by 'password';
mysql> GRANT BACKUP_ADMIN ON *.* TO 'clone_user';  # BACKUP_ADMIN是MySQL8.0 才有的备份锁的权限

执行本地克隆
mysql -uclone_user -ppassword -S /tmp/mysql3008.sock
mysql> CLONE LOCAL DATA DIRECTORY = '/fander/clone_dir';

#捐赠者
CREATE USER clone_user@'172.18.100.59' IDENTIFIED by 'P@ssw0rd001';
GRANT BACKUP_ADMIN ON *.* TO 'clone_user'@'172.18.100.74';  # BACKUP_ADMIN是MySQL8.0 才有的备份锁的权限
#接受者
CREATE USER clone_user@'172.18.100.74' IDENTIFIED by 'P@ssw0rd001';
GRANT CLONE_ADMIN ON *.* TO 'clone_user'@'172.18.100.59';

set global clone_valid_donor_list='172.18.100.59:3308' # 将捐赠者 MySQL 服务器实例的主机地址添加到 clone_valid_donor_list 变量设置中
CLONE INSTANCE FROM clone_user@'172.18.100.59':3308 IDENTIFIED BY 'P@ssw0rd001';

SELECT STAGE, STATE, END_TIME FROM performance_schema.clone_progress;	# `克隆流程`
SELECT STATE FROM performance_schema.clone_status;	# `克隆进度`
SELECT STATE, ERROR_NO, ERROR_MESSAGE FROM performance_schema.clone_status; # `克隆是否有问题`
show global status like 'Com_clone';  # `捐赠者` 每次+1，`接受者` 0

create user repl@'%' identified WITH 'mysql_native_password' by 'P@ssw0rd001';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%'; 

stop replica; reset replica;

CHANGE MASTER TO
  MASTER_HOST='172.18.100.59',
  MASTER_USER='repl',
  MASTER_PASSWORD='P@ssw0rd001',
  MASTER_PORT=3308,
  MASTER_AUTO_POSITION=1;

show replica status\G;

grant
SELECT HOST,USER FROM mysql.user
ALTER USER ltest IDENTIFIED WITH caching_sha2_password BY '123';
CREATE USER 'armoto'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'Passarmoto123';
 
-- 对目标数据库的权限
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON `bjfinance`.* TO 'armoto'@'%';

SELECT COUNT(1) FROM llfinanceinterfaceimp

GRANT REPLICATION SLAVE, REPLICATION CLIENT, SUPER ON *.* TO 'armoto'@'%';
GRANT SELECT ON `bjfinance`.* TO 'armoto'@'%';

#mysql8.0.26安装
#初始化
/opt/mysql-8.0.26/bin/mysqld --defaults-file=/etc/my.cnf.d/my.cnf --initialize --user=mysql

-----------------------------------------------
--my.cnf
[mysqld]
basedir=/opt/mysql-8.0.26/
datadir=/opt/mysql-3307/data/
socket=/opt/mysql-3307/mysql_sock/mysql.sock
server_id=1322
log_bin=/opt/mysql-3307/binlog/mysql-bin
binlog_format=row
expire_logs_days=7
max-binlog-size = 1024M
port = 3307
symbolic-links=0
lower_case_table_names=1
binlog_expire_logs_seconds=604800 `7天：秒数为单位 Mysql8.0` 5.7 expire_logs_days
# 清理binlog 1.清理全部binlog除了此binlog：purge binary logs to 'mysql-bin.000136';2.清理指定时间前的binlog：purge binary logs before '2017-05-01 13:09:51';
log_error = /opt/mysql-3307/log/mysql-error.log
#innodb_force_recovery = 0
#sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
user=mysql

[mysqld_safe]
log-error = /opt/mysql-3307/log/mysql-error.log
pid-file=/opt/mysql-3307/data
user=mysql

[client]
socket=/opt/mysql-3307/mysql_sock/mysql.sock
user=mysql
-----------------------------------------------

#修改support-files/mysql.server 
basedir=/opt/mysql-8.0.26/
datadir=/opt/mysql-3307/data/
conf=/etc/my.cnf.d/my.cnf

extra_args=""
if test -r "$basedir/my.cnf"
then
  extra_args="-e $basedir/my.cnf"
fi
#extra_args="-c $conf" 增加

$bindir/mysqld_safe /--defaults-file="$conf" 增加 / --datadir="$datadir" --pid-file="$mysqld_pid_file_path" $other_args >/dev/null &
      wait_for_pid created "$!" "$mysqld_pid_file_path"; return_value=$?

#启动mysql
support-files/mysql.server start	 
	
#月度维护(服务器密码
shsqlp10bk\administrator ng.life59
shsqlp30\administrator 
shsqlp50\administrator ng.life59
shsqlp60\administrator
shsqlp70\administrator ng.life59
shsqlp80\administrator ng.life59
shsqlp90\administrator ng.life59
shsqlp100\administrator ng.life
shsqlp120\administrator ng.life

shiisp10\administrator ng.life59
C:\project\Seeyon\A8\ApacheJetspeed\work 删除
shiisp30\administrator ng.life59
shiisp40\administrator ng.life59
Shygz\administrator ng.life59
Shdb2\administrator Unitedplaza37
shdbbk\administrator ng.life59
shdtg\administrator ng.life59
shhr\administrator ng.life59
shibm\administrator ng.life59
shprt1\administrator Unitedplaza37
shrptp10\administrator ng.life59
shwas3\administrator Unitedplaza37
shwasp10\administrator Unitedplaza37

#20220218

docker stop $(docker ps -a | awk '{ print $1}' | tail -n +2)

mysql架构体系
mysql向外提供交互接口--connectors


#阿里云密码
121.40.213.220
root
latency@1


insert into handler_table values(3, '张三');
insert into handler_table values(4, '李四');
insert into handler_table values(5, '王五');
insert into handler_table values(1, '刘一');
insert into handler_table values(2, '陈二');

Create Table: CREATE TABLE `handler_table` (
  `id` int(11) DEFAULT NULL,
  `name` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1

# GTID POSITION
change master to master_host='10.67.33.136' ,master_user='repl',master_password='repl',master_auto_position=1;

change master to master_host='172.18.100.194' ,master_user='repl',master_password='2&Ru@bbMT',master_auto_position=1;

58e6250d-356f-11ec-982c-000c29bb216a:1-6694556,
612c68db-7da3-11ec-8daa-000c296e8b4d:7-76,
b3972d82-5c69-11eb-a08e-525400b8eba7:19184702-19361245

#位点
change master to master_host='192.168.88.131',master_user='lixl',master_password='lixl',master_log_file='mysql-bin.000015',master_log_pos=194;


log-bin   = /data/mysql-3306/data/mysql-bin
server-id =41
sync_binlog = 1
innodb_flush_log_at_trx_commit=1
binlog_format = row

server-id = 9941
log_bin=/data/mysql/data/mysql-bin
binlog_format = row
sync_binlog = 1
innodb_flush_log_at_trx_commit=1

#备份
mysqldump -h192.168.99.41 -uroot -p --single-transaction --skip-opt --databases sign --triggers --routines --events --master-data=2 --delete-master-logs --add-drop-database --create-options --complete-insert --extended-insert --disable-keys --set-charset --tz-utc --quick --log-error=/root/sign_error.txt > /root/sign_backup_20220222.sql

scp root@192.168.99.41:/root/sign_backup_20220222.sql /root/

#恢复
mysqldump -h192.168.99.53 -uroot -p </root/sign_backup_20220222.sql

校验

#查看当前binlog文件 与pos
show master status;
#change主从
change master to 
master_host='192.168.99.41',
master_user='root',
master_password='Cmbjx3ccwtn9',
master_log_file='mysql-bin.',
master_log_pos=;

start slave;
show slave status\G;
mysqldump -h192.168.99.41 -uroot -p --single-transaction --skip-opt --databases sign --triggers --routines --events --master-data=2 --delete-master-logs --add-drop-database --create-options --complete-insert --extended-insert --disable-keys --set-charset --tz-utc --quick --log-error=/root/sign_error.txt > /root/sign_backup_20220222.sql

#mysqldump主动搭建
select Heartbeat from slave_master_info

DROP DATABASE t;

SHOW BINARY logs
'mysql-bin.000001', 180, 'No'
'mysql-bin.000002', 6780, 'No'


laster DROP database t
'mysql-bin.000001', 180, 'No'
'mysql-bin.000002', 6952, 'No'

#如果记录gtid 导入数据会报错、需清空该参数GLOBAL.GTID_EXECUTED 需reset master即可。
ERROR 3546 (HY000) at line 26: @@GLOBAL.GTID_PURGED cannot be changed: the added gtid set must not overlap with @@GLOBAL.GTID_EXECUTED
SELECT @@GLOBAL.GTID_EXECUTED

reset master;



#mysqldump些参数说明:
--single-transaction
	single-transaction参数的作用，设置事务的隔离级别为可重复读，即REPEATABLE READ，这样能保证在一个事务中所有相同的查询读取到同样的数据，也就大概保证了在dump期间，如果其他innodb引擎的线程修改了表的数据并提交，对该dump线程的数据并无影响，在这期间不会锁表。

--skip-opt
	关闭--opt选项

--triggers
	导出触发器。该选项默认启用，用--skip-triggers禁用它。

 --routines, -R
    导出存储过程以及存储函数。注意：该参数并不导出属性信息如：存储过程创建和修改的时间戳。导入时创建的时间戳和导入时时间相同。假如要使用原始的时间戳，不要使用参数--routines，而是直接备份mysql.proc的内容（需要用户有相关权限）
 
 --events, -E
    导出事件调度。

--master-data[=value]
    该参数有两个值1和2，默认为1 
    mysqldump导出数据时，当这个参数的值为1的时候，mysqldump出来的文件就会包括CHANGE MASTER TO这个语句，CHANGE MASTER TO后面紧接着就是file和position的记录，在slave上导入数据时就会执行这个语句，salve就会根据指定这个文件位置从master端复制binlog。当这个值是2的时候，chang master to也是会写到dump文件里面去的，但是这个语句是被注释的状态。
    使用该选项需要在my.cnf中开启binary log并需要拥有RELOAD权限。该参数会主动关闭--lock-tables，如果未使用--single-transaction，该参数还会自动开启--lock-all-tables，否则不开启。

 --delete-master-logs
    master备份完成后通过语句PURGE BINARY LOGS删除日志. 这个参数将自动激活--master-data。

--add-drop-database
    在CREATE DATABASE语句前增加DROP DATABASE语句，一般配合--all-databases 或 --databases使用，因为只有使用了这二者其一，才会记录CREATE DATABASE语句。

--create-options
    在CREATE TABLE语句中包括所有MySQL特性选项。(默认为打开状态)
	
--complete-insert, -c
    使用完整的insert语句(包含列名称)。这么做能提高插入效率，但是可能会受到max_allowed_packet参数的影响而导致插入失败。

 --extended-insert, -e
    使用具有多个VALUES列的INSERT语法。这样使导出文件更小，并加速导入时的速度。默认为打开状态，使用--skip-extended-insert取消选项。
	
--disable-keys, -K
    对于每个表，用/*!40000 ALTER TABLE tbl_name DISABLE KEYS */;和/*!40000 ALTER TABLE tbl_name ENABLE KEYS */;语句引用INSERT语句。这样可以更快地导入dump出来的文件，因为它是在插入所有行后创建索引的。该选项只适合非唯一索引的MyISAM表，默认为打开状态。

 --set-charset
    添加'SET NAMES  default_character_set'到输出文件。默认为打开状态，使用--skip-set-charset关闭选项

--tz-utc
    在导出顶部设置时区TIME_ZONE='+00:00' ，以保证在不同时区导出的TIMESTAMP 数据或者数据被移动其他时区时的正确性。该参数默认开启，如需关闭使用参数 --skip-tz-utc

--quick, -q
    该选项在导出大表时很有用，它强制 mysqldump 从服务器查询取得记录直接输出而不是取得所有记录后将它们缓存到内存中，即不缓冲查询，直接导出到标准输出。默认为打开状态，使用--skip-quick取消该选项。
	

Innodb 状态的部分解释:
Innodb_buffer_pool_pages_data
Innodb buffer pool缓存池中包含数据的页的数目，包括脏页。单位是page。

Innodb_buffer_pool_pages_dirty
innodb buffer pool缓存池中脏页的数目。单位是page。

Innodb_buffer_pool_pages_flushed
innodb buffer pool缓存池中刷新页请求的数目。单位是page。

Innodb_buffer_pool_pages_free
innodb buffer pool剩余的页数目。单位是page。

Innodb_buffer_pool_pages_misc
innodb buffer pool缓存池中当前已经被用作管理用途或hash index而不能用作为普通数据页的数目。单位是page。

Innodb_buffer_pool_pages_total
innodb buffer pool的页总数目。单位是page。

Innodb_buffer_pool_read_ahead
后端预读线程读取到innodb buffer pool的页的数目。单位是page。

Innodb_buffer_pool_read_ahead_evicted
预读的页数，但是没有被读取就从缓冲池中被替换的页的数量，一般用来判断预读的效率。

Innodb_buffer_pool_read_requests
innodb进行逻辑读的数量。单位是次。

Innodb_buffer_pool_reads
进行逻辑读取时无法从缓冲池中获取而执行单页读取的次数。单位是次。

Innodb_buffer_pool_wait_free
写入 InnoDB 缓冲池通常在后台进行，但有必要在没有干净页的时候读取或创建页，有必要先等待页被刷新。Innodb的IO线程从数据文件中读取了数据要写入buffer pool的时候，需要等待空闲页的次数。单位是次。

Innodb_buffer_pool_write_requests
写入 InnoDB 缓冲池的次数。单位是次。

Innodb_data_fsyncs
innodb进行fsync()操作的次数。单位是次。

Innodb_data_pending_fsyncs
innodb当前挂起 fsync() 操作的数量。单位是次。

Innodb_data_pending_reads
innodb当前挂起的读操作数。单位是次。

Innodb_data_pending_writes
inndo当前挂起的写操作数。单位是次。

Innodb_data_read
innodb读取的总数据量。单位是字节。

Innodb_data_reads
innodb数据读取总数。单位是次。

Innodb_data_writes
innodb数据写入总数。单位是次。

Innodb_data_written
innodb写入的总数据量。单位是字节。

Innodb_dblwr_pages_written
innodb已经完成的doublewrite的总页数。单位是page。

Innodb_dblwr_writes
innodb已经完成的doublewrite的总数。单位是次。

Innodb_log_waits
因日志缓存太小而必须等待其被写入所造成的等待数。单位是次。

Innodb_log_write_requests
innodb日志写入请求数。单位是次。

Innodb_log_writes
innodb log buffer写入log file的总次数。单位是次。

Innodb_os_log_fsyncs
innodb log buffer进行fsync()的总次数。单位是次。

Innodb_os_log_pending_fsyncs
当前挂起的 fsync 日志文件数。单位是次。

Innodb_os_log_pending_writes
当前挂起的写log file的数目。单位是次。

Innodb_os_log_written
写入日志文件的字节数。单位是字节。

Innodb_page_size
编译的 InnoDB 页大小 (默认 16KB)。

Innodb_pages_created
innodb总共的页数量。单位是page。

Innodb_pages_read
innodb总共读取的页数量。单位是page。

Innodb_pages_written
innodb总共写入的页数量。单位是page。

Innodb_row_lock_current_waits
innodb当前正在等待行锁的数量。单位是个。

Innodb_row_lock_time
innodb获取行锁的总消耗时间。单位是毫秒。

Innodb_row_lock_time_avg
innodb获取行锁等待的平均时间。单位是毫秒。

Innodb_row_lock_time_max
innodb获取行锁的最大等待时间。单位是毫秒。

Innodb_row_lock_waits
innodb等待获取行锁的次数。单位是次。

Innodb_rows_deleted
从innodb表中删除的行数。单位是行。

Innodb_rows_inserted
插入到innodb表中的行数。单位是行。

Innodb_rows_updated
innodb表中更新的行数。单位是行

#查看脏页数量
mysqladmin ext| grep dirty

#mysql监控指标
QPS
TPS
并发数
连接数 (最大连接数、当前连接数)
慢查询 (5s)
每秒SQL执行次数
缓冲池的脏块的百分率 innodb_buffer_pool_pages_dirty / innodb_buffer_pool_pages_total
innodb 脏页数量 innodb_buffer_pool_pages_dirty
innodb 缓存池读命中率 innodb_buffer_read_hit_ratio = ( 1 – innodb_buffer_pool_reads/innodb_buffer_pool_read_requests) * 100
innodb 缓存使用率 innodb_buffer_usage = ( 1 – innodb_buffer_pool_pages_free / innodb_buffer_pool_pages_total) * 100
innodb buffer pool读写 innodb_buffer_pool_read_requests/ innodb_buffer_pool_write_requests
innodb 总页数当前 InnoDB 打开表的数量
MyISAM读写次数  key_read_requests/ key_write_requests
myisam 缓存命中率
myisam 缓存使用率
mysql error告警
mysql服务 严重告警
从 IO 线程状态
从 SQL 线程状态
mysql 主从延迟 (5s)
keepalived服务 状态 告警 VIP转移 告警
linux io使用率 80-90%
linux 磁盘告警 80-90%
linux 内存告警 80-90% (oom严重告警)
linux 读写比例
linux 网络流量 (Bytes_received/s：平均每秒的输入流量,Bytes_sent/s：平均每秒的输出流量)

create user 'lixl'@'%' IDENTIFIED BY 'lixl';
grant all privileges on *.* to lixl@'%' with grant option; 
FLUSH PRIVILEGES; 

slave-load-tmpdir = /data/mysql-3306/tmp

relay_log_info_repository = TABLE
relay_log_recovery = 1
relay-log = /data/mysql-3306/binlog/relay-bin
relay-log-index = /data/mysql-3306/binlog/relay-bin.index
max_relay_log_size = 1024M

#audit
#server_audit_events='QUERY_DML_NO_SELECT'
#server_audit_logging=on
#server_audit_file_path =/usr/local/mysql/data/
#server_audit_file_rotate_size=1G
#server_audit_file_rotations=4
#server_audit_file_rotate_now=ON
#server_audit_incl_users=audit,lixl

#innodb_lock_wait_timeout =
#innodb_log_files_in_group = 3
#innodb_thread_concurrency = 0
#innodb_purge_threads = 1
innodb_log_file_size=16M
innodb_undo_log_truncate=1
gtid-mode=on
enforce-gtid-consistency=true
log-slave-updates=1

#slave-------------------------------------------------
#master_info_repostitory=table
#slave_parallel_workers=16
#slave-parallel-type=LOGICAL_CLOCK
#slave_pending_jobs_size_max = 2147483648
#slave_preserve_commit_order=1
#relay_log_info_repository=TABLE
#relay_log_recovery=ON
#general_log=1
join_buffer_size=256
sort_buffer_size=2M
key_buffer_size = 384M
sort_buffer_size = 2M
open-files-limit=10000
table_open_cache = 4096
max_allowed_packet = 20M
binlog_cache_size=4M
tmp_table_size = 256M
max_heap_table_size = 256M

3月2号点检：
shsqlp30 bjh_job2作业报错，已邮件告知宋老师；
其他服务，数据库作业，AR,Zabbix,鼎甲备份，均显示正常；


./home/lixl/soft/percona-xtrabackup-2.4.21-Linux-x86_64.glibc2.12/bin/innobackupex

set @@global.gtid_purged='58e6250d-356f-11ec-982c-000c29bb216a:1-6694556,
612c68db-7da3-11ec-8daa-000c296e8b4d:7-76,
b3972d82-5c69-11eb-a08e-525400b8eba7:19184702-19361245,58e6250d-356f-11ec-982c-000c29bb216a:1-6694972';

./innobackupex --apply-log /data/mysql-3306/data/
change master to master_host='192.168.88.129',master_port=3306,master_user='repl',master_password='repl',master_auto_position=1;
select * from performance_schema.replication_applier_status_by_worker\G;

--no-create-info

export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_144
export JRE_HOME=${JAVA_HOME}/jre  
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
export PATH=${JAVA_HOME}/bin:$PATH



ShardingSphere-Proxy > 启动手册 > 使用二进制发布包


authentication:
#username: root
#password: root
 users:
   root:
     password: root
   sharding:
     password:  
     authorizedSchemas: sharding_db

props:
 max-connections-size-per-query: 1
 acceptor-size: 16#The default value is available processors count * 2.
 acceptor-size: 16#The default value is available processors count * 2.
 executor-size: 16#Infinite by default.
 proxy-frontend-flush-threshold: 128#The default value is 128.
 
 zabbix
 日常点检 1.zabbix 监控linux基本参数 cpu 内存 io等。监控mysql qps tps。主从状态。主从延迟pt。检测服务是否正常。2.鼎佳备份3.日常点检，检测服务数据库状态 并发送企业微信。一天三次。
 dynatrace
 快速定位应用系统性能故障。通过对应用系统各种组件（数据库、中间件）的监测，迅速定位系统故障，可以细化到代码级故障。
 shardingsphere
 读写分离 分库分表
 proxysql mycat replication-manager保障HA
 mha mgr架构
 
 keepalived
 VIP转移
 PXC架构
 
 xtrabackup
 备份
 pt-heartbeat
 pt工具：检测主从数据一致性、在线修改表结构、检测主从延迟、修复数据不一致问题
 
 诊断mysql参数指标
 mysql
 mssql
 pgsql
 mariadb
 redis
 mongodb
 
 ansible
 批量部署工具
 
 --删除主键
(1)如果主键id不是自动递增
Alter table ci drop primary key;--删除主建

(2)如果主键id是自动递增
Alter table ci change id id int(10);--删除自增长
Alter table ci drop primary key;--删除主建

--添加主键
(1)如果主键id不是自动递增
Alter table ci add primary key(id);

(2)如果主键id是自动递增
Alter table ci add primary key(id);
Alter table ci change id id int(10) unsigned not null auto_increment;

扩展知识：
--添加字段并设置主键
ALTER TABLE tabelname ADD new_field_id int(5) unsigned default 0 not null auto_increment ,ADD primary key (new_field_id);
--加主关键字的索引
ALTER TABLE tablename ADD primary key(id);
--加索引  
ALTER TABLE tablename CHANGE depno depno int(5) not null;
ALTER TABLE tablename ADD INDEX 索引名 (字段名1[，字段名2 …]);
ALTER TABLE tablename ADD INDEX emp_name (COLUMNS_name);
--加唯一限制条件的索引
ALTER TABLE tablename ADD UNIQUE emp_name2(cardnumber);
--删除某个索引
ALTER TABLE tablename DROP INDEX emp_name;

alter table LCCustomerReturnCall drop index IDX_POLICY_NO
 
--增加字段：
ALTER TABLE table_name ADD field_name field_type;
--删除字段
ALTER TABLE table_name DROP field_name;
--重命名列
ALTER TABLE table_name CHANGE field_name1 field_name2 integer;
--调整字段顺序 
ALTER TABLE `users` CHANGE `user_password` `user_password` varchar( 20 ) NOT NULL AFTER user_name;
--改变列的类型
ALTER TABLE table_name CHANGE field_name field_name bigint not null;
ALTER TABLE infos CHANGE list list tinyint not null default '0';
--修改原字段名称及类型：   www.2cto.com  
ALTER TABLE table_name CHANGE old_field_name new_field_name field_type;
--重命名表
ALTER TABLE table_name rename new_table_name;
--级联更新 和 删除(红色部分,不区分大小写 )
DROP TABLE IF EXISTS `mail_model`;create TABLE mail_model(id varchar(50) primary key not null ,mail_filename varchar(200),content varchar(2000))ENGINE=InnoDB DEFAULT CHARSET=gbk;
DROP TABLE IF EXISTS `mail_model_extend`;create TABLE mail_model_extend(id int(6) auto_increment not null primary key,rid varchar(50) not null,content varchar(2000),INDEX (RID),FOREIGN KEY (RID) REFERENCES mail_model(ID) ON DELETE CASCADE ON UPDATE CASCADE)ENGINE=InnoDB DEFAULT CHARSET=gbk;


[mysqld]
basedir=/data/mysql_basedir/
datadir=/data/mysql-3306/data
socket=/data/mysql-3306/mysql_sock/mysql.sock
port = 3306
symbolic-links=0
lower_case_table_names=1
[mysqld_safe]
log-error=/data/mysql-3306/log/mysqld.log
pid-file=/data/mysql-3306/data

!includedir /etc/my.cnf.d

/usr/bin/
/etc/init.d/



echo "test" | mail -s "KEEPALIVED故障进行转移" 1403687948@qq.com

docker inspect pmm-server_data
[
    {
        "CreatedAt": "2021-05-28T16:16:15+08:00",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "pmm-server",
            "com.docker.compose.version": "1.29.2",
            "com.docker.compose.volume": "data"
        },
        "Mountpoint": "/var/lib/docker/volumes/pmm-server_data/_data",
        "Name": "pmm-server_data",
        "Options": null,
        "Scope": "local"
    }
]


/root/mysqld_exporter/mysqld_exporter --web.listen-address=0.0.0.0:9104 --config.my-cnf /etc/my.cnf --collect.slave_status --collect.slave_hosts --log.level=error --collect.info_schema.processlist --collect.info_schema.innodb_metrics --collect.info_schema.innodb_tablespaces --collect.info_schema.innodb_cmp --collect.info_schema.innodb_cmpmem



firewall-cmd --zone=public --add-port=9093/tcp --permanent
firewall-cmd --reload
firewall-cmd --query-port=9093/tcp

firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.111.160" drop'

firewall-cmd --permanent --remove-rich-rule='rule family="ipv4" source address="192.168.111.160" drop'

firewall-cmd --reload

firewall-cmd --zone=public --list-all

[mysqld]
basedir=/data/mysql_basedir/
datadir=/data/mysql-3306/data/
socket=/data/mysql-3306/mysql_sock/mysql.sock
server_id=9956
log_bin=/data/mysql-3306/binlog/mysql-bin
binlog_format=row
expire_logs_days=7
max-binlog-size = 1024M
port = 3306
symbolic-links=0
lower_case_table_names=1
log_error = /data/mysql-3306/log/mysql-error.log

[mysqld_safe]
log-error = /data/mysql-3306/log/mysql-error.log
pid-file=/data/mysql-3306/data

[client]
socket=/data/mysql-3306/mysql_sock/mysql.sock

(mysql_global_variables_innodb_buffer_pool_size{instance="$host"} * 100) / on (instance) node_memory_MemTotal_bytes{instance="$host"}

--node_exporter.services
[Unit]
Description=node_exporter
[Service]
User=root
ExecStart=/root/node_exporter/node_exporter --log.level=error
ExecStop=/usr/bin/killall node_exporter
#MemoryLimit=300M#限制内存使用最多300M
#CPUQuota=100%#限制CPU使用最多一个核

[Install]
WantedBy=default.target

/usr/local/mysqld_exporter/mysqld_exporter --web.listen-address=0.0.0.0:9104 --config.my-cnf=/etc/my.cnf --collect.slave_status --collect.slave_hosts --log.level=error --collect.info_schema.processlist --collect.info_schema.innodb_metrics --collect.info_schema.innodb_tablespaces --collect.info_schema.innodb_cmp --collect.info_schema.innodb_cmpmem

--mysqld_exporter.services
[Unit]
Description=mysqld_exporter
#After=network.target
[Service]
Type=simple
User=root
#Environment=DATA_SOURCE_NAME=lixl:lixl@(localhost:3306)/
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/etc/my.cnf
Restart=on-failure
[Install]
WantedBy=default.target


/usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/etc/my.cnf



#!/bin/bash

echo -e "\033[32m *************** 环境验证-START *************** \033[0m"
#验证参数
if [ $#-ne 5 ];then
  echo -e "\033[41;37m 参数应为5个 \033[0m"
  exit 9
fi
#接收参数
FIRST=$1
SECOND=$2
FILE=$3
APP=$4
WORKSPACE=$5
#设置常量
UnzipDir="${WORKSPACE}/${APP}"
TmpPublishFile="${WORKSPACE}/tmp_publish.txt"
PublishFile="${WORKSPACE}/publish.txt"
#验证sftp发布包
if [ "${APP}" = "Midplat" ];then
        if [ "${FILE}" -eq "1" ];then
    APP_FULL_NAME="${APP}.zip"
  else
    APP_FULL_NAME="${APP}-${FILE}.zip"
  fi
  APP_PUBLISH_NAME="${APP}.zip"
else
  echo -e "\033[41;37m 参数不正确 ${FIRST} ${SECOND} ${FILE} ${APP} ${WORKSPACE} \033[0m"
  exit 9
fi
FILE_PATH="/data/sftp/midplat/${FIRST}/incr/${SECOND}/${APP_FULL_NAME}"
if [ ! -f "${FILE_PATH}" ];then
  echo -e "\033[41;37m 发布包不存在 ${FILE_PATH} \033[0m"
  exit 9
fi
echo "发布包存在 "${FILE_PATH}
echo -e "\033[32m *************** 环境验证-END *************** \033[0m"
echo -e "\033[32m *************** 解压发布包-START *************** \033[0m"
#解压sftp发布包到jenkins工作目录
unzip ${FILE_PATH} -d ${WORKSPACE} > /dev/null 2>&1
if [ ! -d "${UnzipDir}" ];then
  echo "发布包解压失败 ${FILE_PATH} ---> ${WORKSPACE}"
  exit 9
fi
echo "发布包解压成功 ${FILE_PATH} ---> ${WORKSPACE}"
echo -e "\033[32m *************** 解压发布包-END *************** \033[0m"
echo -e "\033[32m *************** 验证发布目录-START *************** \033[0m"
dir_size=$(du -s ${UnzipDir} | awk '{print $1}')
if [ "${dir_size}" -eq "0" ];then
        echo -e "\033[41;37m 目录下没有文件 ${FILE_PATH} \033[0m"
        tree -C
  exit 9
fi
echo "发布目录结构如下："
tree -C ${UnzipDir}
#将发布文件的绝对路径写入临时文件
tree -f -i ${UnzipDir} > ${TmpPublishFile}
#格式化文件
TotalLine=`cat ${TmpPublishFile} | wc -l`
sed -i $((${TotalLine}-1)),${TotalLine}d ${TmpPublishFile}
#去除文件夹
TopLine=`head -n 1 ${TmpPublishFile}`
for line in `cat ${TmpPublishFile}`
do
        if [ -f ${line} ];then
                substr=${line:$((${#TopLine}+1))}
                echo ${substr//\//\\} >> ${PublishFile}
        fi
done
#删除临时文件
rm -f ${TmpPublishFile} > /dev/null 2>&1
echo -e "\033[32m *************** 验证发布目录-END *************** \033[0m"
echo -e "\033[32m *************** 记录版本号-START *************** \033[0m"
echo "$(date "+%Y-%m-%d") $(date "+%H:%M:%S") ${APP} ${FILE_PATH}" >> $(cd `dirname $0`; pwd)/version.txt
echo -e "\033[32m *************** 记录版本号-END *************** \033[0m"
exit 0

P@ssword1f

20220329212909
20220329212941

27869164:#             '0020220329212909',
27869177:#  @1=20220329212909 /* DECIMAL(20,0) meta=5120 nullable=0 is_null=0 */
27869211:#             '0020220329212909',
27869224:#  @1=20220329212909 /* DECIMAL(20,0) meta=5120 nullable=0 is_null=0 */
27869258:#             '0020220329212909',
27869271:#  @1=20220329212909 /* DECIMAL(20,0) meta=5120 nullable=0 is_null=0 */
28530559:#  @1=20220329212909 /* DECIMAL(20,0) meta=5120 nullable=0 is_null=0 */
28530571:#  @1=20220329212909 /* DECIMAL(20,0) meta=5120 nullable=0 is_null=0 */

27880788:#             '0020220329212941',
27880801:#  @1=20220329212941 /* DECIMAL(20,0) meta=5120 nullable=0 is_null=0 */


-----交接问题相关汇总
1.SQLServer修改表结构 AR数据同步相关（新建表，新建字段带default值 ，增减同步表，数据同问题调查 等等）
2.周末清理团险日志 --操作 还有类似清理日志的服务器吗
3.MQ重放报文问题、MQ类似问题 --中间件厂商负责
4.dynatrace安装问题 --操作文档
5.智能核保数据库地址、发布
6.sqlserver备份脚本 备份疑惑 --BACKUP LOG [LifeCIRC] To disk='nul'
7.sqlserver数据迁移注意事项
8.监控告警服务器 --不清楚的服务器请教丁杰？？
9.192.168.100.117 自动清理脚本
10.企业微信管理后台 --登陆操作 添加用户显示报警
11.jenkins 发布失败--直接回滚吗
12.企业微信群 输出警告信息 --详情
13.云上数据库巡检 是否包含在zabbix上
14.ar 邮件设置  --详情问供应商

192.168.100.131_shcredit-app1 负责人
192.168.100.165_shPayDB-主 负责人 是否为我维护
192.168.100.166_shPayDB-从
192.168.100.211 mysql 负责人 是否为我维护


--架构升级
172.28.249.216
select count(*) from recr_notice;
+----------+
| count(*) |
+----------+
|    10000

select count(*) from ldcom;
+----------+
| count(*) |
+----------+
|      303 |

select count(*) from recr_user_info;
+----------+
| count(*) |
+----------+
|    16847 |
+----------+


172.28.250.82
select count(*) from outer_manage;
+----------+
| count(*) |
+----------+
|   312596 |
+----------+

172.28.250.145
SELECT table_name,table_rows FROM information_schema.tables WHERE TABLE_SCHEMA ='csactivity' ORDER BY table_rows DESC limit 3;
+-------------------+------------+
| table_name        | table_rows |
+-------------------+------------+
| attendance_record |    2887073 |
| latree            |     341760 |
| laagent           |     252840 |
+-------------------+------------+

172.28.250.156
mysql> SELECT table_name,table_rows FROM information_schema.tables WHERE TABLE_SCHEMA ='ApolloConfigDB' ORDER BY table_rows DESC limit 3;           
+----------------+------------+
| table_name     | table_rows |
+----------------+------------+
| Audit          |        665 |
| Item           |        484 |
| InstanceConfig |        117 |
+----------------+------------+
3 rows in set (0.00 sec)

mysql> SELECT table_name,table_rows FROM information_schema.tables WHERE TABLE_SCHEMA ='ApolloPortalDB' ORDER BY table_rows DESC limit 3;              
+----------------+------------+
| table_name     | table_rows |
+----------------+------------+
| RolePermission |         79 |
| Permission     |         78 |
| Role           |         71 |
+----------------+------------+
3 rows in set (0.01 sec)
Unitedplaza37

100.28
P60_NissayLis_to_P30_LifeCMSDP
P30_to_P80_LifeCMSDP

<span class="inner-text" i18n="tasks.ResetDataErrors">Reset Data Errors...</span>
<span class="inner-text" i18n="tasks.Reload">Reload...</span>

C:\ProgramFiles(x86)\IBM\WebSphere\AppServer\profiles\AppSrv01\installedApps\shybt2Node01Cell\ybt_war.ear

tp/wxzy/2022/2022-04-14/payment

按照行数截取
cat -n 172.29.249.78.log |grep '12:29:'| head -n 1
sed -n '140293031,140968214p' /root/usr/tomcat7/apache-tomcat-7.0.91/logs/catalina.out >houzhi.log



kill -9  $(ps -ef|grep pmm | awk '{ print $1}' | tail -n +2)
kill -9 $(ps -ef|grep kube | awk '{ print $2}' | tail -n +2)
kill -9 $(ps -ef|grep per | awk '{ print $2}' | tail -n +2)
kill -15 $(ps -ef|grep etcd | awk '{ print $2}' | tail -n +2)
kill -9 $(ps -ef|grep docker | awk '{ print $2}' | tail -n +2)

kill -9 $(ps -ef|grep awx | awk '{ print $2}' | tail -n +2)

! Configuration File for keepalived

global_defs {
   router_id GDS-PRO-qianyue-db2
}

vrrp_script mysqlcheck {
    script "/usr/bin/sh /data/keepalived/check/mysql_check.sh"
    interval 5
}

vrrp_instance QIANYUE_VIP {
    state BACKUP
    interface ens160
    virtual_router_id 55
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.99.55
    }
    track_script {
        mysqlcheck
    }
    notify_master "/usr/bin/sh data/keepalived/backup_status_switch.sh master"
    notify_backup "/usr/bin/sh /data/keepalived/backup_status_switch.sh backup"
    notify_fault "/usr/bin/sh /data/keepalived/backup_status_switch.sh fault"
    notify_stop "/usr/bin/sh /data/keepalived/backup_status_switch.sh stop"
}

-------------------------------------------------------------
#!/bin/bash
#截取主从同步position
#set home
WORKHOME="/data/keepalived/"
LOGFILE=${WORKHOME}"log/switch.log"

#set const
USERNAME="replic_oper"
PASSWORD="replic_oper@123"

#write log
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
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--keepalived.conf

! Configuration File for keepalived

global_defs {
    router_id GDS-PRO-qianyue-db1
}

vrrp_script mysqlcheck {
    script "/usr/bin/sh /data/keepalived/check/mysql_check.sh"
    interval 5
}

vrrp_instance QIANYUE_VIP {
    state BACKUP
    interface ens160
    virtual_router_id 55
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.99.55
    }
    track_script {
        mysqlcheck
    }
    notify_master "/usr/bin/sh /data/keepalived/master_status_switch.sh master"
    notify_backup "/usr/bin/sh /data/keepalived/master_status_switch.sh backup"
    notify_fault "/usr/bin/sh /data/keepalived/master_status_switch.sh fault"
    notify_stop "/usr/bin/sh /data/keepalived/master_status_switch.sh stop"
}

------------------------------------------------------------------------------------
 select * from sys.dm_tran_session_transactions; --查看当前运行的事务
 
#接收者邮箱，多个以空格分隔
contact=(1403687948@qq.com)
#本机ip
HOST_IP=192.168.88.129
notify() {
#邮件主题
    mailsubject="KEEPALIVED故障进行转移,$HOST_IP keepalived to be $1"
#邮件正文
    mailbody="$(date +'%F %T'): vrrp transition, $HOST_IP keepalived changed to be $1"
    for receiver in ${contact[*]}
    do
   #发送邮件
        echo ""$(date +'%F %T'): vrrp transition,192.168.88.129 keepalived changed" | mail -r 192.168.88.129 -s "KEEPALIVED故障进行转移" $receiver
    done
}
case $1 in
master)
    notify master
    ;;
backup)
    notify backup
    ;;
fault)
    notify fault
    ;;
*)
    echo "Usage:{master|backup|fault}"
    exit 1
    ;;
esac
------------------------------------------------------------------------------------------------------------------------------------------------------------------
pmm-agent setup --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml --server-address=192.168.88.129 --server-insecure-tls --server-username=admin --server-password=admin
pmm-admin config --server-insecure-tls --server-url=https://admin:admin@192.168.88.129:443
pmm-admin config --server-insecure-tls --server-url=https://admin:P@ssword12@127.0.0.1:443

启动pmm-agent
pmm-agent --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml
--向PMM-Server服务添加linux主机监控
pmm-admin config --server-insecure-tls --server-url=https://admin:admin@192.168.88.132:443


#赢时胜每月脚本
update CS_SUN set FBWB = round(FBWB,2) where fywdate >= '20220601' and fywdate < '20220701';
update cs_sun  set FT7 = '000'  where FT7 = '0000'  and fywdate >= '20220601' and fywdate < '20220701';

#sysbench压测OLTP
------------------------------------------------------------------------------------------------------------------------------------------------------------------
#准备数据
sysbench --db-driver=mysql --mysql-host=192.168.88.132 --mysql-port=3306 --mysql-user=lixl --mysql-password=lixl --mysql-db=sysbench --mysql-storage-engine=innodb --tables=5 --table-size=100000000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off prepare
------------------------------------------------------------------------------------------------------------------------------------------------------------------
sysbench --db-driver=mysql --mysql-host=192.168.88.130 --mysql-port=3306 --mysql-user=lixl --mysql-password=lixl --mysql-db=sbtest --mysql-storage-engine=innodb --tables=5 --table-size=100000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off run

sysbench --db-driver=mysql --mysql-host=192.168.97.222 --mysql-port=3306 --mysql-user=us_hammer --mysql-password=us_hammer --mysql-db=tpcc --mysql-storage-engine=innodb --tables=3 --table-size=100000000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off prepare
sysbench --db-driver=mysql --mysql-host=192.168.97.222 --mysql-port=3306 --mysql-user=us_hammer --mysql-password=us_hammer --mysql-db=tpcc --mysql-storage-engine=innodb --tables=5 --table-size=100000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off run
sysbench --db-driver=mysql --mysql-host=172.18.100.59 --mysql-port=3308 --mysql-user=us_hammer --mysql-password=us_hammer --mysql-db=T --mysql-storage-engine=innodb --tables=5 --table-size=100000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off cleanup

pt-heartbeat --user=root --ask-pass --host=172.18.100.74 --create-table -D heartbeat --interval=1 --update --replace --daemonize

pt-heartbeat -D heartbeat --table=heartbeat --monitor --host=172.18.100.74 --user=root --ask-pass --master-server-id=1007457

sysbench --db-driver=mysql --mysql-host=172.18.100.74 --mysql-port=3306 --mysql-user=us_test --mysql-password='2&Ru@bbMT' --mysql-db=test --mysql-storage-engine=innodb --tables=3 --table-size=10000000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off prepare

sysbench --db-driver=mysql --mysql-host=172.18.100.74 --mysql-port=3306 --mysql-user=us_test --mysql-password='2&Ru@bbMT' --mysql-db=test --mysql-storage-engine=innodb --tables=3 --table-size=10000000 /usr/share/sysbench/oltp_update_non_index.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off run

sysbench --db-driver=mysql --mysql-host=172.18.100.59 --mysql-port=3308 --mysql-user=us_hammer --mysql-password=us_hammer --mysql-db=T --mysql-storage-engine=innodb --tables=5 --table-size=100000 /usr/share/sysbench/oltp_point_select.lua --forced-shutdown=1  --threads=16 --events=0 --time=60000000 --report-interval=1 --percentile=99 --db-ps-mode=disable --auto_inc=1 --mysql-ignore-errors=all --skip_trx=off cleanup

4951c10a947d

172.17.0.2

show variables where variable_name in ('innodb_buffer_pool_size','innodb_log_buffer_size','innodb_additional_mem_pool_size','key_buffer_size','query_cache_size');

#mycat
 <readHost host="hostS1" url="jdbc:mysql://192.168.88.133:3306" user="lixl" password="lixl" />
 TESTDB
 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------


https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=wwc94cbe14046ce7f7&corpsecret=m7zBNoy7Heot8Kxl_5X2abWbVP715hELRI3gEtXeDLA

#!/bin/bash

CropID='wwc94cbe14046ce7f7'
Secret='m7zBNoy7Heot8Kxl_5X2abWbVP715hELRI3gEtXeDLA'
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F\" '{print $4}')

PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"

function body() {
local int AppID=1
local UserID=$1
local PartyID=2
local Msg=$(echo "$@" | cut -d" " -f3-)
printf '{\n'
printf '\t"touser": "'"$UserID"\"",\n"
printf '\t"toparty": "'"$PartyID"\"",\n"
printf '\t"msgtype": "text",\n'
printf '\t"agentid": "'" $AppID "\"",\n"
printf '\t"text": {\n'
printf '\t\t"content": "'"$Msg"\""\n"
printf '\t},\n'
printf '\t"safe":"0"\n'
printf '}\n'
}
/usr/bin/curl --data-ascii "$(body $1 $2 $3)" $PURL

------------------------------------------------------------------------------------------------------------------------------------------------------------------
#!/bin/bash
#监控mysql服务 企业微信提醒
NAME=mysql
count=$(netstat -ano | grep ":::3306" | grep "LISTEN" | wc -l)
if [ ${count} -eq 0 ];then
  echo "$(date +'%F %T'): mysql is fail,192.168.88.129" | mail -r 192.168.88.129 -s "mysql DOWN!!!" 1403687948@qq.com
  exit 9
 else
  echo "$(date +'%F %T'): mysql is running"
fi
exit 0

#!/bin/bash
count=$(netstat -ano | grep ":::3306" | grep "LISTEN" | wc -l)
 if [${count} -ne 0 ];then
  exit 9
 else
  AgentID="1000016"
  CropID="wxb6e82c5ccefc0733"
  Secret="Ddm7YI-g8yd-Pa3etoT0gubaELxRQ7B0wu6eWdiJV5A"
  GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
  Gtoken=$(/usr/bin/curl -s -G $GURL | awk -F \" '{print $10}')
  count=$(netstat -ano | grep ":::3306" | grep "LISTEN" | wc -l)
  DATE=`date +'%F %T'`
  SERVER=`/usr/sbin/ifconfig ens160 | grep 'inet' | awk '{print $2}'|head -n 1`
  body='{
   "touser": "LiXinLong",
   "toparty": "2",
   "msgtype": "text",
   "agentid": 1000016,
   "text": {
     "content": "'$DATE' '[$SERVER]' MySQL服务异常"
   },
   "safe": 0,
   "enable_id_trans": 0,
   "enable_duplicate_check": 0
   }'
   PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
   /usr/bin/curl -s --data-ascii "$body" $PURL >> monitor.log
  fi
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * * * * * /check/monitor_mysql.sh
 
 
#docker run pmm
 docker run \
--rm \
--name pmm-client \
PMM_AGENT_SERVER_ADDRESS=${PMM_SERVER} 
PMM_AGENT_SERVER_USERNAME=admin 
PMM_AGENT_SERVER_PASSWORD=admin 
PMM_AGENT_SERVER_INSECURE_TLS=1 
PMM_AGENT_SETUP=1 
PMM_AGENT_CONFIG_FILE=pmm-agent.yml 


#MSSQL
#查看存储包含的表
select distinct object_name(id) from syscomments where id in
 (select object_id from sys.objects where type ='P') and text like'%PFCASBENE%';
#查看正在运行的语句

USE master
GO
select 
    er.session_id sid
    ,blocking_session_id bsid
    ,er.percent_complete
    ,er.status
    ,er.wait_type
    ,er.last_wait_type
    ,er.wait_resource
    ,er.total_elapsed_time
    ,er.cpu_time
    ,er.reads
    ,er.writes
    ,er.logical_reads
    ,er.start_time
    ,s.login_name
    ,er.command
    ,DatabaseName = DB_NAME(er.database_id)
    -- ,user_name(er.user_id) Username
    -- ,object_name(st.objectid,st.dbid) obj_name
    ,StatementDefinition = SUBSTRING (st.text,(er.statement_start_offset / 2) + 1,
       ((CASE er.statement_end_offset
           WHEN -1 THEN DATALENGTH(st.text)
           ELSE er.statement_end_offset
           END - er.statement_start_offset) / 2) + 1)
from sys.dm_exec_requests er
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
	join sys.dm_exec_sessions s
		on er.session_id = s.session_id
	join sys.dm_exec_connections c
		on er.session_id = c.session_id


#pmm2 添加监控帐号
CREATE USER 'pmm'@'%' IDENTIFIED BY 'pass' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'%';

#nginx
nginx1.20安装

tar -zxvf nginx-1.20.1.tar.gz

./configure --prefix=/data/nginx --with-http_ssl_module
make
make install

vim /usr/lib/systemd/system/nginx.service
nginx.service
[Unit]
SourcePath=/data/nginx/sbin/nginx
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/data/nginx/sbin/nginx
ExecStop=/data/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target

systemctl enable nginx
systemctl is-enabled nginx.service
vim ../conf/nginx.conf
nginx -s reload

#if ($request_method ~* PUT|OPTIONS|TRACE){
#         return 403;
#       }
#


#start.sh stop.sh
ps -ef|grep pmm-agent|grep -v grep|grep -v kill|awk '{print $2}'
	
	
kill -15 $(ps -ef|grep pmm-agent|grep -v grep|grep -v kill|awk '{print $2}')
	
	
	
#!/bin/sh
APP_NAME=pmm-agent
tpid1=`ps -ef|grep $APP_NAME|grep -v grep|grep -v kill|awk '{print $2}'`
echo tpid1-$tpid1
    if [[ $tpid1 ]]; then
    echo 'Stop Process...'
    kill -15 $tpid1
fi
sleep 5
tpid2=`ps -ef|grep $APP_NAME|grep -v grep|grep -v kill|awk '{print $2}'`
    echo tpid2-$tpid2
if [[ $tpid2 ]]; then
    echo 'Kill Process!'
    kill -9 $tpid2
else
    echo 'Stop Success!'
fi



#!/bin/sh
APP_NAME=/usr/local/percona/pmm2/bin/pmm-agent
echo Starting application 
#rm -f tpid
source /etc/profile
nohup $APP_NAME --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml >/dev/null 2>&1 &
#echo $! > tpid
echo $!


pmm-admin add mysql --username pmm --password pass mysql-192.168.88.129 192.168.88.129:3306


firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
firewall-cmd --query-port=9090/tcp

#PG14安装

-- 下载源码包 
wget https://ftp.postgresql.org/pub/source/v14.2/data/data/postgresql-14.2.tar.gz --no-check-certificate 
wget https://ftp.postgresql.org/pub/source/v13.3/data/data/postgresql-13.3.tar.gz 
wget https://ftp.postgresql.org/pub/source/v12.7/data/data/postgresql-12.7.tar.gz 
wget https://ftp.postgresql.org/pub/source/v11.12/data/data/postgresql-11.12.tar.gz 
wget https://ftp.postgresql.org/pub/source/v10.17/data/data/postgresql-10.17.tar.gz 
wget https://ftp.postgresql.org/pub/source/v9.6.22/data/data/postgresql-9.6.22.tar.gz 
wget https://ftp.postgresql.org/pub/source/v9.4.26/data/data/postgresql-9.4.26.tar.gz 

-- 一些依赖包 
yum install -y cmake make gcc zlib zlib-devel gcc-c++ perl readline readline-devel  tcl openssl ncurses-devel openldap pam flex 

-- 创建用户 
useradd postgres echo "postgres" | passwd --stdin postgres 

-- 创建目录 
mkdir -p /data/postgres/{pgdata,archive,scripts,backup,pg14,soft} 
chown -R postgres:postgres /data/postgres && chmod -R 775 /data/postgres 

-- 编译
 su - pgsql 
 cd /data/postgres/soft tar zxvf postgresql-14.6.tar.gz cd postgresql-14.6
 ./configure --prefix=/data/postgres/postgres 
 make -j 4 && make install 
#编译完成，最后一行显示：All of PostgreSQL successfully made. Ready to install. 
 -- 如果你希望编译所有能编译的东西，包括文档（HTML和手册页）以及附加模块（contrib），这样键入： 
 make world -j 16 && make install-world 
#最后一行显示：PostgreSQL, contrib, and documentation successfully made. Ready to install. 
 -- 源码安装postgresql时，而make时又没有make world，就会导致的pg最终没有类似pg_stat_statements的扩展功能 
 
 -- 配置环境变量 
 cat >> ~/.bash_profile <<"EOF"
 export PGPORT=5432 
 export PGDATA=/data/postgres/pgdata 
 export PGHOME=/data/postgres/postgres 
 export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH 
 export PATH=$PGHOME/bin:$PATH:. 
 export PGHOST=$PGDATA 
 export PGUSER=postgres 
 export PGDATABASE=postgres EOF 
 source ~/.bash_profile 
 
 -- 初始化 
 su - postgres 
 /data/postgres/postgres/bin/initdb -D /data/postgres/pgdata -E UTF8 --locale=en_US.utf8 -U postgres 
 
 -- 修改参数 
 cat >> /data/postgres/pgdata/postgresql.conf <<"EOF" 
 listen_addresses = '*' port=5432 
 unix_socket_directories='/data/postgresql/pgdata' 
 logging_collector = on log_directory = 'pg_log' 
 log_filename = 'postgresql-%a.log' 
 log_truncate_on_rotation = on EOF cat > /data/postgresql/pgdata/pg_hba.conf << EOF 
#TYPE DATABASE USER ADDRESS METHOD host all all 0.0.0.0/0 md5 EOF 
 -- 启动 su - pgsql pg_ctl start pg_ctl status pg_ctl stop 
 -- 配置系统服务 cat > /etc/systemd/system/PG14.service <<"EOF" [Unit] Description=PostgreSQL database server Documentation=man:postgres(1) After=network.target [Service] Type=forking User=pgsql Group=pgsql Environment=PGPORT=5433 Environment=PGDATA=/data/postgresql/pgdata OOMScoreAdjust=-1000 ExecStart=/data/postgresql/pg14/bin/pg_ctl start -D ${PGDATA} -s -o "-p ${PGPORT}" -w -t 300 ExecStop=/data/postgresql/pg14/bin/pg_ctl stop -D ${PGDATA} -s -m fast ExecReload=/data/postgresql/pg14/bin/pg_ctl reload -D ${PGDATA} -s KillMode=mixed KillSignal=SIGINT TimeoutSec=0 [Install] WantedBy=multi-user.target EOF systemctl daemon-reload systemctl enable PG14 systemctl start PG14 systemctl status PG14 su - pgsql psql \password postgres or: alter user postgres with password 'lhr'; -- 安装插件 create extension pageinspect; create extension pg_stat_statements; select * from pg_extension ; select * from pg_available_extensions order by name;

cat >> /data/postgresql/pgdata/postgresql.conf <<"EOF" 
listen_addresses = '*' port=5432 
unix_socket_directories='/data/postgresql/pgdata' 
logging_collector = on log_directory = 'pg_log' 
log_filename = 'postgresql-%a.log' 
log_truncate_on_rotation = on 
EOF

cat > /data/postgresql/pgdata/pg_hba.conf << EOF 
#TYPE DATABASE USER ADDRESS METHOD host all all 0.0.0.0/0 md5 
EOF


stdprm
192.168.100.28：
AS400_to_P20_LifeMir20210913
AS400_to_P30_LifeMir20191223
192.168.100.32：
AS400-100_216_LifeMir
AS400-99_11_LifeMir
AS400_to_100_98_LifeMir
AS400_to_100_99_LifeMir

C:\Program Files(x86)\IBM\WebSphere\AppServer\profiles\AppSrv01\temp\shgapppreNode01\server1\CSGCS_war\CSGCS.war


\IBM\WebSphere\AppServer\profiles\AppSrv01\temp\shgapppre1Node01\server1\CSGCS_war\CSGCS.war

{xor}CiwAOC0wKi8bHQ==

${MICROSOFT_JDBC_DRIVER_PATH}/sqljdbc4.jar

   
--mycat2
   /*+ mycat:createDataSource{
"name":"master",
"instanceType":"WRITE",
"url":"jdbc:mysql://192.168.88.129:3306",
"user":"lixl",
"password":"lixl"
} */;

/*+ mycat:createDataSource{
"name":"slave",
"instanceType":"READ",
"url":"jdbc:mysql://192.168.88.133:3306",
"user":"lixl",
"password":"lixl"
} */;

/*! mycat:createCluster{
"name":"prototype",
"masters":"master",
"replicas":["slave"],
"readBalanceType":"BALANCE_ALL_READ",
"readBalanceName":"BalanceLeastActive"
} */;

/*+ mycat:createSchema{
  "customTables":{},
  "globalTables":{},
  "normalTables":{},
  "schemaName":"area",
  "shardingTables":{},
  "targetName":"prototype"
} */;


数据库：P20，LifeExt
SQL：update PUB_T_PLAN_INFO1 set EXT_EVOICE_FEILD1='FH',DOUBLE_MAIN_FIELD='FH' where PLANTYPE = 'BJ';
影响条数：12条。

回滚SQL：update PUB_T_PLAN_INFO1 set EXT_EVOICE_FEILD1='CTX',DOUBLE_MAIN_FIELD='CTX' where PLANTYPE = 'BJ';

global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 30s
  repeat_interval: 5m
  receiver: 'wxwork'
  routes:
  - receiver: 'collect'
    repeat_interval: 5m
    match_re:
      alertname: mssql_active_transactions|MySQL_threads_running_High|win_cpu_usage
    continue: true
  - receiver: 'wxwork'
    repeat_interval: 12h
    match_re:
      alertname: mssql_db_log_size
    continue: false
  - receiver: 'wxwork'
    repeat_interval: 10m
    continue: true
receivers:
- name: 'wxwork'
  webhook_configs:
  - url: 'http://192.168.100.222:10086/wxwork'
- name: 'mail'
  webhook_configs:
  - url: 'http://192.168.100.222:10086/mail'
- name: 'collect'
  webhook_configs:
  - url: 'http://192.168.100.222:10086/collect'
    send_resolved: false
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'instance']
#





select hostgroup,username,digest_text from stats_mysql_query_digest;
select hostgroup_id,hostname,port,status,weight from mysql_servers; 
select * from mysql_replication_hostgroups;
select * from mysql_server_read_only_log;
select * from mysql_server_ping_log

SELECT URID,CORPACCESSSYSTEMSID,APPORGID,ACCOUNTNUMBER,ACCOUNTNAME,ACCOUNTTYPE,CVV2,
EXPIREDDATE,CERTTYPE,CERTNUMBER,CELLPHONE,ISPRIVATE,ISBATCH,a.SIGNBANK,BANKID,ASKNUMBER,
SRCSERIALNO,TOKEN,SIGNSTATE,SIGNINFO,SIGNNO,LGLREPNM,LGLREPIDTP,LGLREPIDNO,DISABLEDATE,SINGLELIMIT,LIMITPERIODUNIT,
MAXCNTLIMIT,LASTMODIFIEDON,CREATEDON,ROWVERSION,NOTIFYSTATE1,NOTIFYSTATE2,NOTIFYINFO1,NOTIFYINFO2,REQRESERVED1,
REQRESERVED2,MERCHANT,SIGNCODE,SIGNMODE,SOURCENOTECODE,POLICYNO,NOTEMONEY,NOTIFYURL,SIGNCONFIRM,INSUREID,
INSURENAME,SIGNSENTDATE,SIGNMADEDATE,BATCHSEQ,CANCELSENDDATE,CANCELMADEDATE,EFFECTIVEDATE,DAYAMTLIMIT,
TOTALAMTLIMIT,MONTHAMTLIMIT FROM (SELECT signbank FROM t_signinfos WHERE  signbank != 'CEB11') a JOIN t_signinfos 
WHERE signconfirm BETWEEN 3 AND 6 AND signstate !='4'  and createdon >= now()
;

--查看是否事务锁SQL

SELECT r.trx_wait_started AS wait_started,
TIMEDIFF(NOW(), r.trx_wait_started) AS wait_age ,
TIMESTAMPDIFF(SECOND,r.trx_wait_started, NOW()) AS wait_age_secs,
rl.lock_table AS locked_table ,
rl.lock_index AS cked_index ,
rl.lock_type AS locked_type,
r.trx_id AS waiting_trx_id,
r.trx_started as waiting_trx_started,
TIMEDIFF(NOW(),r.trx_started) AS waiting_trx_age ,
r.trx_rows_locked AS waiting_trx_rows_locked,
r.trx_rows_modified AS waiting_trx_rows_modified,
r.trx_mysql_thread_id AS waiting_pid,
sys.format_statement(r.trx_query) AS waiting_query ,
rl.lock_id AS waiting_lock_id,
rl.lock_mode AS waiting_lock_mode ,
b.trx_id AS blocking_trx_id,
b.trx_mysql_thread_id AS blocking_pid,
sys.format_statement(b.trx_query) AS blocking_query,
bl.lock_id AS blocking_lock_id,
bl.lock_mode AS blocking_lock_mode ,
b.trx_started AS blocking_trx_started,
TIMEDIFF(NOW() , b.trx_started) AS blocking_trx_age,
b.trx_rows_locked AS blocking_trx_rows_locked,
b.trx_rows_modified AS blocking_trx_rows_modified,
CONCAT ('KILL QUERY ', b.trx_mysql_thread_id) AS sql_kill_blocking_query, 
CONCAT ('KILL', b.trx_mysql_thread_id) AS sql_kill_bl_cking_nnection
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id
INNER JOIN information_schema.innodb_locks bl ON bl.lock_id = blocking_lock_id
INNER JOIN information_schema.innodb_locks rl ON rl.lock_id = w.requested_lock_id
ORDER BY r.trx_wait_started;

--查看是否有MDL锁SQL

SELECT g.object_schema AS object_schema,
      g.object_name AS object_name,
      pt.thread_id AS waiting_thread_id,
      pt.processlist_id AS waiting_pid,
      sys.ps_thread_account(p.owner_thread_id)AS waiting_account,
      p.lock_type AS waiting_lock_type,
      p.lock_duration AS waiting_lock_duration,
      sys.format_statement(pt.processlist_info)AS waiting_query,
      pt.processlist_time AS waiting_query_secs,
      ps.rows_affected AS waiting_query_rows_affected,
      ps.rows_examined AS waiting_query_rows_examined,
      gt.thread_id AS blocking_thread_id,
      gt.processlist_id AS blocking_pid,
      sys.ps_thread_account(g.owner_thread_id)AS blocking_account,
      g.lock_type AS blocking_lock_type,
      g.lock_duration AS blocking_lock_duration,
      CONCAT('KILL QUERY ', gt.processlist_id)AS sql_kill_blocking_query,
      CONCAT('KILL ', gt.processlist_id)AS sql_kill_blocking_connection
  FROM performance_schema.metadata_locks g
INNER JOIN performance_schema.metadata_locks p
    ON g.object_type = p.object_type
  AND g.object_schema = p.object_schema
  AND g.object_name = p.object_name
  AND g.lock_status = 'GRANTED'
  AND p.lock_status = 'PENDING'
INNER JOIN performance_schema.threads gt ON g.owner_thread_id = gt.thread_id
INNER JOIN performance_schema.threads pt ON p.owner_thread_id = pt.thread_id
  LEFT JOIN performance_schema.events_statements_current gs ON g.owner_thread_id =gs.thread_id
  LEFT JOIN performance_schema.events_statements_current ps ON p.owner_thread_id =ps.thread_id
WHERE g.object_type = 'TABLE';​​

netsh advfirewall firewall add rule name="Win-RM-HTTP" dir=in localport=5985 protocol=TCP action=allow


停止所有的容器
docker stop $(docker ps -aq)
删除所有的容器
docker rm $(docker ps -aq)
删除所有的镜像
docker rmi $(docker images -q)



Consolas, 'Courier New', monospace#vscode 默认字体

#sh 查看binlog事务大小脚本
[root@postgre binlog]#../../mysql_basedir_3306/bin/mysqlbinlog mysql-bin.000014 |grep "GTID$(printf '\t')last_committed" -B 1 \
|grep -E '^#at' \
|awk '{print $3}' \
|awk 'NR==1 {tmp=$1} NR>1 {print ($1-tmp);tmp=$1}' \
|sort -n -r |head -n 10
1029601
1029601
1029601
1029601
1029601
1029601
1029601
1029601
1029601
1029601
这里用到了 grep 两个技巧：
1. 过滤 tab 字符，用到了 "$(printf '\t')" 来插入 tab 字符，无法直接使用 "\t" 字符。
2. 使用 -B 参数向前找到了匹配的前一行，输出 "at xxx"，这一行是 GTID_event 在 binlog 中的位置
（单位是字节）。


#解决鼎甲原生xtrabackup版本兼容问题所产生依赖问题
 440  tar xf percona-xtrabackup-8.0.28-21-Linux-x86_64.glibc2.17.tar.gz
  441  cd percona-xtrabackup-8.0.28-21-Linux-x86_64.glibc2.17/
  442  ll
  443  cd bin/
  444  ll
  445  ./xtrabackup --help
  446  cd /opt/
  447  ll
  448  cd scutech/dbackup3/bin/
  449  ll
  450  ./xtrabackup-8.0 --help
  451  ./xbstream --version
  452  pwd
  453  /opt/scutech/dbackup3/bin/xbstream --version
  454  /opt/scutech/dbackup3/bin/xbstream --help
  455  /opt/percona-xtrabackup-8.0.28-21-Linux-x86_64.glibc2.17/bin/xbstream --version
  456  cd /opt/scutech/dbackup3/bin/
  457  ll
  458  rm -rf xbstream
  459  ll
  460  mv xtrabackup-8.0 xtrabackup-8.0_bak
  461  ll /opt/percona-xtrabackup-8.0.28-21-Linux-x86_64.glibc2.17/bin/
  462  mv /opt/percona-xtrabackup-8.0.28-21-Linux-x86_64.glibc2.17/bin/xtrabackup /opt/scutech/bin
  463  ll
  464  pwd
  465  mv /opt/percona-xtrabackup-8.0.28-21-Linux-x86_64.glibc2.17/bin/xtrabackup /opt/scutech/dbackup3/bin/
  466  ll /opt/scutech/
  467  mv /opt/scutech/bin /opt/scutech/dbackup3/bin/xtrabackup-8.0
  468  ll
  469  ln -s xbstream /opt/scutech/dbackup3/bin/xtrabackup-8.0
  470  ln -s /opt/scutech/dbackup3/bin/xtrabackup-8.0 xbstream
  471  ll
  472  ./xbstream
  473  ./xbstream --version
  474  cd /usr/lib64
  475  ln -s libgcrypt.so.11.8.2 libgcrypt.so
  476  ln -s libprocps.so.4.0.0 libprocps.so
  477  ./xbstream --version
  478  /opt/scutech/dbackup3/bin/xbstream --version
  479  ll /usr/lib64/libssl*
  480  find / name 'libprotobuf'
  481  find / name 'libprotobuf*'
  482  /opt/scutech/dbackup3/bin/xbstream --version
  483  find / name 'libprotobuf-lite.so.3.11.4'
  484  find / name "libprotobuf-lite.so.3.11.4"
  485  ;;
  486  ll
  487  /opt/scutech/dbackup3/bin/xbstream --version
  488  vim /data/mariadb/mycnf/
  489  vim /data/mariadb/mycnf/my.cnf
  490  vim /data/mysql8/mycnf/my.cnf
  491  systemctl restart mysql8
  492  systemctl restart mariadb.service
  493  top
  494  ll
  495  /opt/scutech/dbackup3/bin/xbstream --version
  496  ln -s libssl.so.1.0.2k libssl.so
  497  ln -s libcrypto.so.1.0.2k libcrypto.so
  498  /opt/scutech/dbackup3/bin/xbstream --version
  499  ll /usr/local/mysql8_basedir/lib/
  500  yum -y install autoconf automake libtool curl make g++ unzip
  501  cd /opt/scutech/dbackup3/bin/
  502  ll
  503  ./xtrabackup-8.0_bak --version
  504  rm -rf xbstream
  505  ./xtrabackup-8.0 --version
  506  ln -s xtrabackup-8.0 xbstream
  507  ll
  508  ./xbstream --version
  509  rm -rf xbstream
  510  ln -s xtrabackup-8.0 xbstream
  511  ./xbstream --version
  512  cd /usr/lib64/
  513  ln -s libprotobuf-lite.so.3.19.4 libprotobuf-lite.so.3.11.4
  514  ll libpro*
  515  /opt/scutech/dbackup3/bin/xbstream --version


#navicat sql保存目录
C:\Users\itwb_lixl\Documents\Navicat\MySQL\servers


#查看磁盘实用百分比
df -h /dev/sda1 | sed -n '/% \//p' | gawk '{ print $5 }'
#查看僵尸进程
ps -al | gawk '{print $2,$4}' | grep Z
#查看内存使用百分比
free | sed -n '2p' | gawk 'x = int(( $3 / $2 ) * 100) {print x}' | sed 's/$/%/'
#uptime获取在线用户数
uptime | sed 's/user.*$//' | gawk '{print $NF}'


#pmm
INFO[2023-06-16T10:14:50.836+08:00] 2023-06-16T02:14:50.836Z    warn    VictoriaMetrics/lib/promscrape/scrapework.go:377        cannot scrape target "http://127.0.0.1:42000/metrics?collect%5B%5D=custom_query.mr" ({agent_id="/agent_id/28a3a7b3-9f9f-4bb5-9d3c-176886a81d69",agent_type="postgres_exporter",instance="/agent_id/28a3a7b3-9f9f-4bb5-9d3c-176886a81d69",job="postgres_exporter_agent_id_28a3a7b3-9f9f-4bb5-9d3c-176886a81d69_mr",machine_id="/machine_id/93e6db90b4434ca88794808002b4cc48",node_id="/node_id/38a986ab-35d8-4e9b-8249-90c1560893d7",node_name="postgre",node_type="generic",service_id="/service_id/80c6ef90-7b68-402d-a37b-8436495493fd",service_name="postgresql_192.168.97.222",service_type="postgresql"}) 1 out of 1 times during -promscrape.suppressScrapeErrorsDelay=0s; the last error: cannot read data: cannot scrape "http://127.0.0.1:42000/metrics?collect%5B%5D=custom_query.mr": Get "http://127.0.0.1:42000/metrics?collect%5B%5D=custom_query.mr": EOF  agentID=/agent_id/4449bfa5-3705-4f72-a22e-744d69431208 component=agent-process type=vm_agent
INFO[2023-06-16T10:14:50.836+08:00] 2023-06-16T02:14:50.836Z    warn    VictoriaMetrics/lib/promscrape/scrapework.go:377        cannot scrape target "http://127.0.0.1:42000/metrics?collect%5B%5D=custom_query.hr&collect%5B%5D=exporter&collect%5B%5D=standard.go&collect%5B%5D=standard.process" ({agent_id="/agent_id/28a3a7b3-9f9f-4bb5-9d3c-176886a81d69",agent_type="postgres_exporter",instance="/agent_id/28a3a7b3-9f9f-4bb5-9d3c-176886a81d69",job="postgres_exporter_agent_id_28a3a7b3-9f9f-4bb5-9d3c-176886a81d69_hr",machine_id="/machine_id/93e6db90b4434ca88794808002b4cc48",node_id="/node_id/38a986ab-35d8-4e9b-8249-90c1560893d7",node_name="postgre",node_type="generic",service_id="/service_id/80c6ef90-7b68-402d-a37b-8436495493fd",service_name="postgresql_192.168.97.222",service_type="postgresql"}) 1 out of 1 times during -promscrape.suppressScrapeErrorsDelay=0s; the last error: cannot read data: cannot scrape "http://127.0.0.1:42000/metrics?collect%5B%5D=custom_query.hr&collect%5B%5D=exporter&collect%5B%5D=standard.go&collect%5B%5D=standard.process": Get "http://127.0.0.1:42000/metrics?collect%5B%5D=custom_query.hr&collect%5B%5D=exporter&collect%5B%5D=standard.go&collect%5B%5D=standard.process": EOF  agentID=/agent_id/4449bfa5-3705-4f72-a22e-744d69431208 component=agent-process type=vm_agent

#
#tshark 简单使用
#
-c, 50 抓包数量
-w, /tmp/97.222.pcap 输出文件
-T, fields，可以指定需要输出的字段，需配合-e一起使用，此处将分别打印获取包的时间、主机IP及TCP的标志位，这些字段会按照-e的顺序进行排列展示
-e，支持多种协议下的字段展示，具体用法查询路径：Wireshark -> 分析 -> 显示过滤器表达式
-i，默认会选择第一个非 loopback 的网络接口（可简写为 lo），效果与指定 -i eth0 相同
-f，指定捕获过滤器的表达式，可指定需要捕获的内容，如：协议、端口、主机IP等
通过指定 MySQL 协议解析模块，此处捕获到了 MySQL 从实例在启动复制时会执行的 SQL 语句
#如已用 -d 选项指定了协议、端口等信息时，可省略 -f（抓包过滤器表达式），除非还有其他的过滤需求，但不建议省略 -Y（显示过滤器表达式），否则会输出非常多的信息，以下两种写法是等效的：
tshark -i ens160 -f 'tcp port 3306' -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.host -e mysql.query
tshark -i ens160 -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.host -e mysql.query
#抓包
tshark -i ens33 -f 'tcp port 3306 and host 192.168.97.222'

#MySQL
tshark -i ens33 -f 'tcp port 3306 and host 192.168.97.222' /*三次握手*/ 
tshark -i ens33 -f 'tcp port 3306' -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.src -e ip.dst -e mysql.query  /*抓SQL语句*/ 
tshark -i ens33 -f 'tcp port 3306' -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.src -e ip.dst -e mysql.query
tshark -i ens33 -d tcp.port==3306,mysql -f "host 192.168.97.222 and tcp port 3306" -T fields -e frame.time -e ip.host -e tcp.flags /*十进制*/
tshark -i ens33 -d tcp.port==3306,mysql -Y 'mysql.query contains "SHOW"' -T fields -e ip.host -e mysql.query -e frame.time /*SQL语句基础上进行模糊过滤*/ 

#postgres
tshark -i ens33 -f 'tcp port 5432 and host 192.168.97.222'
tshark -i ens33 -f 'tcp port 5432' -Y "pgsql.query" -d tcp.port==5432,pgsql -T fields -e frame.time -e ip.src -e ip.dst -e pgsql.query
tshark -i ens33 -d tcp.port==5432,pgsql -f "host 192.168.97.222 and tcp port 5432" -T fields -e frame.time -e ip.host -e tcp.flags
tshark -i ens33 -d tcp.port==5432,pgsql -Y 'pgsql.query contains "delete"' -T fields -e ip.host -e pgsql.query -e frame.time


#proxysql
INSERT INTO mysql_servers(hostgroup_id,hostname,port) VALUES (1,'172.18.100.194',3306);
INSERT INTO mysql_servers(hostgroup_id,hostname,port) VALUES (1,'172.18.100.74',3306);

#master monitor
mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'monitor'@'172.18.100.%' IDENTIFIED BY 'monitor';"

SET mysql-monitor_username='monitor';
SET mysql-monitor_password='monitor';
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
select * from mysql_server_connect_log;
select * from mysql_server_ping_log;
INSERT INTO mysql_replication_hostgroups VALUES(1,2,"test");
SELECT * FROM mysql_replication_hostgroups;
LOAD MYSQL SERVERS TO RUNTIME;
SELECT * FROM mysql_servers;
SAVE MYSQL SERVERS TO DISK;

#MHA master crash
第一步：检查配置
binlog server
 1.检查ssh连通性
 2.获取node版本 get_node_version --apply_diff_relay_logs --version
 3.拿到版本号可达binlog server 否则不可达
	1.检查mha版本信息
		result1:没有安装mha
		result2::node version 版本号必须等于或者高于0.54
		检查每个实例是否可以连接
		每个节点的死活状态
		查看slave_io_running 是否为yes 不然则启动sql thread

第二步：关闭当前crash io线程、并执行脚本切换VIP
判断ssh是否可达
 停止所有slave 复制io线程
 执行配置文件中的master_ip_failover_script/shutdown_script 若没有则不执行
 如果设置了VIP，则首先切换VIP
 如果设置了shutdown脚本，则执行shutdown脚本

第三步：新主恢复
获取新的主从信息
 获取各个slave的binlog file 和 position 点
 执行 show slave status 获取从库信息 --其中重要信息参数
 $target->{Relay_Master_Log_File} = $status{Relay_Master_Log_File};
 $target->{Exec_Master_Log_Pos} = $status{Exec_Master_Log_Pos};
 $target->{Relay_Log_File} = $status{Relay_Log_File};
 $target->{Relay_Log_Pos} = $status{Relay_Log_Pos};
  比较各个slave 中的 master_log_file 和 read_master_logs_pos，寻找laster的 slave
  比较各个slave 中的 master_log_file 和 read_master_logs_pos，寻找oldest的 slave
   if ( !$_server_manager->is_gtid_auto_pos_enabled() ) {..
    进行binlog补充
	判断dead msater 是否可以ssh连接
	 如果dead msater 可以ssh连接
	 使用node节点的save_binary_logs脚本在dead master做拷贝
	 拷贝binlog文件到manage节点的manager_workdir目录下 ，如果dead master无法ssh登录，则master上未同步到slave的txn丢失
	确定新主
	 寻找最新的有所有中继日志的slave，用于恢复其他slave
	#my $latest_base_slave = find_latest_base_slave_internal();
	#my $oldest_mlf = $oldest_slave->{Master_Log_File};
	#my $oldest_mlp = $oldest_slave->{Read_Master_Log_Pos};
	#my $latest_mlf = $latest_slaves[0]->{Master_Log_File};
	#my $latest_mlp = $latest_slaves[0]->{Read_Master_Log_Pos};
	 ..
	  判断latest和oldest slave 上的binlog位置是不是相同、相同就不需要同步relay log
	  查看laster slave中是否有oldest缺少的relay log、若无则继续，否则failover失败
	  查找的方法：逆序的读laster slave的relay log文件、一直找到binlog file的position为止
	  选出新的master节点
	  比较master_log_file:read_master_log_pos
	  识别优先从库、在线的并带有candidate_master标记
	  识别应该忽略的从库，带有no_master标记、或者未开启log_bin 、与最新从库想必数据延迟比较大 --slave 与 master的binlog position差距大于100000000
	  选择优先级依次为：优先列表、最新从库列表、所有从库列表、但一定排除忽略列表
	  检查新老主库的复制过滤是否一致
    恢复从库 类似单独灰度主库过程
	中继补偿（生成slave与new slave之间的差异日志，将该日志拷贝到各个slave的工作目录下）指向新主库&启动复制（change_master_and_start_slave)清理新主库的slave复制通道 reset slave all
	 
MHA 选主逻辑：
1. 选举优先级最高的 slave 作为新主（通常是手工切换指定的new master），如果该slave 不能作为新主，则报错退出，否则如果是故障切换，则进行下面的步骤
2. 选择复制位点最新并且在设置了 candidate_master 的 slave 作为新主，如果复制位点最新的 slave 没有设置 candidate_master ，则继续下面步骤
3. 从设置了 candidate_master 中选择一个 slave 作为新主，如果没有选出则继续
4. 选择复制位点最新的 slave 作为新主，如果没有选出则继续
5. 从所有的 slave 中进行选择
6. 经过以上步骤仍然选择不出主则选举失败
注意：前面的 6 个选举步骤，都需要保证新主不在 bad 数组中

MHA，全称Master High Availability，是一款开源的MySQL高可用性解决方案。它的主要功能是在主节点故障时自动进行故障转移，以保证数据的高可用性和系统的连续性。本文将详细解析MHA的工作原理和使用方法。

1. MHA的工作原理可以概括为以下几点：
2. 监控：MHA持续监控MySQL主从复制的状态，以便及时发现和处理故障。
3. 故障检测：当MHA检测到主节点故障时，它会启动故障转移过程。
4. 选主：MHA会选择一个从节点作为新的主节点，这个节点拥有最新的数据。
5. 数据同步：MHA会将其他从节点的数据同步到新的主节点，确保数据一致性。
6. 切换：MHA会将所有对主节点的请求重定向到新的主节点，完成故障转移。
	 
#mgr
#引导
SET GLOBAL group_replication_bootstrap_group=ON;
#注册节点信任ip
set global group_replication_ip_allowlist="17.16.10.129,17.16.10.130,17.16.10.131";
#开始组复制
START GROUP_REPLICATION;
#引导关闭、其他节点注册节点开启组复制即可
SET GLOBAL group_replication_bootstrap_group=OFF;
SELECT * FROM performance_schema.replication_group_members;
STOP GROUP_REPLICATION;

索引
双写原理
SQL执行过程
MVCC
MySQL三大特性
MySQL主从复制
MySQL复制的进化和分库分表涉
redo undo
事务隔离级别
备份原理
锁
MySQL体系结构

insert into mysql_servers(hostgroup_id,hostname,port,weight,max_connections,max_replication_lag,comment) values (10,'17.16.10.129',3306,1,3000,10,'mgr_node1');
insert into mysql_servers(hostgroup_id,hostname,port,weight,max_connections,max_replication_lag,comment) values (10,'17.16.10.130',3306,1,3000,10,'mgr_node2');
insert into mysql_servers(hostgroup_id,hostname,port,weight,max_connections,max_replication_lag,comment) values (10,'17.16.10.131',3306,1,3000,10,'mgr_node3');
LOAD mysql users TO RUNTIME;
SAVE mysql servers TO DISK;

set mysql-monitor_username='monitor';
set mysql-monitor_password='monitor';
LOAD mysql variables TO RUNTIME;
SAVE mysql variables TO DISK;

insert into mysql_users(username,password,active,default_hostgroup,transaction_persistent)values('proxysql','proxysql',1,10,1);
insert into mysql_users(username,password,default_hostgroup,transaction_persistent) values('root','Zh_000000',10,1);

proxysql节点状态查询
select hostgroup_id,hostname,port,status,max_replication_lag from runtime_mysql_servers;


sysbench /usr/share/sysbench/oltp_common.lua --mysql-host=172.18.100.59 --mysql-port=3308 --mysql-user=us_hammer --mysql-password='2&Ru@bbMT' --mysql-db=hammer --tables=10 --table-size=1000000 --db-driver=mysql --report-interval=1 prepare
sysbench --threads=50 /usr/share/sysbench/oltp_read_write.lua --table-size=1000000 --tables=10 --point_selects=2  --index_updates=2 --non_index_updates=1 --delete_inserts=1 --report-interval=1 --mysql-host=172.18.100.59 --mysql-port=3308 --mysql-user=us_hammer --mysql-password='2&Ru@bbMT' --mysql-db=hammer --time=120  run

前台用户管理 
commPlatform-admin.jar
172.28.250.92
172.28.250.135



前台用户
userauth.jar
172.28.250.236
172.28.250.104

展业app
gwcslifeApp.jar
172.28.249.180
172.28.249.213


172.28.240.137
172.28.240.224


#加密 可逆 PostgreSQL14
select encrypt('Q','PostgreSQL_NB','aes')
不可逆 crypt('Qwerty1!', gen_salt('md5'))
#解密
select convert_from(decrypt('\x7da7ddc71a5dece9c31259f1fce1de3b','PostgreSQL_NB272','aes'),'SQL_ASCII');

#iptables 白名单配置
#systemctl status iptables 运行状态 MySQL端口不可访问 本地通
#开放端口 开放某个ip访问MySQL端口 重启iptables 失效
iptables -I INPUT -s 192.168.97.91 -p TCP --dport 3306 -j ACCEPT
#永久生效 service iptables save 重启iptables /etc/sysconfig/iptables文件可查看对应规则
#开放某个端口
iptables -I INPUT -p tcp --dport 8090 -j ACCEPT
#关闭所有的8090端口
iptables -I INPUT -p tcp --dport 8090 -j DROP
iptables -I INPUT -s 192.168.97.91 -p tcp --dport 8090 -j ACCEPT


20.205.243.166 github.com
185.199.108.153 assets-cdn.github.com
151.101.77.194 github.global.ssl.fastly.net

git init
git add .
git status
git config --global user.name "lixinl0ng"
git config --global user.email "postgre@126.com"
git commit -m "注释"
git remote add origin git@github.com:lixinl0ng/bcp-mssql.git



2023-08-28 15:12:12.587@informatica@7180@LM_INFO@agent|Job 'MySQL 时间点恢复作业20230828' (id cc71a0d4457111ee8000ac751dade2d1, activity id 35c50a6c457211ee80000050568a78f2) is started.
2023-08-28 15:12:12.594@informatica@7180@LM_DEBUG@agent|Spawned process 10328 "ps", cwd="(null)"
2023-08-28 15:12:12.624@informatica@7180@LM_DEBUG@agent|The process 10328 exited with code 0
2023-08-28 15:12:12.656@informatica@7180@LM_DEBUG@agent|MySQL data directory: /data/mysql/data/
2023-08-28 15:12:12.664@informatica@7180@LM_INFO@agent|Stopping MySQL instance MySQL-3306
2023-08-28 15:12:12.666@informatica@7180@LM_DEBUG@agent|Spawned process "sh -c /tmp/script-35d2c40e457211ee80000050568a78f2.sh", pid=10331, cwd="(null)"
2023-08-28 15:12:16.244@informatica@7180@LM_DEBUG@agent|The process 'sh -c /tmp/script-35d2c40e457211ee80000050568a78f2.sh' exited with code 0
2023-08-28 15:12:16.248@informatica@7180@LM_DEBUG@agent|Spawned process 10343 "ps", cwd="(null)"
2023-08-28 15:12:16.275@informatica@7180@LM_DEBUG@agent|The process 10343 exited with code 0
2023-08-28 15:12:16.277@informatica@7180@LM_ERROR@agent|Failed to find inode of port 3306
2023-08-28 15:12:16.277@informatica@7180@LM_ERROR@agent|Failed to get PID of MySQL-3306
2023-08-28 15:12:16.348@informatica@7180@LM_ERROR@agent|Failed to connect to mysql database: Can't connect to local MySQL server through socket '/data/mysql/socket/mysql.sock' (2)
2023-08-28 15:12:16.348@informatica@7180@LM_DEBUG@agent|Try to login MySQL-3306
2023-08-28 15:12:16.349@informatica@7180@LM_DEBUG@agent|Spawned process 10344 "ps", cwd="(null)"
2023-08-28 15:12:16.376@informatica@7180@LM_DEBUG@agent|The process 10344 exited with code 0
2023-08-28 15:12:16.379@informatica@7180@LM_ERROR@agent|Failed to find inode of port 3306
2023-08-28 15:12:16.379@informatica@7180@LM_ERROR@agent|Failed to get PID of MySQL-3306
2023-08-28 15:12:16.379@informatica@7180@LM_INFO@agent|Start to transport full backup data to /data/mysql/data/, instance: MySQL-3306
2023-08-28 15:12:16.494@informatica@7180@LM_ERROR@agent|2023-08-28T15:12:16.486618+08:00 0 [ERROR] [MY-011825] [Xtrabackup] unknown argument: '/data/mysql/data/'
2023-08-28 15:12:16.499@informatica@7180@LM_ERROR@agent|Failed to write to xbstream, errno=32, Broken pipe
2023-08-28 15:12:16.531@informatica@7180@LM_ERROR@agent|Failed to restore MySQL physical backup
2023-08-28 15:12:16.553@informatica@7180@LM_ERROR@agent|Job 'MySQL 时间点恢复作业20230828' (id cc71a0d4457111ee8000ac751dade2d1, activity id 35c50a6c457211ee80000050568a78f2) failed.


mysql> select count(*) from sbtest2;
+----------+
| count(*) |
+----------+
|   451584 |
+----------+
1 row in set (0.12 sec)

mysql> select count(*) from sbtest1;
+----------+
| count(*) |
+----------+
|  1000000 |
+----------+
1 row in set (0.06 sec)


powershell .\bcp_queryout.ps1 -fileList "LAAssessMaintain:LAAssessMaintain" -src_server 192.168.100.106 -src_user sa -src_password Cmbjx3ccwtn9 -dst_server 172.18.100.157 -dst_user sa -dst_password qwerty1! -throttle 3


#下载可执行文件的tar包
wget "https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/file-manage-files/zh-CN/20230406/flxd/qpress-11-linux-x64.tar"

#解压下载的tar包，取出可执行文件
tar -xvf qpress-11-linux-x64.tar

#设置qpress文件的执行权限
sudo chmod 775 qpress

#拷贝qpress到/usr/bin中
sudo cp qpress /usr/bin


*** 命令url https://attunity46.rssing.com/chan-63610596/article30.html
#AR命令行 
#获取所有任务列表，然后断开连接
repctl connect; gettasks; disconnect

Paramaters:
1 = Start Full Load only
2 = Start Change Capture only
3 = Start Both
Flags Values:
0 = Resume
1 = Fresh Start (like starting as of now)
#停止任务
repctl connect; stoptask test_test1; disconnect
#启动任务
repctl connect; execute test_test1 3 Flags=0; disconnect


#获取所有任务列表#
tasks=$(repctl connect; gettasks; disconnect)

#遍历任务列表并启动每个任务
for task_name in $tasks; do
    repctl connect; execute $task_name 3 Flags=0; disconnect
done


***url https://community.qlik.com/t5/Qlik-Replicate/How-to-recover-a-task-by-repctl-execute-command/td-p/1765367
task:required string
operation:required enum, valid values:
01 - EXECUTE_OPERATIONS_LOAD
02 - EXECUTE_OPERATIONS_CDC
03 - EXECUTE_OPERATIONS_BOTH

flags:optional enum, valid values:
00 - RESUME
01 - FRESH
02 - METADATA_ONLY
03 - FRESH_METADATA_ONLY
04 - COLLECTION
08 - RECOVERY
#全量刷 Flags=1 为全量 0 为增量 、operation=1 全量刷完停止任务
repctl connect; execute test_test1 3 Flags=1; disconnect


一条 insert 语句在写入磁盘的过程中到底涉及了哪些文件？顺序又是如何的？下面我们用两张图和大家一 起解析 insert 语句的磁盘写入之旅。

图 1：事务提交前的日志文件写入
过程：
1. 首先 insert 进入 server 层后，会进行一些必要的检查，检查的过程中并不会涉及到磁盘的写入。
2. 检查没有问题之后，便进入引擎层开始正式的提交。
我们知道 InnoDB 会将数据页缓存至内存中的 buffer pool，所以 insert 语句到了这里并不需要立刻将数据写入磁盘文件中，只需要修改 buffer pool 当中对应的数据页就可以了。 
buffer pool 中的数据页刷盘并不需要在事务提交前完成，其中交互过程会在下一张图中分解。
3. 但仅仅写入内存的 buffer pool 并不能保证数据的持久化，如果 MySQL 宕机重启了，需要保证 insert 的数据不会丢失。
redo log 因此而生，当 innodb_flush_log_at_trx_commit=1 时，每次事务提交都会 触发一次 redo log 刷盘。（redo log 是顺序写入，相比直接修改数据文件，redo 的磁盘写入效率更加 高效）
4. 如果开启了 binlog 日志，我们还需将事务逻辑数据写入 binlog 文件，且为了保证复制安全，建议使 用 sync_binlog=1 ，也就是每次事务提交时，都要将 binlog 日志的变更刷入磁盘。
综上（在 InnoDB buffer pool 足够大且上述的两个参数设置为双一时），insert 语句成功提交时，真正发生 磁盘数据写入的，并不是 MySQL 的数据文件，而是 redo log 和 binlog 文件。
然而，InnoDB buffer pool 不可能无限大，redo log 也需要定期轮换，很难容下所有的数据，下面我们就来 看看 buffer pool 与磁盘数据文件的交互方式。




InnoDB buffer pool 一页脏页大小为 16 KB，如果只写了前 4KB 时发生宕机，那这个脏页就发生了 写失败，会造成数据丢失。为了避免这一问题，InnoDB 使用了 double write 机制（InnoDB 将 double write 的数据存于共享表空间中）。在写入数据文件之前，先将脏页写入 double write 中，当然这里的写入 都是需要刷盘的。有人会问 redo log 不是也能恢复数据页吗？为什么还需要 double write？这是因为 redo log 中记录的是页的偏移量，比如在页偏移量为 800 的地方写入数据 xxx，而如果页本身已经发生损坏， 应用 redo log 也无济于事。


InnoDB 的数据是根据聚集索引排列的，通常业务在插入数据时是按照主键递增的，所以插入聚集索 引一般是顺序磁盘写入。
但是不可能每张表都只有聚集索引，当存在非聚集索引时，对于非聚集索引的变 更就可能不是顺序的，会拖慢整体的插入性能。
为了解决这一问题，InnoDB 使用了 insert buffer 机制，将 对于非聚集索引的变更先放入 insert buffer ，尽量合并一些数据页后再写入实际的非聚集索引中去。

事务提交后的数据文件写入过程

1. 当 buffer pool 中的数据页达到一定量的脏页或 InnoDB 的 IO 压力较小 时，都会触发脏页的刷盘操 作。
2. 当开启 double write 时，InnoDB 刷脏页时首先会复制一份刷入 double write，在这个过程中，由于 double write 的页是连续的，对磁盘的写入也是顺序操作，性能消耗不大。
3. 无论是否经过 double write，脏页最终还是需要刷入表空间的数据文件。刷入完成后才能释放 buffer pool 当中的空间。
4. insert buffer 也是 buffer pool 中的一部分，当 buffer pool 空间不足需要交换出部分脏页时，有可能将 insert buffer 的数据页换出，刷入共享表空间中的 insert buffer 数据文件中。
5. 当 innodb_stats_persistent=ON 时，SQL 语句所涉及到的 InnoDB 统计信息也会被刷盘到 innodb_table_stats 和 innodb_index_stats 这两张系统表中，这样就不用每次再实时计算了。
6. 有一些情况下可以不经过 double write 直接刷盘 a. 关闭 double write b. 不需要 double write 保障，
如 drop table 等操作 汇总两张图，一条 insert 语句的所有涉及到的数据在磁盘上会依次写入 redo log，binlog，(double write， insert buffer) 共享表空间，最后在自己的用户表空间落定为安。

解析 binlog/relaylog，得到 DROP 操作的 GTID 或者 POS。
while read relaylogname
do
/data/mysql_basedir/bin/mysqlbinlog --base64-output=decode-rows -vvv $relaylogname  | grep -Ei "drop" && echo "RELAYLOG位置: $relaylogname"
done < /data/mysql/data/informatica-relay-bin.index

# 初始化本地仓库
git init

# 添加要上传的文件夹
git add monthlymaintenance

# 提交更改
git commit -m "commit"
git remote add origin git@github.com:ceriar/databases.git
# 关联到远程仓库
git remote add origin git@github.com:xinl0ngli/PostgreSQL.git
git remote add origin git@github.com:lcerll/MySQL-note.git
# 推送更改到 GitHub
git pull origin main
git push -u origin master

#20240229
#load data for mysql
lixl@msql[(none)]> LOAD DATA INFILE '/data/mysql_8034/file/20240229.txt'
    -> REPLACE INTO TABLE testg.datetest
    -> CHARACTER SET utf8mb4
    -> FIELDS TERMINATED BY ','
    -> ENCLOSED BY '"'
    -> LINES TERMINATED BY '\n'
    -> (@CA, @C2) -- 对应txt文件中的2列数据
    -> SET datetime_column = STR_TO_DATE(@CA, '%Y/%m/%d %H:%i'), --使用 STR_TO_DATE 函数来转换日期时间值
    ->     timestamp_column = STR_TO_DATE(@C2, '%Y/%m/%d %H:%i:%s');
Query OK, 12 rows affected (0.12 sec)
Records: 12  Deleted: 0  Skipped: 0  Warnings: 0

[root@localhost file]# cat /data/mysql_8034/file/20240229.txt
"2024/2/19 16:09","2024/02/19 16:08:39"
"2024/2/19 15:26","2024/02/19 15:25:23"
"2024/2/19 15:22","2024/02/19 15:22:14"
...


# LOAD 数据
-- 导出
msql[testg]> SELECT * INTO OUTFILE '/data/mysql_8034/file/order1.txt'
    -> CHARACTER SET utf8mb4
    -> FIELDS TERMINATED BY ','
    -> ENCLOSED BY '\"'
    -> LINES TERMINATED BY '\n'
    -> FROM testg.orders;
Query OK, 358138 rows affected (0.42 sec)

-- 查看TXT
"1","1","1","2978","7","7","1","2023-12-08 13:00:34"
"2","1","1","1062","5","8","1","2023-12-08 13:00:34"

--导入
 LOAD DATA INFILE '/data/mysql_8034/file/order1.txt'
    ->      REPLACE INTO TABLE testg.orders1
    ->      CHARACTER SET utf8mb4
    ->      FIELDS TERMINATED BY ','
    ->      ENCLOSED BY '"'
    ->      LINES TERMINATED BY '\n'
    ->      (@C1, @C2, @C3, @C4, @C5, @C6, @C7, @C8) -- 对应txt中的8列数据
    ->      SET o_id=@C1,o_w_id=@C2,o_d_id=@C3,o_c_id=@C4,o_entry_d=@C8; -- 指定txt列与字段对应关系，
Query OK, 358138 rows affected (6.30 sec)
Records: 358138  Deleted: 0  Skipped: 0  Warnings: 0


#my2sql
./my2sql -user lixl -password lixl -host 192.168.97.51 -port 3306 -mode file -local-binlog-file /data/mysql_8034/binlog/mysql-bin.000111 -work-type stats -start-file /data/mysql_8034/binlog/mysql-bin.000111 -output-dir ./tmpdir

#PostGreSQL checkpoint，

checkpoint检查点，一般会将某个时间节点之前的脏数据全部刷到磁盘，是为了实现数据一致性和完整性、业界主流RDBMS关系型数据库都具备该功能。目的是为了缩短崩溃恢复时间，之后一系列的应用WAL日志。

postgresql-15.2\src\include\access\xlog.h

```c
/*
 * OR-able request flag bits for checkpoints.  The "cause" bits are used only
 * for logging purposes.  Note: the flags must be defined so that it's
 * sensible to OR together request flags arising from different requestors.
 */

/* These directly affect the behavior of CreateCheckPoint and subsidiaries */
#define CHECKPOINT_IS_SHUTDOWN	0x0001	/* Checkpoint is for shutdown */
#define CHECKPOINT_END_OF_RECOVERY	0x0002	/* Like shutdown checkpoint, but
											 * issued at end of WAL recovery */
#define CHECKPOINT_IMMEDIATE	0x0004	/* Do it without delays */
#define CHECKPOINT_FORCE		0x0008	/* Force even if no activity */
#define CHECKPOINT_FLUSH_ALL	0x0010	/* Flush all pages, including those
										 * belonging to unlogged tables */
```

从注释来看checkpoint触发机制 与MySQL 是有相似的。


# 在8.0版本之前，我们可以通过授予该用户对mysql.proc的select权限来达成目的。
grant select on mysql.proc to zhenxi1@'%';

#8.0版本之后，去掉了mysql.proc，所以这种方法，不再有效，一种可替代的方案是，授予该账号对所有库的select权限。
grant select on *.* to zhenxi1@'%'

#授予用户对所有库的select权限，范围太广了，所以mysql从8.0.20开始增加了show_routine权限，解决这个问题：
GRANT show_routine on *.* TO 'zhenxi1'@'%'
https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html#priv_show-routine
需要注意的是show_routine是一个global privilege，需要在全局授予，也即*.*，不能在库级别授予，否则，将会报如下错误：ERROR 1221 (HY000): Incorrect usage of DB GRANT and GLOBAL PRIVILEGES


CREATE USER 'exporter'@'%' IDENTIFIED BY 'P@ssw0rd001!' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';


GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT ON *.* TO 'exporter'@'%' WITH MAX_USER_CONNECTIONS 3;



####
su - mysql
currdt=`date +%Y%m%d_%H%M%S`
echo "$currdt" > /tmp/currdt_tmp.txt
mkdir /tmp/diag_info_`hostname -i`_$currdt
cd /tmp/diag_info_`hostname -i`_$currdt

-- 1. mysql进程负载
su - 
cd /tmp/diag_info_`hostname -i`_`cat /tmp/currdt_tmp.txt`

ps -ef | grep -w mysqld
mpid=`pidof mysqld`
echo $mpid

-- b: 批量模式; n: 制定采集测试; d: 间隔时间; H: 线程模式; p: 指定进程号
echo $mpid
top -b -n 120 -d 1 -H -p $mpid > mysqld_top_`date +%Y%m%d_%H%M%S`.txt

-- 2. 信息采集步骤--- 以下窗口，建议启动额外的窗口执行
mysql -uroot -h127.1 -p

tee var-1.txt
show global variables;

tee stat-1.txt
show global status;

tee proclist-1.txt
show full processlist\G
show full processlist;

tee slave_stat-1.txt
show slave status\G

tee threads-1.txt
select * from performance_schema.threads \G

tee innodb_trx-1.txt
select * from information_schema.innodb_trx \G

tee innodb_stat-1.txt
show engine innodb status\G

tee innodb_mutex-1.txt
SHOW ENGINE INNODB MUTEX;

-- 锁与等待信息
tee data_locks-1.txt

-- mysql8.0
select * from performance_schema.data_locks\G
select * from performance_schema.data_lock_waits\G

-- mysql5.7
select * from information_schema.innodb_lock_waits \G
select * from information_schema.innodb_locks\G


-- 3. 堆栈信息
su - 
cd /tmp/diag_info_`hostname -i`_`cat /tmp/currdt_tmp.txt`

ps -ef | grep -w mysqld
mpid=`pidof mysqld`
echo $mpid

-- 堆栈信息
echo $mpid
pstack $mpid > mysqld_stack_`date +%Y%m%d_%H%M%S`.txt

-- 线程压力
echo $mpid

perf top
echo $mpid
perf top -p $mpid

perf record -a -g -F 1000 -p $mpid -o pdata_1.dat
perf report -i pdata_1.dat

-- 4. 等待 30 秒
SELECT SLEEP(60);

-- 5. 信息采集步骤--- 以下窗口，建议启动额外的窗口执行
mysql -uroot -h127.1 -p

tee var-2.txt
show global variables;

tee stat-2.txt
show global status;

tee proclist-2.txt
show full processlist\G
show full processlist;

tee slave_stat-2.txt
show slave status\G

tee threads-2.txt
select * from performance_schema.threads \G

tee innodb_trx-2.txt
select * from information_schema.innodb_trx \G

tee innodb_stat-2.txt
show engine innodb status\G

tee innodb_mutex-2.txt
SHOW ENGINE INNODB MUTEX;

-- 锁与等待信息
tee data_locks-2.txt

-- mysql8.0
select * from performance_schema.data_locks\G
select * from performance_schema.data_lock_waits\G

-- mysql5.7
select * from information_schema.innodb_lock_waits \G
select * from information_schema.innodb_locks\G


-- 6. 堆栈信息
su - 
cd /tmp/diag_info_`hostname -i`_`cat /tmp/currdt_tmp.txt`

ps -ef | grep -w mysqld
mpid=`pidof mysqld`
echo $mpid

-- 堆栈信息
echo $mpid
pstack $mpid > mysqld_stack_`date +%Y%m%d_%H%M%S`.txt

-- 线程压力
echo $mpid

perf top
echo $mpid
perf top -p $mpid

perf record -a -g -F 1000 -p $mpid -o pdata_2.dat
perf report -i pdata_2.dat

#诊断
• top 主机负载情况
• dmesg | tail 是否存在oom-killer 或 tcp drop等错误信息
• vmstat 1 检查r、free、si、so、us, sy, id, wa, st列
• mpstat -P ALL 1 检查CPU使用率是否均衡
• pidstat 1 检查进程的cpu使用率、多核利用情况
• iostat -xz 1 检查r/s, w/s, rkB/s, wkB/s, await, avgqu-sz, %util (yum install sysstat)
• free -m 检查内存使用情况
• sar -n DEV 1 检查网络吞吐量
• sar -n TCP,ETCP 1 检查tcp连接情况active/s, passive/s, retrans/s 

SELECT t.table_schema, t.table_name FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints c
WHERE t.table_schema NOT IN ('mysql','information_schema', 'performance_schema') AND t.engine = 'InnoDB' AND
ON (t.table_schema = c.table_schema AND t.table_name = c.table_name AND c.constraint_type IN ('PRIMARY KEY','UNIQUE'))
c.table_name IS NULL;

SELECT a.requesting_trx_id '被阻塞的事务ID' ,b.trx_mysql_thread_id '被阻塞的线程ID', TIMESTAMPDIFF(SECOND,b.trx_wait_started,NOW())
'被阻塞秒数', b.trx_query '被阻塞的语句', a.blocking_trx_id '阻塞事务ID' ,c.trx_mysql_thread_id '阻塞线程ID',d.INFO '阻塞事务信息' FROM
information_schema.INNODB_LOCK_WAITS a
 INNER JOIN information_schema.INNODB_TRX b ON a.requesting_trx_id=b.trx_id
 INNER JOIN information_schema.INNODB_TRX c ON a.blocking_trx_id=c.trx_id
 INNER JOIN information_schema.PROCESSLIST d ON c.trx_mysql_thread_id=d.ID ;

#gh-ost丢数据原因
应该和两阶段提交有关，两阶段提交先写redo log设置prepare阶段，再写binlog，最后将redo log设置为commit状态。
在写完binlog，没标记redo log commit状态的时候，启动gh-ost，完成binlog监听，select最大最小边界值，就会出现丢数据。
和主从同步关系应该不大。即使没有从库，也会丢数据的。  
--当使用 gh-ost 时，它会监听 binlog，捕获表的变更，并将这些变更应用到目标表中。
--然而，在某些情况下，如果在 binlog 中的事务已经被标记为提交，但是在 gh-ost 启动前，
--该事务的 binlog 还未被读取和应用，那么在执行完 gh-ost 后，这些事务就会被遗漏，导致数据丢失。
不过加共享锁，确实可以解决这个问题。


没有使用半同步也存在这种问题，sync阶段binlog落盘到commit阶段释放锁资源，这个时间差内的数据都存在上面问题，只是半同步放大这种问题

#bcp-mssql
powershell .\bcp_queryout.ps1 -fileList "F_CUSTOM:F_CUSTOM" -src_server 192.168.100.106 -src_db NissayLis -src_user sa -src_password Cmbjx3ccwtn9 -dst_server 172.18.100.157 -dst_db NissayLis_DB -dst_user sa -dst_password qwerty1! -throttle 5


#查询slow_log表中每天第一个慢查询的 start_time\query_time
SELECT * FROM
(
SELECT 
@rn:= CASE WHEN @start_day = start_day THEN @rn + 1 ELSE 1 END AS rn,
@start_day:= start_day as start_day,
start_time, query_time
FROM
(select start_time,query_time,DATE(start_time) as start_day 
from mysql.slow_log where start_time >= '2024-03-24' order by start_time,query_time desc) a
,(SELECT @rn=0, @start_day=0) b
)a WHERE rn <= 5


#mysql5.7 row_number 通过start_time列获取相同一天进行倒叙排序(query_time)
SET @rn := 0; -- 初始化 @rn
SET @start_day := NULL; -- 初始化 @start_day

SELECT * FROM (
    SELECT 
        @rn:= CASE WHEN @start_day = start_day THEN @rn + 1 ELSE 1 END AS rn,
        @start_day:= start_day as start_day,
        start_time, 
        query_time
    FROM (
        SELECT 
            start_time, 
            query_time, 
            DATE(start_time) as start_day 
        FROM mysql.slow_log 
        WHERE start_time >= '2024-03-24' 
        ORDER BY start_day, query_time DESC -- 根据日期和query_time降序排序
    ) a
) AS c WHERE rn <= 5; -- rn=1获取每天最耗时

rn	start_day	start_time			query_time	
1	2024-03-24	2024-03-24 08:34:17	00:04:16.0846220
2	2024-03-24	2024-03-24 09:01:06	00:00:38.7939260
3	2024-03-24	2024-03-24 04:00:09	00:00:09.1025340
4	2024-03-24	2024-03-24 09:34:50	00:00:07.9247820
5	2024-03-24	2024-03-24 21:00:07	00:00:07.3918420
1	2024-03-25	2024-03-25 08:34:07	00:04:05.7095560
2	2024-03-25	2024-03-25 13:52:42	00:01:23.4929310
3	2024-03-25	2024-03-25 15:52:39	00:01:22.9520950
4	2024-03-25	2024-03-25 14:52:24	00:01:22.0064700
5	2024-03-25	2024-03-25 14:51:02	00:01:17.3882960
1	2024-03-26	2024-03-26 14:39:07	00:26:35.4035430
2	2024-03-26	2024-03-26 15:25:25	00:25:17.5150220
3	2024-03-26	2024-03-26 11:49:01	00:24:13.3050960
4	2024-03-26	2024-03-26 15:51:57	00:23:47.4948910
5	2024-03-26	2024-03-26 10:52:43	00:15:47.6714450

SELECT * FROM (
    SELECT 
        @rn:= CASE WHEN @start_day = start_day THEN @rn + 1 ELSE 1 END AS rn,
        @start_day:= start_day as start_day,
        start_time, 
        query_time
    FROM (
        SELECT 
            start_time, 
            query_time, 
            @start_day:= DATE(start_time) as start_day -- 保存 start_day 的值
        FROM mysql.slow_log 
        WHERE start_time >= '2024-03-24' 
        ORDER BY start_day, query_time DESC -- 根据日期和query_time降序排序
    ) a,
    (SELECT @rn:=0, @start_day:=0) b
) AS c where rn<6;

`GROUP_CONCAT` 函数用于将多个行的值连接成一个单个字符串。 //SEPARATOR 是 GROUP_CONCAT 函数的一个可选参数，用于指定连接结果中每个值之间的分隔符。默认情况下，GROUP_CONCAT 函数会将多个值连接成一个字符串，每个值之间没有分隔符。
SELECT 
CONCAT("ALTER TABLE t_recments ",GROUP_CONCAT(CONCAT("DROP INDEX ", index_name) SEPARATOR ", "),";") AS drop_index_sql
FROM information_schema.statistics 
WHERE TABLE_NAME='t_recments' AND CARDINALITY < '100000';

在 READ-COMMITTED 隔离级别，也会存在 gap lock，只发生
在：唯一约束检查到有唯一冲突的时候，会加 S Next-key Lock，即对记录以及与和上一条记录之间的
间隙加共享锁。

# 参考{https://opensource.actionsky.com/20210915-mysql/}
# 利用mysql-shell 做垂直拆表demo。
 MySQL  localhost  Py > conn1 = 'mysql://lixl:lixl@192.168.97.51:3306/testdb'
 MySQL  localhost  Py > rs = mysql.get_classic_session(conn1);
 MySQL  localhost  Py > field_list = []
 MySQL  localhost  Py > for i in range(1, 1001):
                     ->     field_list.append('r' + str(i) + ' int')
                     -> field_lists = ','.join(field_list)
                     -> rs.run_sql('create table t_large(id serial primary key,' + field_lists + ')')
                     ->
Query OK, 0 rows affected (0.2094 sec)
 MySQL  localhost  Py > v_list = []
 MySQL  localhost  Py > for i in range(1000, 2000):
                     ->     v_list.append(str(i))
                     -> v_lists = ','.join(v_list)
                     -> for i in range(1, 10001):
                     ->     rs.run_sql('insert into t_large select null,' + v_lists)
                     ->
Query OK, 1 row affected (0.0018 sec)

Records: 1  Duplicates: 0  Warnings: 0
 MySQL  localhost  Py > rs.run_sql('select count(*) from t_large');
+----------+
| count(*) |
+----------+
|    10000 |
+----------+
1 row in set (0.2209 sec)
 MySQL  localhost  Py > for i in range(1,101):
                     ->      f_list1 = []
                     ->      f_list2 = []
                     ->      for j in range(1,11):
                     ->          f_list1.append('r' + str(j + (i-1)*10) + ' int')
                     ->          f_list2.append('r' + str(j + (i-1)*10))
                     ->      rs.run_sql('create table t_large' + str(i) +'( id serial primary key,'+ ','.join(f_list1) + ')')
                     ->
Query OK, 0 rows affected (0.0088 sec)
 MySQL  localhost  Py > rs.run_sql('insert into t_large' + str(i) +' select id,' + ','.join(f_list2) + ' from t_large')
Query OK, 10000 rows affected (0.2919 sec)

Records: 10000  Duplicates: 0  Warnings: 0
 MySQL  localhost  Py > for i in range(1, 101):
                     ->     table_name = 't_large' + str(i)
                     ->     rs.run_sql('DROP TABLE IF EXISTS ' + table_name)
                     ->
Query OK, 0 rows affected (0.0057 sec)
 MySQL  localhost  Py > for i in range(1,101):
                     ->      f_list1 = []
                     ->      f_list2 = []
                     ->      for j in range(1,11):
                     ->          f_list1.append('r' + str(j + (i-1)*10) + ' int')
                     ->          f_list2.append('r' + str(j + (i-1)*10))
                     ->      rs.run_sql('create table t_large' + str(i) +'( id serial primary key,'+ ','.join(f_list1) + ')')
                     ->      rs.run_sql('insert into t_large' + str(i) +' select id,' + ','.join(f_list2) + ' from t_large')
                     ->
Query OK, 10000 rows affected (0.2247 sec)

Records: 10000  Duplicates: 0  Warnings: 0

#mysql 5.7禁用ssl
 MySQL  Py > conn1 = 'mysql://root:Cmbjx3ccwtn9@172.18.100.59:3306/ats?ssl-mode=DISABLED'
 MySQL  Py > rs = mysql.get_classic_session(conn1);
 MySQL  Py > rs.run_sql('select * from mysql.user')

columns_query = "SELECT COLUMN_NAME,COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_NAME = 't_recments' AND TABLE_SCHEMA = 'ats'"
columns_result = rs.run_sql(columns_query)
all_rows = columns_result.fetch_all()
column_info = {row[0]: row[1] for row in all_rows}
field_names = list(column_info.keys())

def insert_data(table_name, data):
    placeholders = ', '.join(['%s'] * len(data))
    columns = ', '.join([f"`{col}`" for col in data.keys()])  # Wrap field names with backticks
    insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
    rs.run_sql(insert_query, tuple(data.values()))

for i in range(0, len(field_names), 20):
    table_name = f"t_recments_{i // 20 + 1}"
    create_table_sql = f"CREATE TABLE {table_name} (id SERIAL PRIMARY KEY"
    for field_name in field_names[i:i+20]:
        column_type = column_info[field_name]
        create_table_sql += f", `{field_name}` {column_type}"  # Wrap field names with backticks
    create_table_sql += ")"
    rs.run_sql(create_table_sql)
	
pg加密
INSERT INTO users (username, password)
VALUES ('it', pgp_sym_encrypt('123456', 'lixl'));
SELECT username, pgp_sym_decrypt(password::bytea, 'lixl'::text) AS decrypted_password FROM users WHERE id ='1';

pg审计插件
https://github.com/pgaudit/pgaudit 找对应支持的版本
select name,setting from pg_settings where name ~ 'pgaudit';
alter system set pgaudit.log = 'read, write, ddl';		
set pgaudit.log = 'read, write, ddl';
set pgaudit.log_relation = on;
set pgaudit.log_client=on;


ALTER DATABASE postgres SET pgaudit.log = 'none';
SELECT rolname,rolconfig FROM pg_roles;
ALTER ROLE read_access SET pgaudit.log='NONE';

SHOW cron.timezone;


SELECT pg_catalog.pg_get_functiondef(p.oid)
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.proname = 'i';


CREATE SCHEMA daily_schema;

drop table users;
CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(36) NOT NULL,
    password VARCHAR(255) NOT NULL,
    key VARCHAR(64) NOT NULL
);

DROP PROCEDURE daily_schema.i;
CREATE OR REPLACE PROCEDURE daily_schema.i()
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_key TEXT;
BEGIN
    BEGIN
        -- 生成一个随机密钥
        new_key := gen_random_uuid()::TEXT;
        PERFORM pg_sleep(2);
        -- 插入新的记录
        INSERT INTO users (id, username, password, key)
        VALUES (65432,'itwb_lixl', pgp_sym_encrypt('P@ssw0rd123', new_key), new_key);

    EXCEPTION
        WHEN OTHERS THEN
            -- 捕获所有异常并记录日志，但不显示具体的 SQL 语句
            RAISE NOTICE 'an error occurred, please contact the administrator';
            -- 或者你可以记录错误信息到一个日志表中，而不是直接返回给用户
            -- INSERT INTO error_log (error_time, error_message) VALUES (now(), SQLERRM);
    END;
END;
$$;

CREATE OR REPLACE PROCEDURE daily_schema.t()
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    BEGIN
    	PERFORM pg_sleep(6);
        TRUNCATE TABLE users;

    EXCEPTION
        WHEN OTHERS THEN
            -- 捕获所有异常并记录日志，但不显示具体的 SQL 语句
            RAISE NOTICE 'an error occurred, please contact the administrator';
            -- 或者你可以记录错误信息到一个日志表中，而不是直接返回给用户
            -- TRUNCATE.. 
    END;
END;
$$;


CREATE ROLE daily_role;
CREATE USER daily_user WITH PASSWORD 'u8sEbcGCNwWsze8a';
GRANT daily_user TO daily_role;


GRANT USAGE ON SCHEMA daily_schema TO daily_user;
GRANT EXECUTE ON PROCEDURE daily_schema.i TO daily_user;
GRANT INSERT ON users TO daily_user;

GRANT USAGE ON SCHEMA daily_schema TO daily_user;
GRANT EXECUTE ON PROCEDURE daily_schema.t TO daily_user;
GRANT TRUNCATE  ON users TO daily_user;

GRANT USAGE ON SCHEMA cron TO daily_user;
SELECT cron.schedule('0 9 * * *', 'SET ROLE daily_user; CALL daily_schema.t(); reset role;');
create extension pg_cron;

SET ROLE daily_user; CALL daily_schema.i(); reset role;

select * from users


Redo Log 的持久化：
在 2PC 的准备阶段，参与者会将 PREPARE 记录写入 redo log buffer，并通过 write 操作将数据写入到 redo log 文件的 page cache 中。
执行 fsync 操作后，PREPARE 记录会真正持久化到磁盘。这保证了即使系统崩溃，准备状态的事务也不会丢失，并能够正确地处理后续的 COMMIT 或 ROLLBACK 操作。

Binlog 的持久化：
在 2PC 的提交阶段，参与者会将 COMMIT 记录写入 redo log，并随后将 COMMIT 事件记录到 binlog 中。
fsync 操作确保 redo log 中的 COMMIT 记录被持久化到磁盘，并在 binlog 中记录 COMMIT 事件，表示事务已完成。


MySQL DDL 的原理简析

copy 算法
较简单的实现方法，MySQL 会建立一个新的临时表，把源表的所有数据写入到临时表，在此期间无法对源表进行数据写入。MySQL 在完成临时表的写入之后，用临时表替换掉源表。这个算法主要被早期（<=5.5）版本所使用。

inplace 算法
从 5.6 开始，常用的 DDL 都默认使用这个算法。inplace 算法包含两类：inplace-no-rebuild 和 inplace-rebuild，两者的主要差异在于是否需要重建源表。

inplace 算法的操作阶段主要分为三个：

Prepare阶段： 
	- 创建新的临时 frm 文件(与 InnoDB 无关)。 - 持有 EXCLUSIVE-MDL 锁，禁止读写。 - 根据 alter 类型，确定执行方式（copy，online-rebuild，online-not-rebuild）。 更新数据字典的内存对象。 - 分配 row_log 对象记录数据变更的增量（仅 rebuild 类型需要）。 - 生成新的临时ibd文件 new_table（仅rebuild类型需要）。
Execute 阶段：
	降级EXCLUSIVE-MDL锁，允许读写。
	扫描old_table聚集索引（主键）中的每一条记录 rec。
	遍历new_table的聚集索引和二级索引，逐一处理。
	根据 rec 构造对应的索引项。
	将构造索引项插入 sort_buffer 块排序。
	将 sort_buffer 块更新到 new_table 的索引上。
	记录 online-ddl 执行过程中产生的增量（仅 rebuild 类型需要）。
	重放 row_log 中的操作到 new_table 的索引上（not-rebuild 数据是在原表上更新）。
	重放 row_log 中的DML操作到 new_table 的数据行上。
Commit阶段：
	当前 Block 为 row_log 最后一个时，禁止读写，升级到 EXCLUSIVE-MDL 锁。
	重做 row_log 中最后一部分增量。
	更新 innodb 的数据字典表。
	提交事务（刷事务的 redo 日志）。
	修改统计信息。
	rename 临时 ibd 文件，frm文件。
	变更完成，释放 EXCLUSIVE-MDL 锁。

instant 算法
	MySQL 8.0.12 才提出的新算法，目前只支持添加列等少量操作，利用 8.0 新的表结构设计，可以直接修改表的 metadata 数据，省掉了 rebuild 的过程，极大的缩短了 DDL 语句的执行时间。
	
	
	
systemctl命令tab自动补全
yum install -y bash-completion


mysql 5.7.27 源码编译安装（debug）
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/data/mysql/data \
-DMYSQL_UNIX_ADDR=/data/mysql/socket/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DENABLED_LOCAL_INFILE=1 \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=/usr/local/boost \
-DWITH_DEBUG=1 \
-DCURSES_LIBRARY=/usr/lib/libncurses.so \
-DCURSES_INCLUDE_PATH=/usr/include \
-DWITH_ZLIB=/usr/local/

make
make install
mkdir -p /data/mysql/{binlog,data,log,relaylog,socket,tmp}
groupadd mysql >/dev/null 2>&1
useradd -g mysql -r -s /bin/false mysql >/dev/null 2>&1

[mysqld]
basedir = /usr/local/mysql/
datadir = /data/mysql/data
port = 3306
socket = /data/mysql/socket/mysql.sock
symbolic-links = 0
innodb_flush_log_at_trx_commit = 1
character_set_server = utf8
lower_case_table_names=1
# explicit_defaults_for_timestamp = true
skip_name_resolve = 1

# INNODB
# innodb_buffer_pool_chunk_size = 128M
# innodb_buffer_pool_instances = 8
innodb_buffer_pool_size = 256M
# innodb_log_buffer_size = 16M
innodb_flush_method             = O_DIRECT
innodb_read_io_threads          = 4
innodb_write_io_threads         = 4
innodb_io_capacity = 1000

# BINLOG
server-id = 97197  # 1:GDS  1:prod  10053:ip
log_bin = /data/mysql/binlog/mysql-bin
binlog_format = row
max_binlog_size = 1024M
expire_logs_days = 7
sync_binlog = 1

# GTID
gtid-mode = on
enforce-gtid-consistency = true
log-slave-updates = 1

# MTS
slave-load-tmpdir = /data/mysql/tmp
slave-parallel-type = LOGICAL_CLOCK
slave-parallel-workers = 2
slave_preserve_commit_order = 1
master_info_repository = TABLE
relay_log_info_repository = TABLE
relay_log_recovery = 1
relay-log = /data/mysql/relaylog/relay-bin
relay-log-index = /data/mysql/relaylog/relay-bin.index
max_relay_log_size = 1024M

pid-file = /data/mysql/data/mysql.pid

max_connections                 = 2000
open_files_limit                = 65535

# validate_password #
validate_password                    = ON
validate_password_policy             = 1
validate_password_mixed_case_count   = 1
validate_password_number_count       = 1
validate_password_special_char_count = 0
validate_password_length             = 10

# plugin #
plugin-load="validate_password=validate_password.so"

[mysqld_safe]
log-error = /data/mysql/log/error.log
pid-file = /data/mysql/data/mysql.pid

[client]
socket = /data/mysql/socket/mysql.sock



MySQL 默认使用 GLIBC 内存分配器，通过 gdb 调用 malloc_stats()函数分析内存使用情况：

gdb -ex "call (void) malloc_stats()" --batch -p $(pidof mysqld)
上述命令执行完成后，会将内存使用情况打印到 MySQL 错误日志：

#jemalloc部署
jemalloc版本5.3.0，操作系统Centos7.9
https://github.com/jemalloc/jemalloc/releases
unzip jemalloc-5.3.0
cd jemalloc-5.3.0
bash autogen.sh --prefix=/usr/local/jemalloc --libdir=/usr/lib64
make
make install
	ldconfig
[root@localhost jemalloc-5.3.0]# ldconfig -p |grep jemalloc
        libjemalloc.so.2 (libc6,x86-64) => /lib64/libjemalloc.so.2
        libjemalloc.so (libc6,x86-64) => /lib64/libjemalloc.so

Services添加如下
EnvironmentFile=-/etc/sysconfig/mysql

echo "LD_PRELOAD=libjemalloc.so" >>/etc/sysconfig/mysql
最后重启mysql

#ubuntu  systemctl 禁止分页
Bash (~/.bashrc 或 ~/.bash_profile):
bash
复制代码
export SYSTEMD_PAGER=

#itil pg表详情
-- 设计变更审批人 以及变更实施人 update20250110
SELECT * FROM changeroleusermapping WHERE changeid=3183
SELECT c.changeid,c.wfstageid,ch.description,to_timestamp(c.commentedon / 1000) AS commentedon,a.first_name 
FROM changestatuscomments c join change_statusdefinition ch on c.wfstatusid=ch.wfstatusid join aaauser a on c.commentedby=a.user_id WHERE changeid = 3183 order by commentedon

-- 变更 表详情
explain analyze SELECT * FROM changedetails order BY  changeid DESC LIMIT 200;

-- 变更理由 html
SELECT * FROM changetodescription  LIMIT 1

1724136664167
1724155200000
1724157000000
1724288030496

-- changedetails createdtime-scheduledstrttime=创建时间 completedtime-createdtime=变更关闭时间
SELECT to_timestamp((1724288030496 - 1724157000000 % 1000) / 1000) AS converted_time;

-- 用户表
SELECT * FROM aaalogin WHERE NAME LIKE '%lixl'
SELECT *FROM aaalogin WHERE user_id IN (1,9917,11113,312,24022)

-- 用户涉及登录
SELECT *from aaaaccount WHERE account_id='9613'

-- 邮箱
SELECT *from aaacontactinfo LIMIT 10

-- 变更状态类别
SELECT * FROM change_stagedefinition
SELECT *FROM  change_statusdefinition 

-- 变更id以及状态涉及的表
SELECT cd.changeid,cs.statusdisplayname, cd.wfstatusid, cs.wfstatusid FROM change_statusdefinition cs JOIN changedetails cd ON cd.wfstatusid=cs.wfstatusid

-- 变更详情 审批概览
SELECT * FROM changestatuscomments WHERE changeid = 3183 or changeid = 3180

SELECT 
  commentedon,
  to_timestamp(commentedon / 1000) AS readable_time
FROM 
  changestatuscomments WHERE changeid = 3183 or changeid = 3180;


--变更详细
--------------------------------------------------------------------------------------
function plan1需要
CREATE OR REPLACE FUNCTION longtodate(bigint)
RETURNS date AS $$
BEGIN
    RETURN to_timestamp($1 / 1000)::date; -- 将毫秒转换为日期
END;
$$ LANGUAGE plpgsql;
----------------------------------------------------------------------------------------
--plan1
SELECT chdt.CHANGEID AS "Change ID",
       chdt.TITLE AS "Title",
       longtodate(chdt.CREATEDTIME) AS "Created Time",
       ctdef.NAME AS "Change Type",
       stageDef.DISPLAYNAME AS "Stage",
       orgaaa.FIRST_NAME AS "Change Requester",
       cmDef.FIRST_NAME AS "Change Manager",
       ownaaa.FIRST_NAME AS "Change Owner",
       Approvers."Stage Time" AS "Stage Time",
       Approvers."Approvers" AS "Approvers",
       IMPLEMENTER.IMPLEMENTERS AS "IMPLEMENTER"
FROM ChangeDetails chdt
LEFT JOIN SDUser orgsd ON chdt.INITIATORID = orgsd.USERID
LEFT JOIN AaaUser orgaaa ON orgsd.USERID = orgaaa.USER_ID
LEFT JOIN SDUser ownsd ON chdt.TECHNICIANID = ownsd.USERID
LEFT JOIN AaaUser ownaaa ON ownsd.USERID = ownaaa.USER_ID
LEFT JOIN ChangeTypeDefinition ctdef ON chdt.CHANGETYPEID = ctdef.CHANGETYPEID
LEFT JOIN Change_StageDefinition stageDef ON chdt.WFSTAGEID = stageDef.WFSTAGEID
LEFT JOIN AaaUser cmDef ON chdt.CHANGEMANAGERID = cmDef.USER_ID
LEFT JOIN
  (SELECT CRUSERMAPPING.changeid,
          string_agg(AUSER.first_name, ', ') AS IMPLEMENTERS
   FROM changeroleusermapping CRUSERMAPPING
   INNER JOIN changedetails ON changedetails.changeid = CRUSERMAPPING.changeid
   LEFT JOIN changeroles CHANGEROLES ON CRUSERMAPPING.roleid = CHANGEROLES.id
   LEFT JOIN aaauser AUSER ON CRUSERMAPPING.userid = AUSER.user_id
   WHERE CHANGEROLES.name = 'Implementer'
   GROUP BY CRUSERMAPPING.changeid) IMPLEMENTER ON chdt.changeid = IMPLEMENTER.changeid
LEFT JOIN
  (SELECT c.changeid,
          MAX(to_timestamp(c.commentedon / 1000)) AS "Stage Time", -- 最后审批时间
 string_agg(a.first_name || ' (' || to_char(to_timestamp(c.commentedon / 1000), 'YYYY-MM-DD HH24:MI:SS') || ')', ', '
            ORDER BY c.commentedon DESC) AS "Approvers" -- 获取审批人及其对应时间，按时间倒序

   FROM changestatuscomments c
   JOIN change_statusdefinition ch ON c.wfstatusid = ch.wfstatusid
   JOIN aaauser a ON c.commentedby = a.user_id
   WHERE ch.wfstageid = '3'
   GROUP BY c.changeid) Approvers ON chdt.changeid = Approvers.changeid
ORDER BY chdt.CHANGEID DESC;
-----------------------------------------------------------------------------------
analyze sql
WITH implementer_cte AS (
    SELECT cm.changeid,
           string_agg(au.first_name, ', ') AS implementers
    FROM changeroleusermapping cm
    INNER JOIN changeroles cr ON cm.roleid = cr.id
    LEFT JOIN aaauser au ON cm.userid = au.user_id
    WHERE cr.name = 'Implementer'
    GROUP BY cm.changeid
),
approvers_cte AS (
    SELECT 
        c.changeid,
        MAX(to_timestamp(c.commentedon / 1000)) AS stage_time,
        string_agg(
            a.first_name || ' (' || 
            to_char(to_timestamp(c.commentedon / 1000), 'YYYY-MM-DD HH24:MI:SS') || ')',
            ', ' ORDER BY c.commentedon DESC
        ) AS approvers
    FROM changestatuscomments c
    JOIN change_statusdefinition ch ON c.wfstatusid = ch.wfstatusid
    JOIN aaauser a ON c.commentedby = a.user_id
    WHERE ch.wfstageid = '3'
    GROUP BY c.changeid
)

SELECT 
    chdt.CHANGEID AS "Change ID",
    chdt.TITLE AS "Title",
    TO_CHAR(to_timestamp(chdt.CREATEDTIME / 1000), 'YYYY-MM-DD') AS "Created Time",
    ctdef.NAME AS "Change Type",
    stageDef.DISPLAYNAME AS "Stage",
    orgaaa.FIRST_NAME AS "Change Requester",
    cmDef.FIRST_NAME AS "Change Manager",
    ownaaa.FIRST_NAME AS "Change Owner",
    a."stage_time" AS "Stage Time",
    a."approvers" AS "Approvers",
    i.implementers AS "IMPLEMENTER"
FROM ChangeDetails chdt

LEFT JOIN ChangeTypeDefinition ctdef ON chdt.CHANGETYPEID = ctdef.CHANGETYPEID
LEFT JOIN Change_StageDefinition stageDef ON chdt.WFSTAGEID = stageDef.WFSTAGEID
LEFT JOIN SDUser orgsd ON chdt.INITIATORID = orgsd.USERID
LEFT JOIN AaaUser orgaaa ON orgsd.USERID = orgaaa.USER_ID
LEFT JOIN SDUser ownsd ON chdt.TECHNICIANID = ownsd.USERID
LEFT JOIN AaaUser ownaaa ON ownsd.USERID = ownaaa.USER_ID
LEFT JOIN AaaUser cmDef ON chdt.CHANGEMANAGERID = cmDef.USER_ID
LEFT JOIN implementer_cte i ON chdt.changeid = i.changeid
LEFT JOIN approvers_cte a ON chdt.changeid = a.changeid

WHERE chdt.CHANGEID > 0
ORDER BY chdt.CHANGEID DESC;
------------------------------------------------------------------------------------
--plan2
SELECT 
    chdt.CHANGEID AS "Change ID",
    chdt.TITLE AS "Title",
    to_timestamp(chdt.CREATEDTIME / 1000) AS "Created Time",
    ctdef.NAME AS "Change Type",
    stageDef.DISPLAYNAME AS "Stage",
    orgaaa.FIRST_NAME AS "Change Requester",
    cmDef.FIRST_NAME AS "Change Manager",
    ownaaa.FIRST_NAME AS "Change Owner",
    IMPLEMENTER.IMPLEMENTERS AS "IMPLEMENTER",
    STAGES.stage_details AS "Stage Details"
FROM ChangeDetails chdt
LEFT JOIN SDUser orgsd ON chdt.INITIATORID = orgsd.USERID
LEFT JOIN AaaUser orgaaa ON orgsd.USERID = orgaaa.USER_ID
LEFT JOIN SDUser ownsd ON chdt.TECHNICIANID = ownsd.USERID
LEFT JOIN AaaUser ownaaa ON ownsd.USERID = ownaaa.USER_ID
LEFT JOIN ChangeTypeDefinition ctdef ON chdt.CHANGETYPEID = ctdef.CHANGETYPEID
LEFT JOIN Change_StageDefinition stageDef ON chdt.WFSTAGEID = stageDef.WFSTAGEID
LEFT JOIN AaaUser cmDef ON chdt.CHANGEMANAGERID = cmDef.USER_ID
LEFT JOIN (
    SELECT 
        CRUSERMAPPING.changeid,
        string_agg(AUSER.first_name, ', ') AS IMPLEMENTERS
    FROM changeroleusermapping CRUSERMAPPING
    INNER JOIN changedetails ON changedetails.changeid = CRUSERMAPPING.changeid
    LEFT JOIN changeroles CHANGEROLES ON CRUSERMAPPING.roleid = CHANGEROLES.id
    LEFT JOIN aaauser AUSER ON CRUSERMAPPING.userid = AUSER.user_id
    WHERE CHANGEROLES.name = 'Implementer'
    GROUP BY CRUSERMAPPING.changeid
) IMPLEMENTER ON chdt.changeid = IMPLEMENTER.changeid
LEFT JOIN (
    SELECT 
        c.changeid,
        string_agg(
            ch.description || ': ' || 
            to_char(to_timestamp(c.commentedon / 1000), 'YYYY-MM-DD HH24:MI:SS') || 
            ' (' || a.first_name || ')',
            ' -> ' 
            ORDER BY c.commentedon
        ) AS stage_details
    FROM changestatuscomments c
    JOIN change_statusdefinition ch ON c.wfstatusid = ch.wfstatusid
    JOIN aaauser a ON c.commentedby = a.user_id
    GROUP BY c.changeid
) STAGES ON chdt.changeid = STAGES.changeid
ORDER BY chdt.CHANGEID DESC;

--analyze sql
--------------------------------------------------------------------------------
--plan2
WITH implementer_cte AS (
    SELECT 
        CRUSERMAPPING.changeid,
        string_agg(AUSER.first_name, ', ') AS implementers
    FROM changeroleusermapping CRUSERMAPPING
    INNER JOIN changedetails ON changedetails.changeid = CRUSERMAPPING.changeid
    LEFT JOIN changeroles CHANGEROLES ON CRUSERMAPPING.roleid = CHANGEROLES.id
    LEFT JOIN aaauser AUSER ON CRUSERMAPPING.userid = AUSER.user_id
    WHERE CHANGEROLES.name = 'Implementer'
    GROUP BY CRUSERMAPPING.changeid
),
stages_cte AS (
    SELECT 
        c.changeid,
        string_agg(
            ch.description || ': ' || 
            to_char(to_timestamp(c.commentedon / 1000), 'YYYY-MM-DD HH24:MI:SS') || 
            ' (' || a.first_name || ')',
            ' -> ' 
            ORDER BY c.commentedon
        ) AS stage_details
    FROM changestatuscomments c
    JOIN change_statusdefinition ch ON c.wfstatusid = ch.wfstatusid
    JOIN aaauser a ON c.commentedby = a.user_id
    GROUP BY c.changeid
)
SELECT 
    chdt.CHANGEID AS "Change ID",
    chdt.TITLE AS "Title",
    to_timestamp(chdt.CREATEDTIME / 1000) AS "Created Time",
    ctdef.NAME AS "Change Type",
    stageDef.DISPLAYNAME AS "Stage",
    orgaaa.FIRST_NAME AS "Change Requester",
    cmDef.FIRST_NAME AS "Change Manager",
    ownaaa.FIRST_NAME AS "Change Owner",
    i.implementers AS "IMPLEMENTER",
    s.stage_details AS "Stage Details"
FROM ChangeDetails chdt
LEFT JOIN SDUser orgsd ON chdt.INITIATORID = orgsd.USERID
LEFT JOIN AaaUser orgaaa ON orgsd.USERID = orgaaa.USER_ID
LEFT JOIN SDUser ownsd ON chdt.TECHNICIANID = ownsd.USERID
LEFT JOIN AaaUser ownaaa ON ownsd.USERID = ownaaa.USER_ID
LEFT JOIN ChangeTypeDefinition ctdef ON chdt.CHANGETYPEID = ctdef.CHANGETYPEID
LEFT JOIN Change_StageDefinition stageDef ON chdt.WFSTAGEID = stageDef.WFSTAGEID
LEFT JOIN AaaUser cmDef ON chdt.CHANGEMANAGERID = cmDef.USER_ID
LEFT JOIN implementer_cte i ON chdt.changeid = i.changeid
LEFT JOIN stages_cte s ON chdt.changeid = s.changeid
ORDER BY chdt.CHANGEID DESC;

CREATE INDEX IF NOT EXISTS idx_changedetails_changeid ON ChangeDetails(CHANGEID);
CREATE INDEX IF NOT EXISTS idx_changedetails_created ON ChangeDetails(CREATEDTIME);
CREATE INDEX IF NOT EXISTS idx_changeroleusermapping_changeid ON changeroleusermapping(changeid);
CREATE INDEX IF NOT EXISTS idx_changestatuscomments_changeid ON changestatuscomments(changeid);




---------------------------------------------------------------------------------------------------
--MAX(to_timestamp(c.commentedon / 1000)) AS "Stage Time", -- 最后审批时间
SELECT c.changeid,
       TO_CHAR(to_timestamp(MAX(c.commentedon) / 1000), 'YYYY-MM-DD') AS "Stage Time",
       string_agg(a.first_name || ' (' || to_char(to_timestamp(c.commentedon / 1000), 'YYYY-MM-DD HH24:MI:SS') || ')', ', '
            ORDER BY c.commentedon DESC) AS "Approvers"
FROM changestatuscomments c
JOIN change_statusdefinition ch ON c.wfstatusid = ch.wfstatusid
JOIN aaauser a ON c.commentedby = a.user_id
WHERE ch.wfstageid = '3'
GROUP BY c.changeid
ORDER BY c.changeid DESC;


chmod u+w /etc/sudoers
itwb_hongsheng ALL=(ALL) ALL
chmod u-w /etc/sudoers


innodb_max_dirty_pages_pct = 0 #设置为 0，表示禁用脏页的使用，即在页面变为脏页之前，InnoDB 会将缓冲池中的数据刷新到磁盘。
innodb_fast_shutdown = 0 #表示 InnoDB 会进行更加彻底的关机，确保所有脏页都写入磁盘，所有内部数据结构都被清理。

https://kkjiasu.top/api/v1/client/subscribe?token=9fcc82f52c98c4d480a0eb2815048712

https://cpdd.one/sub?token=6ddcc2d3e9c9d089ea63e066c4f3f4d6

鼎甲8.0还原 取相应版本的xtrabackup（backup）或者 xbstream（restore）
还原：鼎甲需映射 xbstream -> xbstream-8.0 鼎甲取参(xbstream-8.0),需新版copy，最终应用是xbstream 需做 ln -s
备份：新版copy(xtrabackup-8.0)到bin目录，需映射 xbstream -> xtrabackup-8.0;
5.7保持 xbstream -> xtrabackup-8.0 即可。
undo参数初始化后调整参数有异常，需删掉undo tablespace，可直接删除/data 空间

1.xtraback原理 2.高可用相关mha原理架构 3.隔离级别 唯一索引出发锁机制 4.主从原理 sql线程算法（？）5.监控指标 6.死锁监控 7.故障处理 8.ddl 9.innodb特性 八股文 10.btree索引原理 pg 1.常用系统表以及视图 2.高可用 3.体系架构

SELECT
*
FROM sys.procedures s
JOIN sys.dm_exec_procedure_stats d ON s.object_id = d.object_id
WHERE s.name = 'Lacommission_add'
;

select top 100 * from sys.dm_exec_query_stats as d cross apply sys.dm_exec_sql_text(d.sql_handle) as dm where dm.objectid=1483868353

select * from sys.dm_exec_query_plan(0x05000500C108725840A19EE8010000000000000000000000)

mysqlsh沙盒
mysql-js> dba.deploySandboxInstance(3307, {sandboxDir: '/custom/path'})
或全局设置（后续所有沙盒均生效）：
mysql-js> shell.options.sandboxDir = '/custom/path'
附加配置
mysql-js> dba.deploySandboxInstance(3307, {
  mysqldOptions: ["max_connections=500", "slow_query_log=1"]
})1

mysql-js> dba.startSandboxInstance(3307)  // 启动
mysql-js> dba.stopSandboxInstance(3307)   // 停止

删除实例（需先停止）
mysql-js> dba.deleteSandboxInstance(3307)



systemctl命令tab自动补全
yum install -y bash-completion


尝试使用 gdb 获取锁等待信息
ps aux | grep 端口号，找出mysqld进程号 pid，pstack pid > stack.log
在stack.log中搜索 acquire_lock（请求mdl锁的函数） thread 3 在请求元数据锁

gdb -p pid
thread 3
切换到目标线程


./sql/mysqld --basedir=$(pwd) --datadir=/data/debugdb/5.7/data \
             --socket=/tmp/mysql_debug.sock --port=3317 \
             --log-error=/data/debugdb/5.7/mysqld.log \
             --pid-file=/data/debugdb/5.7/mysqld.pid \
			 --lc-messages-dir=$(pwd)/share \
             --lc-messages=english \
             --explicit_defaults_for_timestamp=1 &
			 
git sync remote
# 更新或新增文件后
git add .
git commit -m "更新 a.txt，新增 c.txt"
git push -u origin master
推送到github

--git push --set-upstream master

 git rm --cached percona-qa #不在跟踪此目录

#username 主体更改
 git remote -v
 git remote set-url origin  [newname]