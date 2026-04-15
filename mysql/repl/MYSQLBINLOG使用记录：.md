### MYSQLBINLOG使用记录：

恢复大表的数据误操作，binlog_format模式必须是ROW模式，可以使用binlog2sql工具

```csharp
//安装包
https://github.com/danfengcao/binlog2sql.git 
```

**安装教程：**

```sql
、？

[root@db01 binlog2sql]# pwd
/root/binlog2sql
[root@db01 binlog2sql]# ls
binlog2sql  example  LICENSE  README.md  requirements.txt  tests

安装python3环境：
yum install python3

修改requirements.txt：
[root@db01 binlog2sql]# cat requirements.txt
PyMySQL==0.7.11
wheel==0.29.0
mysql-replication==0.13

安装依赖：
把PyMySQL==0.7.11修改为：PyMySQL==0.9.3
pip3 install -r requirements.txt
pip3 show pymysql

可选：
连接mysql8.0后，升级pymysql至最新版本，上一步修改了就不用执行了
升级最新版本：
-- pip3 install --upgrade PyMySQL  
```

**binlog2sql****的使用参数说明：**

**mysql****连接配置**

```sql
-h host; -P port; -u user; -p password
```

**解析模式**

- --stop-never 持续同步binlog。可选。不加则同步至执行命令时最新的binlog位置。
- -K, --no-primary-key 对INSERT语句去除主键。可选。

- -B, --flashback 生成回滚语句，可解析大文件，不受内存限制，每打印一千行加一句SLEEP SELECT(1)。可选。与stop-never或no-primary-key不能同时添加。

**解析范围控制**

- --start-file 起始解析文件。必须。
- --start-position/--start-pos start-file的起始解析位置。可选。默认为start-file的起始位置。

- --stop-file/--end-file 末尾解析文件。可选。默认为start-file同一个文件。若解析模式为stop-never，此选项失效。

- --stop-position/--end-pos stop-file的末尾解析位置。可选。默认为stop-file的最末位置；若解析模式为stop-never，此选项失效。

- --start-datetime 从哪个时间点的binlog开始解析，格式必须为datetime，如'2016-11-11 11:11:11'。可选。默认不过滤。

- --stop-datetime 到哪个时间点的binlog停止解析，格式必须为datetime，如'2016-11-11 11:11:11'。可选。默认不过滤。

**对象过滤**

- -d, --databases 只输出目标db的sql。可选。默认为空。
- -t, --tables 只输出目标tables的sql。可选。默认为空。

