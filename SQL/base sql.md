备份有关：

```sql
mysqldump -h192.168.88.132 -ulixl -p --single-transaction --skip-opt --databases bioinfo --triggers --routines --events --master-data=2 --delete-master-logs --add-drop-database --create-options --complete-insert --extended-insert --disable-keys --set-charset --tz-utc --quick --log-error=/root/bioinfo_error.txt > /root/bioinfo_backup_20220615.sql

mysqldump -h192.168.99.41 -uroot -p --single-transaction --skip-opt --databases sign --triggers --routines --events --master-data=2 --delete-master-logs --add-drop-database --create-options --complete-insert --extended-insert --disable-keys --set-charset --tz-utc --quick --log-error=/root/sign_error.txt > /root/sign_backup_20220222.sql

# 恢复
mysqldump -h192.168.99.53 -uroot -p </root/sign_backup_20220222.sql

# 截取position位置并导出sql
/usr/local/mysql/bin/mysqlbinlog  --start-position="486" /usr/local/mysql/data/mysql-bin.000138 >/138.sql
```



用户权限：

```sql
# with grant option 通过在grant语句的最后使用该子句，就允许被授权的用户把得到的权限继续授给其它用户
grant select on `evoicecs`.* to readonly@'%' with grant option;  -- GRANT ALL PRIVILEGES ON `sign`.* TO 'proxysql'@'%'
FLUSH PRIVILEGES;

# 当用户对同一数据库同时具备 USAGE 和 GRANT OPTION 两种权限时，就会出现冲突。此时便可以查看到该数据库以及库下所有表的信息，但无法查看表内具体数据。
GRANT USAGE ON *.* TO 'hjm'@'%';
GRANT USAGE ON `test`.* TO 'hjm'@'%' WITH GRANT OPTION;

# 回收GRANT OPTION 权限
REVOKE GRANT OPTION on test.* from 'hjm'@'%' ;
```

```sql
# 复制权限
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'
```

```sql
# 备份权限5.7x
alter user 'root'@'localhost' identified by 'P@ssw0rd001!';
CREATE USER 'bkpuser'@'%' IDENTIFIED BY 'P3QaaQPhby)D';
GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO'bkpuser'@'%';
FLUSH PRIVILEGES;

# 备份权限8.0x
CREATE USER 'bkpuser'@'%' IDENTIFIED BY 'Password001';
GRANT BACKUP_ADMIN, PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'bkpuser'@'%'; 
GRANT SELECT ON performance_schema.log_status TO 'bkpuser'@'%';
GRANT SELECT ON performance_schema.keyring_component_status TO bkpuser@'%';
FLUSH PRIVILEGES;
```

```sql
# lock
SELECT  r.trx_id，waiting_trx_id,  r.trx_mysql_thread_idwaiting_thread, r.trx_query waiting_query,  b.trx_id，blocking_trx_id, b.trx_mysql_thread_id，blocking_thread,  
b.trx_query，blocking_query
FROM performance_schema.data_lock_waits w
INNER JOIN information_schema.innodb_trx b  ON b.trx_id = w.blocking_engine_transaction_idINNER JOIN information_schema.innodb_trx r  ON r.trx_id = w.requesting_engine_transaction_id;

SELECT  waiting_trx_id, waiting_pid,  waiting_query,  blocking_trx_id, blocking_pid, blocking_query
FROM sys.innodb_lock_waits;
```

```sql
# 字符排序
CREATE DATABASE `pos_secondarywriting` CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';
select schema_name,default_character_set_name,default_collation_name from information_schema.schemata where schema_name = 'pos_secondarywriting';
```

```sql
# 修改库字符集
ALTER DATABASE testg DEFAULT CHARACTER SET utf8mb4
```

```sql
# 某张表只读指定字段 update类似 grant update(empno,job) on testg.emp to readonly;
grant select(empno,job) on testg.emp to readonly;
flush privileges;
```

