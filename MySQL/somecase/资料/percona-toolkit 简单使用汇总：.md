# percona-toolkit 简易汇总：

# 参考文档：

[Percona Toolkit Documentation — Percona Toolkit Documentation](https://docs.percona.com/percona-toolkit/)

## pt-align

### 简述：

​	功能是将其他工具的输出格式化成字段列。

### 例：

![image-20240319140119081](C:\Users\itwb_lixl\AppData\Roaming\Typora\typora-user-images\image-20240319140119081.png)

## pt-archiver

### 简述：

​	将MySQL表中的行鬼归档到另一个表或文件中。参考：[pt-archiver归档工具的使用详解-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1508825?areaSource=102001.15&traceId=7BS2lE17HTG_PDeUYIYFE)

### 例：

[root@informatica bin]# ./pt-archiver --source h=172.18.100.74,u=root,p=123,P=3306,D=prd_aes,t=sm_cfgtable_err \

> --dest h=192.168.97.51,P=3306,u=lixl,p=lixl,D=e,t=sm_cfgtable_err \
> --progress 5000 --where "1=1" \
> --statistics --charset=UTF8 --limit=10000 --txn-size 1000 --no-delete  --bulk-insert --no-check-charset
> TIME                ELAPSED   COUNTl
> 2024-03-19T14:51:29       0       0
> 2024-03-19T14:51:29       0    1988
> Started at 2024-03-19T14:51:29, ended at 2024-03-19T14:51:33
> Source: A=UTF8,D=prd_aes,P=3306,h=172.18.100.74,p=...,t=sm_cfgtable_err,u=root
> Dest:   A=UTF8,D=e,P=3306,h=192.168.97.51,p=...,t=sm_cfgtable_err,u=lixl
> SELECT 1988
> INSERT 1988
> DELETE 0
> Action              Count       Time        Pct
> bulk_inserting          1     3.4237      93.47
> commit                  4     0.0641       1.75
> select                  2     0.0052       0.14
> print_bulkfile       1988     0.0008       0.02
> other                   0     0.1690       4.61

### 注：

1. 案例source表中有1989条数据、pt-archiver会默认对自增列字段的最大值“max(id)”的数据进项保护、不归档也不删除；目的是为了防止auto_increment值重置，防止数据冲突、一旦该值重置、会出现相同自增ID，会导致下一次的归档失败，影响归档简洁影响业务。--nosafe-auto-increment此参数可解决归档部分数据时包含自增列auto_increment字段最大值。只做归档不删除数据的情况下可以一直使用此参数--nosafe-auto-increment，8.0版本不会重置auto_increment
2. 数据库参数要set global local_infile=on; 参数意义：能否使用load data local infile命令。source dest都要配置。否则会报错`DBD::mysql::st execute failed: Loading local data is disabled; this must be enabled on...`



## pt-config-diff

### 简述：

用于my.cnf配置文件和show global variables系统变量之间的对比。

### 例：

```sql
[root@dingjia-mysql bin]# ./pt-config-diff /data/mysql/etc/my.cnf /data/mysql8/etc/my.cnf
13 config differences
Variable                  /data/mysql/etc/my.cnf    /data/mysql8/etc/my.cnf
========================= ========================= =========================
basedir                   /usr/local/mysql          /usr/local/mysql8
datadir                   /data/mysql/data          /data/mysql8/data
general_log_file          /data/mysql/log/mysql-... /data/mysql8/log/mysql...
log_bin                   /data/mysql/binlog/mys... /data/mysql8/binlog/my...
log_bin_index             /data/mysql/binlog/mys... /data/mysql8/binlog/my...
log_error                 /data/mysql/log/mysql-... /data/mysql8/log/mysql...
port                      3306                      3308
relay_log                 /data/mysql/binlog/rel... /data/mysql8/binlog/re...
relay_log_index           /data/mysql/binlog/rel... /data/mysql8/binlog/re...
```



```sql
[root@dingjia-mysql bin]# ./pt-config-diff --report-width=200 h=172.18.100.59,P=3306,u=root,p=123 h=172.18.100.74,P=3306,u=root,p=123
119 config differences
Variable                   dingjia-mysql                                                                          informatica
========================== ====================================================================================== ======================================================================================
basedir                    /usr/local/mysql/                                                                      /data/mysql_3306/
bind_address               0.0.0.0                                                                                *
binlog_cache_size          2097152                                                                                4194304
binlog_group_commit_syn... 1000                                                                                   0
binlog_group_commit_syn... 10                                                                                     0
binlog_rows_query_log_e... OFF                                                                                    ON
binlog_transaction_depe... COMMIT_ORDER                                                                           WRITESET
bulk_insert_buffer_size    8388608                                                                                67108864
character_set_system       utf8                                                                                   utf8mb3
character_sets_dir         /usr/local/mysql/share/charsets/                                                       /data/mysql_3306/share/charsets/
collation_connection       utf8mb4_general_ci                                                                     utf8mb4_0900_ai_ci
collation_database         utf8mb4_general_ci                                                                     utf8mb4_0900_ai_ci
collation_server           utf8mb4_general_ci                                                                     utf8mb4_0900_ai_ci
core_file                  ON                                                                                     OFF
default_authentication_... mysql_native_password                                                                  caching_sha2_password
event_scheduler            OFF                                                                                    ON
expire_logs_days           7                                                                                      0
general_log_file           /data/mysql/log/mysql-general.log                                                      /data/mysql/data/informatica.log
gtid_executed              6f41d1c4-e1d7-11ee-807e-0050568a1004:1-3                                               1ea7b6cf-4581-11ee-b81a-0050568a1004:1-831, 6f33e41f-b126-11ee-9eba-0050568a78f2:1-...
...
```



## pt-deadlock-logger

[MySQL ：： MySQL 8.0 参考手册 ：： 17.7.5.1 InnoDB 死锁示例](https://dev.mysql.com/doc/refman/8.0/en/innodb-deadlock-example.html)

### 简述：

收集和保存mysql上最近的死锁信息，可以直接打印死锁信息和存储死锁信息到数据库中，死锁信息包括发生死锁的服务器、最近发生死锁的时间、死锁线程id、死锁的事务id、发生死锁时事务执行了多长时间等等非常多的信息。

### 例：

```sql
root@myos:/data/percona-toolkit-3.0.11/bin# ./pt-deadlock-logger -u lixl -p lixl D=my_t,t=deadlocks

# A software update is available:
server ts thread txn_id txn_time user hostname ip db tbl idx lock_type lock_mode wait_hold victim query
myos 2024-11-20T11:12:42 35 0 70 root localhost  my_t Animals PRIMARY RECORD X w 0 UPDATE Animals SET value=30 WHERE name='Aardvark'
myos 2024-11-20T11:12:42 36 0 81 root localhost  my_t Birds PRIMARY RECORD X w 1 UPDATE Birds SET value=40 WHERE name='Buzzard'
```

也可以存在表里，innodb支持 `innodb_print_all_deadlocks`参数可以将死锁输出到错误日志中，此方法比较常见