```sql
[root@postgre binlog2sql]# python3 binlog2sql.py --help
usage: binlog2sql.py [-h HOST] [-u USER] [-p [PASSWORD [PASSWORD ...]]]
                     [-P PORT] [--start-file START_FILE]
                     [--start-position START_POS] [--stop-file END_FILE]
                     [--stop-position END_POS] [--start-datetime START_TIME]
                     [--stop-datetime STOP_TIME] [--stop-never] [--help]
                     [-d [DATABASES [DATABASES ...]]]
                     [-t [TABLES [TABLES ...]]] [--only-dml]
                     [--sql-type [SQL_TYPE [SQL_TYPE ...]]] [-K] [-B]
                     [--back-interval BACK_INTERVAL]

Parse MySQL binlog to SQL you want

optional arguments:
  --stop-never          Continuously parse binlog. default: stop at the latest
                        event when you start.
  --help                help information
  -K, --no-primary-key  Generate insert sql without primary key if exists
  -B, --flashback       Flashback data to start_position of start_file
  --back-interval BACK_INTERVAL
                        Sleep time between chunks of 1000 rollback sql. set it
                        to 0 if do not need sleep

connect setting:
  -h HOST, --host HOST  Host the MySQL database server located
  -u USER, --user USER  MySQL Username to log in as
  -p [PASSWORD [PASSWORD ...]], --password [PASSWORD [PASSWORD ...]]
                        MySQL Password to use
  -P PORT, --port PORT  MySQL port to use

interval filter:
  --start-file START_FILE
                        Start binlog file to be parsed
  --start-position START_POS, --start-pos START_POS
                        Start position of the --start-file
  --stop-file END_FILE, --end-file END_FILE
                        Stop binlog file to be parsed. default: '--start-file'
  --stop-position END_POS, --end-pos END_POS
                        Stop position. default: latest position of '--stop-
                        file'
  --start-datetime START_TIME
                        Start time. format %Y-%m-%d %H:%M:%S
  --stop-datetime STOP_TIME
                        Stop Time. format %Y-%m-%d %H:%M:%S;

schema filter:
  -d [DATABASES [DATABASES ...]], --databases [DATABASES [DATABASES ...]]
                        dbs you want to process
  -t [TABLES [TABLES ...]], --tables [TABLES [TABLES ...]]
                        tables you want to process

type filter:
  --only-dml            only print dml, ignore ddl
  --sql-type [SQL_TYPE [SQL_TYPE ...]]
                        Sql type you want to process, support INSERT, UPDATE,
                        DELETE.
```

 /data/mysql_basedir_3306/bin/mysqlbinlog --start-datetime='2023-08-04 00:00:00' --stop-datetime='2023-08-04 09:40:00' /data/mysql_3306/binlog/mysql-bin.000053 --database test --base64-output=decode-rows -vv --skip-gtids=true | grep -C 10 -i 'DELETE FROM `test`.`customer`'

 ```sql
 //解析删除语句
 [root@postgre binlog2sql]# python3 binlog2sql.py -ulixl -plixl -d nglicps2 -t user_t --start-file='mysql-bin.000034' --sql-type delete
 DELETE FROM `nglicps2`.`user_t` WHERE `id`=8 AND `user_name`='aaa' AND `password` IS NULL AND `age`=20 LIMIT 1; #start 251686524 end 251686849 time 2023-06-02 16:11:15
 DELETE FROM `nglicps2`.`user_t` WHERE `id`=9 AND `user_name`='bbb' AND `password` IS NULL AND `age`=30 LIMIT 1; #start 251686524 end 251686849 time 2023-06-02 16:11:15
 DELETE FROM `nglicps2`.`user_t` WHERE `id`=10 AND `user_name`='aaa' AND `password` IS NULL AND `age`=20 LIMIT 1; #start 251686524 end 251686849 time 2023-06-02 16:11:15
 DELETE FROM `nglicps2`.`user_t` WHERE `id`=11 AND `user_name`='bbb' AND `password` IS NULL AND `age`=30 LIMIT 1; #start 251686524 end 251686849 time 2023-06-02 16:11:15
 DELETE FROM `nglicps2`.`user_t` WHERE `id`=12 AND `user_name`='aaa' AND `password` IS NULL AND `age`=20 LIMIT 1; #start 251686524 end 251686849 time 2023-06-02 16:11:15
 DELETE FROM `nglicps2`.`user_t` WHERE `id`=13 AND `user_name`='bbb' AND `password` IS NULL AND `age`=30 LIMIT 1; #start 251686524 end 251686849 time 2023-06-02 16:11:15
 //回滚两种办法：
 一、直接执行生成的语句
 二、导出到文件，进入mysql中进行恢复
 三、可增加（--sql-type=delete --start-position=2698 --stop-position=3514 -B > /root/city_delete.sql）
 [root@postgre binlog2sql]# python3 binlog2sql.py -ulixl -plixl -d nglicps2 -t user_t --start-file='mysql-bin.000034' -B
 INSERT INTO `nglicps2`.`user_t`(`id`, `user_name`, `password`, `age`) VALUES (13, 'bbb', NULL, 30); #start 251686524 end 251686849 time 2023-06-02 16:11:15
 INSERT INTO `nglicps2`.`user_t`(`id`, `user_name`, `password`, `age`) VALUES (12, 'aaa', NULL, 20); #start 251686524 end 251686849 time 2023-06-02 16:11:15
 INSERT INTO `nglicps2`.`user_t`(`id`, `user_name`, `password`, `age`) VALUES (11, 'bbb', NULL, 30); #start 251686524 end 251686849 time 2023-06-02 16:11:15
 INSERT INTO `nglicps2`.`user_t`(`id`, `user_name`, `password`, `age`) VALUES (10, 'aaa', NULL, 20); #start 251686524 end 251686849 time 2023-06-02 16:11:15
 INSERT INTO `nglicps2`.`user_t`(`id`, `user_name`, `password`, `age`) VALUES (9, 'bbb', NULL, 30); #start 251686524 end 251686849 time 2023-06-02 16:11:15
 INSERT INTO `nglicps2`.`user_t`(`id`, `user_name`, `password`, `age`) VALUES (8, 'aaa', NULL, 20); #start 251686524 end 251686849 time 2023-06-02 16:11:15
 ```

远程使用

 ```sql
 例如：我的mysql服务器是192.168.0.51，我使用远程主机连接
 远程访问，加上-h -P参数
 [root@db02 binlog2sql]# python3 binlog2sql.py -h 192.168.0.51 -P3306 -uroot -p123456 -d world -t city --start-file='binlog.000001'
 [root@db02 binlog2sql]# python3 binlog2sql.py -h 192.168.0.51 -P3306 -uroot -p123456 -d world -t city --start-file='binlog.000001' --sql-type=update --start-position=15935 --stop-position=16178 -B > /root/city_update.sql
 ```







查看BINLOG事务大小：