```sql
# percona
CREATE USER 'pmm'@'127.0.0.1' IDENTIFIED BY '2&Ru@bbMT' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'127.0.0.1';
```

```sql
# 用户有效期
create user loge@'%' identified by '123456' password expire interval 90 day;
alter user loge@'%' identified by '123456' password expire interval 90 day;

# 禁用过期，永久不过期：
create user loge@'%' identified by '123456' password expire never;
alter user loge@'%' identified by '123456' password expire never;

# 手动强制某个用户密码过期
ALTER USER 'loge'@'%' PASSWORD EXPIRE;
```

```sql
```





pt：

```sql
# pt主从数据一致性校验
pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=area.checksums --create-replicate-table --databases=area --tables=haha h=192.168.88.129,u=lixl,p=lixl,P=3306
./pt-table-checksum --nocheck-replication-filters --no-check-binlog-format --replicate=testa.checksums --create-replicate-table --databases=testa  h=172.18.100.59,u=root,p=Cmbjx3ccwtn9,P=3308
```

```sql
# 修复不一致数据 打印主从表信息不一致语句 --execute参数直接修复 生产不建议
pt-table-sync --replicate=area.checksums h=192.168.88.129,u=lixl,p=lixl h=192.168.88.129,u=lixl,p=lixl --print
./pt-table-sync --replicate=testa.checksums h=172.18.100.59,P=3308,u=root,p='Cmbjx3ccwtn9' h=172.18.100.74,P=3306,u=root,p='Cmbjx3ccwtn9' --print
```

```sql
# 修复主从错误 error-numbers报错编码
# 注意、此工具可以修复io sql线程均为yes状态、但是不能彻底恢复、通过校验数据完整性需要手工修复
pt-slave-restart --user=root --password='qwerty1!' --socket=/data/mysql8/socket/mysql.sock --error-numbers=1062
./pt-slave-restart --user=root --password='Cmbjx3ccwtn9' --socket=/data/mysql/mysql_sock/mysql.sock --error-numbers=1050
```

```sql
#主从延迟监控 在主库上创建后台update进程
pt-heartbeat -ulixl -plixl -D area --create-table --update --daemonize
```

```sql
#server-id指向主库 其他从库 --interval 1s
pt-heartbeat -ulixl -plixl -D area --table=heartbeat --master-server-id=1  --monitor -h 192.168.88.133 --interval=1
```

```sql
#在线ddl
pt-online-schema-change --user=lixl --password=lixl --host=192.168.88.129 --alter="modify column comn decimal(8,2)" D=jobdata,t=emp --execute --nocheck-replication-filters
ALTER TABLE `test11` modify COLUMN  `ucid` bigint(20) NOT NULL DEFAULT 0 COMMENT '线索ucid';
ALTER TABLE li_pb_input_item MODIFY COLUMN READONLY VARCHAR(12) NOT NULL AFTER id
ALTER TABLE li_pb_input_item RENAME TO li_pb_input_item_up
```

```sql
#添加主键id自增无符号
ALTER TABLE pay_detail_copy_1 ADD COLUMN id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
```





ghost：（<font color='cornflowerblue'>专栏ghost与pt-online-schema-change.md</font>）

```sql
gh-ost \
--max-load=Threads_running=20 \
--critical-load=Threads_running=50 \
--critical-load-interval-millis=5000 \
--chunk-size=1000 \
--user="root" \
--password='' \
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
```



plugin_clone： [https://dev.mysql.com/doc/refman/8.0/en/clone-plugin-remote.html]

```sql
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
```



GTID POSITION：

```sql
change master to master_host='10.67.33.136' ,master_user='repl',master_password='repl',master_auto_position=1;

change master to master_host='172.18.100.194' ,master_user='repl',master_password='2&Ru@bbMT',master_auto_position=1;

58e6250d-356f-11ec-982c-000c29bb216a:1-6694556,
612c68db-7da3-11ec-8daa-000c296e8b4d:7-76,
b3972d82-5c69-11eb-a08e-525400b8eba7:19184702-19361245

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
```