```sql
[root@postgre binlog]# /data/mysql_basedir_3306/bin/mysqlbinlog mysql-bin.000033 |grep "GTID$(printf '\t')last_committed" -B 1|head -n 10
# at 194
#230602 14:16:07 server id 2130706431  end_log_pos 259 CRC32 0x25874865         GTID    last_committed=0        sequence_number=1       rbr_only=yes
--
# at 3053
#230602 14:16:07 server id 2130706431  end_log_pos 3118 CRC32 0x6c5c848a        GTID    last_committed=1        sequence_number=2       rbr_only=yes
--
# at 5910
#230602 14:16:07 server id 2130706431  end_log_pos 5975 CRC32 0xf4e1c4e9        GTID    last_committed=1        sequence_number=3       rbr_only=yes
--
# at 23338
```

（过滤信息且两行数据相减得出每个事物大小）

```sql
[root@postgre binlog]# /data/mysql_basedir_3306/bin/mysqlbinlog mysql-bin.000033 |grep "GTID$(printf '\t')last_committed" -B 1|grep -E '^# at'|awk '{print $3}' |awk 'NR==1 {tmp=$1} NR>1 {print ($1-tmp);tmp=$1}'|sort -n -r |head -n 10 
40334
40000
39603
39492
39391
39390
39325
39272
39254
39251
```

浅析

```sql
[root@postgre binlog]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000034 --database nglicps2 --base64-output=decode-rows -vv --skip-gtids=true | grep -C 1 -i "DELETE FROM nglicps2.cps_transactions_his"
#230602 15:42:54 server id 2130706431  end_log_pos 251684716 CRC32 0x1e62252a   Rows_query
# DELETE FROM nglicps2.cps_transactions_his
# WHERE id = 37
--
#230602 15:43:16 server id 2130706431  end_log_pos 251685652 CRC32 0x2e435600   Rows_query
# DELETE FROM nglicps2.cps_transactions_his
# WHERE id = 38
```

- /data/mysql_3306/binlog/mysql-bin.000034： 需要解析的 binlog 日志。
- database： 只列出该数据库下的行数据，但无法过滤 Rows_query_event。
- base64-output=decode-rows -vv：显示具体 SQL 语句。
- skip-gtids=true：忽略 GTID 显示。
- grep -C 1 -i "delete from dataex_trigger_record"：通过管道命令筛选出所需 SQL 及执行时间。
- /opt/sql.log：将结果导入到日志文件，方便查看。

//\1. 如果不确定 SQL 格式或是无法筛选到数据，比如因为 delete from 中间冷不丁多一个空格出来， 可以使用 grep 多次过滤筛选，比如： grep -C 1 -i "Rows_query" | grep -C 1 -i "Audit_Orga_Specialtype" | grep -C 1 -i "delete" 筛选对应表上的 delete 操作。 2. 触发器执行的 SQL 不会记录在 Rows_query_event 中，只会记录对应的行数据。 3. --database 是无法过滤 rows_query_event 的，只可以过滤行数据。//



直观查看组提交信息

```sql
[root@postgre bin]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000029 |grep -a 'last_commit'|head -n 10
#230628  9:58:36 server id 2130706431  end_log_pos 259 CRC32 0xc35ce733         GTID    last_committed=0        sequence_number=1       rbr_only=no
#230628  9:58:37 server id 2130706431  end_log_pos 429 CRC32 0x825a220f         GTID    last_committed=1        sequence_number=2       rbr_only=no
#230628  9:58:37 server id 2130706431  end_log_pos 603 CRC32 0x6779114a         GTID    last_committed=2        sequence_number=3       rbr_only=no
#230628  9:58:37 server id 2130706431  end_log_pos 811 CRC32 0x7498d6c8         GTID    last_committed=3        sequence_number=4       rbr_only=yes
#230628  9:58:37 server id 2130706431  end_log_pos 1392 CRC32 0x56ae785a        GTID    last_committed=4        sequence_number=5       rbr_only=yes
#230628  9:58:37 server id 2130706431  end_log_pos 1972 CRC32 0x4271de47        GTID    last_committed=5        sequence_number=6       rbr_only=yes
#230628  9:58:37 server id 2130706431  end_log_pos 2553 CRC32 0x52b98a89        GTID    last_committed=6        sequence_number=7       rbr_only=yes
#230628  9:58:37 server id 2130706431  end_log_pos 3133 CRC32 0xd4d70fa1        GTID    last_committed=7        sequence_number=8       rbr_only=yes
#230628  9:58:37 server id 2130706431  end_log_pos 3714 CRC32 0x17c3955f        GTID    last_committed=8        sequence_number=9       rbr_only=yes
#230628  9:58:37 server id 2130706431  end_log_pos 4294 CRC32 0x7882e0ba        GTID    last_committed=9        sequence_number=10      rbr_only=yes
```

查看事务数

```sql
[root@postgre bin]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000029 |grep -a 'last_commit'| awk '{print $11}'|wc -l
200521
[root@postgre bin]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000029 |grep -a 'last_commit'| awk '{print $11}'|uniq|wc -l
166960
```

