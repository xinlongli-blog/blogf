# 管理脚本

- SQL 基于 Oracle MySQL 5.7 版本
- SQL 使用场景包含会话连接、元数据锁、全局锁、锁等待、长事务、内存监控、分区表、低频更新 表、主键、索引、存储引擎、实时负载

## 1	连接相关：

查看某用户连接的会话级别参数设置及状态变量，用于观测其它会话连接行为，辅助定位连接类问题。 例：查看用户连接 ID 为 14 的字符集设置，也可不指定 PROCESSLIST_ID 条件，查看所有用户连接 

```sql
[root@postgre ~]# mysql -ulixl -p
..

 SELECT T1.VARIABLE_NAME,
     T1.VARIABLE_VALUE,
     T2.PROCESSLIST_ID,
     concat(T2.PROCESSLIST_USER,"@",T2.PROCESSLIST_HOST),
     T2.PROCESSLIST_DB,
     T2.PROCESSLIST_COMMAND
    FROM PERFORMANCE_SCHEMA.VARIABLES_BY_THREAD T1,
     PERFORMANCE_SCHEMA.THREADS T2
    WHERE T1.THREAD_ID = T2.THREAD_ID
     AND T1.VARIABLE_NAME LIKE 'character%'
     AND PROCESSLIST_ID ='14';
+-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
| VARIABLE_NAME            | VARIABLE_VALUE | PROCESSLIST_ID | concat(T2.PROCESSLIST_USER,"@",T2.PROCESSLIST_HOST) | PROCESSLIST_DB     | PROCESSLIST_COMMAND |
+-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
| character_set_client     | gbk            |             14 | lixl@192.168.97.91                                  | performance_schema | Sleep               |
| character_set_connection | gbk            |             14 | lixl@192.168.97.91                                  | performance_schema | Sleep               |
| character_set_database   | utf8           |             14 | lixl@192.168.97.91                                  | performance_schema | Sleep               |
| character_set_filesystem | binary         |             14 | lixl@192.168.97.91                                  | performance_schema | Sleep               |
| character_set_results    |                |             14 | lixl@192.168.97.91                                  | performance_schema | Sleep               |
| character_set_server     | utf8           |             14 | lixl@192.168.97.91                                  | performance_schema | Sleep               |
+-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
6 rows in set (0.00 sec)
```

例：发现用户 ID 为 14 的连接关闭了 sql_log_bin 设置

```sql
 SELECT T1.VARIABLE_NAME,
     T1.VARIABLE_VALUE,
     T2.PROCESSLIST_ID,
     concat(T2.PROCESSLIST_USER,"@",T2.PROCESSLIST_HOST) AS 'User@Host',
     T2.PROCESSLIST_DB,
     T2.PROCESSLIST_COMMAND
    FROM PERFORMANCE_SCHEMA.VARIABLES_BY_THREAD T1,
     PERFORMANCE_SCHEMA.THREADS T2
    WHERE T1.THREAD_ID = T2.THREAD_ID
     AND T1.VARIABLE_NAME LIKE 'sql_log_bin';
+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
| VARIABLE_NAME | VARIABLE_VALUE | PROCESSLIST_ID | User@Host          | PROCESSLIST_DB     | PROCESSLIST_COMMAND |
+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
| sql_log_bin   | OFF            |             14 | lixl@192.168.97.91 | performance_schema | Sleep               |
| sql_log_bin   | ON             |             67 | lixl@localhost     | NULL               | Query               |
| sql_log_bin   | ON             |            121 | pmm@192.168.97.222 | NULL               | Sleep               |
| sql_log_bin   | ON             |            122 | pmm@192.168.97.222 | NULL               | Sleep               |
| sql_log_bin   | ON             |            125 | pmm@192.168.97.222 | NULL               | Sleep               |
+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
5 rows in set (0.00 sec)
```

例：查看用户连接 ID 为166 的网络流量变化

```sql
 SELECT T1.VARIABLE_NAME,
     T1.VARIABLE_VALUE,
     T2.PROCESSLIST_ID,
     concat(T2.PROCESSLIST_USER,"@",T2.PROCESSLIST_HOST) AS 'User@Host',
     T2.PROCESSLIST_DB,
     T2.PROCESSLIST_COMMAND
    FROM PERFORMANCE_SCHEMA.STATUS_BY_THREAD T1,
     PERFORMANCE_SCHEMA.THREADS T2
    WHERE T1.THREAD_ID = T2.THREAD_ID
     AND T2.PROCESSLIST_USER = 'us_hammer'
     AND PROCESSLIST_ID= 166
     AND VARIABLE_NAME LIKE 'Byte%';
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
| VARIABLE_NAME  | VARIABLE_VALUE | PROCESSLIST_ID | User@Host               | PROCESSLIST_DB | PROCESSLIST_COMMAND |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
| Bytes_received | 2249391        |            166 | us_hammer@192.168.97.91 | tpcc           | Query               |
| Bytes_sent     | 4117494        |            166 | us_hammer@192.168.97.91 | tpcc           | Query               |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+
2 rows in set (0.00 sec)
```

## 2	长事务：

例:事务开启后，超过 5s 未提交的用户连接

```sql
 SELECT trx_mysql_thread_id AS PROCESSLIST_ID, NOW(),TRX_STARTED, TO_SECONDS(now())-TO_SECONDS(trx_started) AS TRX_LAST_TIME , USER, HOST, DB, TRX_QUERY FROM INFORMATION_SCHEMA.INNODB_TRX trx JOIN INFORMATION_SCHEMA.processlist pcl ON trx.trx_mysql_thread_id=pcl.id WHERE trx_mysql_thread_id != connection_id() AND TO_SECONDS(now())-TO_SECONDS(trx_started) >= 5 ;
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -+-- -- -- -- -- -+
| PROCESSLIST_ID | NOW()               | TRX_STARTED         | TRX_LAST_TIME | USER | HOST                | DB    | TRX_QUERY |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -+-- -- -- -- -- -+
|            205 | 2023-06-02 13:28:12 | 2023-06-02 13:27:16 |            56 | lixl | 192.168.97.91:49365 | csdev | NULL      |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -+-- -- -- -- -- -+
1 row in set (0.00 sec)

#8.0
SELECT 
    thr.processlist_id AS mysql_thread_id,
    CONCAT(PROCESSLIST_USER,'@',PROCESSLIST_HOST) AS User,
    i.Command,
    FORMAT_PICO_TIME(trx.timer_wait) AS trx_duration,
  --  i.info AS latest_statement
  	current_statement AS latest_statement
FROM 
    performance_schema.events_transactions_current trx
    INNER JOIN performance_schema.threads thr USING (thread_id)
    LEFT JOIN information_schema.processlist i ON i.ID = thr.processlist_id
    LEFT JOIN sys.processlist p ON p.thd_id = thread_id
WHERE 
    thr.processlist_id IS NOT NULL 
    AND PROCESSLIST_USER IS NOT NULL 
    AND trx.state = 'ACTIVE'
ORDER BY 
    trx.timer_wait DESC 
LIMIT 10;

```

## 3	元数据锁：

MySQL 5.7 开启元数据锁追踪，以便追踪定位元数据锁相关的阻塞问题

### 3.1	其一：

```sql
--  临时开启，动态生效
 UPDATE performance_schema.setup_consumers
    SET ENABLED = 'YES'
    WHERE NAME ='global_instrumentation';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 1  Changed: 0  Warnings: 0

 UPDATE performance_schema.setup_instruments
    SET ENABLED = 'YES'
    WHERE NAME ='wait/lock/metadata/sql/mdl';
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0
--  配置文件中添加，重启生效
performance-schema-instrument = wait/lock/metadata/sql/mdl=ON

  SELECT trx_mysql_thread_id AS PROCESSLIST_ID,
     NOW(),
     TRX_STARTED,
     TO_SECONDS(now())-TO_SECONDS(trx_started) AS TRX_LAST_TIME ,
     USER,
     HOST,
     DB,
     TRX_QUERY
    FROM INFORMATION_SCHEMA.INNODB_TRX trx
    JOIN INFORMATION_SCHEMA.processlist pcl ON trx.trx_mysql_thread_id=pcl.id
    WHERE trx_mysql_thread_id != connection_id()
     AND TO_SECONDS(now())-TO_SECONDS(trx_started) >=
     (SELECT MAX(Time)
     FROM INFORMATION_SCHEMA.processlist
     WHERE STATE='Waiting for table metadata lock'
     AND INFO LIKE 'alter%table%' OR INFO LIKE 'truncate%table%') ;
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- +-- -- -- -- -- -+-- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +
| PROCESSLIST_ID | NOW()               | TRX_STARTED         | TRX_LAST_TIME | USER | HOST      | DB       | TRX_QUERY                                                        |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- +-- -- -- -- -- -+-- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +
|            327 | 2023-06-02 13:36:07 | 2023-06-02 13:35:54 |            13 | lixl | localhost | nglicps2 | UPDATE nglicps2._cps_approve_info_del
SET current_rec_flag = '2' |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- +-- -- -- -- -- -+-- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +
1 row in set (0.01 sec)
--  kill 掉长事务，释放持有的 MDL 资源
kill 327;
```

注：因 MySQL 元数据信息记录有限，此处可能误杀无辜长事务，且误杀无法完全避免。 当 kill 掉阻塞源后，可能存在 DDL 语句与被阻塞的 SQL 语句同时加锁的情况，此时会出现事务开始时 间等于 DDL 开始时间连接，此类事务也需 kill

### 3.2	其二（推荐）：

```sql
-- 需先开启 metadata 的 instrument
call sys.ps_setup_enable_instrument('wait/lock/metadata/sql/mdl%')

	
SELECT
 ps.*,
 lock_summary.lock_summary
FROM
 sys.processlist ps
 INNER JOIN (
 SELECT
 owner_thread_id,
GROUP_CONCAT(
 DISTINCT CONCAT(
 mdl.LOCK_STATUS,
 ' ',
 mdl.lock_type,
 ' on ',
 IF(
 mdl.object_type = 'USER LEVEL LOCK',
 CONCAT(mdl.object_name, ' (user lock)'),
 CONCAT(mdl.OBJECT_SCHEMA, '.', mdl.OBJECT_NAME)
 )
 )
 ORDER BY
 mdl.object_type ASC,
 mdl.LOCK_STATUS ASC,
 mdl.lock_type ASC SEPARATOR '\n'
 ) as lock_summary
 FROM
 performance_schema.metadata_locks mdl
 GROUP BY
 owner_thread_id
 ) lock_summary ON (ps.thd_id = lock_summary.owner_thread_id)
```



```sql
-- 查找事务开始时间 = DDL 语句事务开始时间的线程
 SELECT trx_mysql_thread_id AS PROCESSLIST_ID,
     NOW(),
     TRX_STARTED,
     TO_SECONDS(now())-TO_SECONDS(trx_started) AS TRX_LAST_TIME ,
     USER,
     HOST,
     DB,
     TRX_QUERY
    FROM INFORMATION_SCHEMA.INNODB_TRX trx
    JOIN INFORMATION_SCHEMA.processlist pcl ON trx.trx_mysql_thread_id=pcl.id
    WHERE trx_mysql_thread_id != connection_id()
     AND trx_started =
     (SELECT MIN(trx_started)
     FROM INFORMATION_SCHEMA.INNODB_TRX
     GROUP BY trx_started HAVING count(trx_started)>=2)
     AND TRX_QUERY NOT LIKE 'alter%table%'
     OR TRX_QUERY IS NULL;
 +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -+
| PROCESSLIST_ID | NOW()               | TRX_STARTED         | TRX_LAST_TIME | TRX_QUERY |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- +
|            205 | 2023-06-02 13:28:12 | 2023-06-02 13:27:16 |            56 | NULL      |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- +
1 row in set (0.00 sec)
-- 杀掉阻塞源
kill 205;
```

TEST:2：kill 掉下发 DDL 语句的用户连接，取消 DDL 语句下发，保障业务不被阻塞

```sql
--  查找 DDL 语句所在用户连接
 SELECT *
    FROM INFORMATION_SCHEMA.PROCESSLIST
    WHERE INFO LIKE 'ALTER%TABLE%';
+-- -- -+-- -- -- +-- -- -- -- -- -+-- -- -- -- -- +-- -- -- -- -+-- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -+-- -- -- -- -- -+-- -- -- -- -- -- -- -+
| ID  | USER | HOST      | DB       | COMMAND | TIME | STATE          | INFO                                                   | TIME_MS | ROWS_SENT | ROWS_EXAMINED |
+-- -- -+-- -- -- +-- -- -- -- -- -+-- -- -- -- -- +-- -- -- -- -+-- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -+-- -- -- -- -- -+-- -- -- -- -- -- -- -+
| 788 | lixl | localhost | nglicps2 | Query   |   11 | altering table | alter table cps_approve_info add column t2 varchar(12) |   10323 |         0 |             0 |
+-- -- -+-- -- -- +-- -- -- -- -- -+-- -- -- -- -- +-- -- -- -- -+-- -- -- +-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -+-- -- -- -- -- -+-- -- -- -- -- -- -- -+
1 row in set (0.00 sec)
--  杀掉 DDL 语句所在用户连接
kill 788;
```

## 4	锁等待：

查看锁等待相关的阻塞线程、被阻塞线程信息及相关用户、IP、PORT

```sql
 SELECT locked_table,
     locked_index,
     locked_type,
     blocking_pid,
     concat(T2.USER,'@',T2.HOST) AS "blocking(user@ip:port)",
     blocking_lock_mode,
     blocking_trx_rows_modified,
     waiting_pid,
     concat(T3.USER,'@',T3.HOST) AS "waiting(user@ip:port)",
     waiting_lock_mode,
     waiting_trx_rows_modified,
     wait_age_secs,
     waiting_query
    FROM sys.x$innodb_lock_waits T1
    LEFT JOIN INFORMATION_SCHEMA.processlist T2 ON T1.blocking_pid=T2.ID
    LEFT JOIN INFORMATION_SCHEMA.processlist T3 ON T3.ID=T1.waiting_pid;
+-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
| locked_table       | locked_index | locked_type | blocking_pid | blocking(user@ip:port) | blocking_lock_mode | blocking_trx_rows_modified | waiting_pid | waiting(user@ip:port) | waiting_lock_mode | waiting_trx_rows_modified | wait_age_secs | waiting_query                                                               |
+-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
| `tpcc`.`warehouse` | PRIMARY      | RECORD      |          908 | lixl@%:59878           | X                  |                          0 |         907 | lixl@%:59877          | X                 |                         0 |             0 | UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id |
| `tpcc`.`warehouse` | PRIMARY      | RECORD      |          901 | lixl@%:59873           | X                  |                          0 |         907 | lixl@%:59877          | X                 |                         0 |             0 | UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id |
| `tpcc`.`warehouse` | PRIMARY      | RECORD      |          904 | lixl@%:59874           | X                  |                          0 |         907 | lixl@%:59877          | X                 |                         0 |             0 | UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id |
| `tpcc`.`warehouse` | PRIMARY      | RECORD      |          900 | lixl@%:59872           | X                  |                          0 |         907 | lixl@%:59877          | X                 |                         0 |             0 | UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id |
| `tpcc`.`warehouse` | PRIMARY      | RECORD      |          894 | lixl@%:59782           | X                  |                          0 |         907 | lixl@%:59877          | X                 |                         0 |             0 | UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id |
..
+-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
45 rows in set, 3 warnings (0.01 sec)

```

若不关心阻塞相关的用户、IP、PORT，可直接查看 innodb_lock_waits 表信息。

```sql
 select * from sys.x$innodb_lock_waits LIMIT 1\G;
*************************** 1. row ***************************
                wait_started: 2023-06-02 14:12:26
                    wait_age: 00:00:00
               wait_age_secs: 0
                locked_table: `tpcc`.`warehouse`
                locked_index: PRIMARY
                 locked_type: RECORD
              waiting_trx_id: 873385792
         waiting_trx_started: 2023-06-02 14:12:26
             waiting_trx_age: 00:00:00
     waiting_trx_rows_locked: 1
   waiting_trx_rows_modified: 0
                 waiting_pid: 940
               waiting_query: UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id
             waiting_lock_id: 873385792:355:3:2
           waiting_lock_mode: X
             blocking_trx_id: 873385727
                blocking_pid: 905
              blocking_query: UPDATE warehouse SET w_ytd = w_ytd + p_h_amount
        WHERE w_id = p_w_id
            blocking_lock_id: 873385727:355:3:2
          blocking_lock_mode: X
        blocking_trx_started: 2023-06-02 14:12:26
            blocking_trx_age: 00:00:00
    blocking_trx_rows_locked: 1
  blocking_trx_rows_modified: 0
     sql_kill_blocking_query: KILL QUERY 905
sql_kill_blocking_connection: KILL 905
1 row in set, 3 warnings (0.11 sec)

ERROR:
No query specified
```

影响锁等待超时的参数

![image-20230602141309749](./imgs/image-20230602141309749.png)

## 5	全局读锁：

PERFORMANCE_SCHEMA.METADATA_LOCKS 表 LOCK_DURATION 列为 EXPLICIT 状态表示 FTWRL 语句添加，OBJECT_TYPE 出现 COMMIT 状态表示已经加锁成功。

场景 1：杀掉添加 FTWRL 的会话，恢复业务运行

```sql
 SELECT processlist_id,
     mdl.OBJECT_TYPE,
     OBJECT_SCHEMA,
     OBJECT_NAME,
     LOCK_TYPE,
     LOCK_DURATION,
     LOCK_STATUS
    FROM performance_schema.metadata_locks mdl
    INNER JOIN performance_schema.threads thd ON mdl.owner_thread_id = thd.thread_id
    AND processlist_id <> connection_id()
    AND LOCK_DURATION='EXPLICIT';
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -+
| processlist_id | OBJECT_TYPE | OBJECT_SCHEMA | OBJECT_NAME | LOCK_TYPE           | LOCK_DURATION | LOCK_STATUS |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -+
|            914 | COMMIT      | NULL          | NULL        | INTENTION_EXCLUSIVE | EXPLICIT      | GRANTED     |
|            914 | BINLOG      | NULL          | NULL        | INTENTION_EXCLUSIVE | EXPLICIT      | GRANTED     |
|            920 | COMMIT      | NULL          | NULL        | INTENTION_EXCLUSIVE | EXPLICIT      | GRANTED     |
|            920 | BINLOG      | NULL          | NULL        | INTENTION_EXCLUSIVE | EXPLICIT      | GRANTED     |
|            921 | COMMIT      | NULL          | NULL        | INTENTION_EXCLUSIVE | EXPLICIT      | GRANTED     |
|            921 | BINLOG      | NULL          | NULL        | INTENTION_EXCLUSIVE | EXPLICIT      | GRANTED     |
+-- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+-- -- -- -- -- -- -+
6 rows in set (0.00 sec)
--  杀掉添加 FTWRL 的用户连接
kill 914;
```

```sql
-- 场景 2：杀掉语句执行时间大于 FTWRL 执行时间的线程，确保 FTWRL 下发成功
 SELECT T2.THREAD_ID,
     T1.ID AS PROCESSLIST_ID,
     T1.User,
     T1.Host,
     T1.db,
     T1.Time,
     T1.State,
     T1.Info,
     T3.TRX_STARTED,
     TO_SECONDS(now())-TO_SECONDS(trx_started) AS TRX_LAST_TIME
    FROM INFORMATION_SCHEMA.processlist T1
    LEFT JOIN PERFORMANCE_SCHEMA.THREADS T2 ON T1.ID=T2.PROCESSLIST_ID
    LEFT JOIN INFORMATION_SCHEMA.INNODB_TRX T3 ON T1.id=T3.trx_mysql_thread_id
    WHERE T1.TIME >=
     (SELECT MAX(Time)
     FROM INFORMATION_SCHEMA.processlist
     WHERE INFO LIKE 'flush%table%with%read%lock')
     AND Info IS NOT NULL;
Empty set (0.00 sec)
```

通过查询来精确地定位出需要 Kill 的会话

```sql
SELECT sql_kill_blocking_connection FROM sys.schema_table_lock_waits WHERE blocking_lock_type <> 'SHARED_UPGRADABLE' AND waiting_query = '（select waiting_query from sys.schema_table_lock_waits\G）';
```

`sys.schema_table_lock_waits` 视图依赖了一张 MDL 相关的表 `performance_schema.metadata_locks`。该表是 MySQL 5.7 引入的，会显示 MDL 的相关信息，包括作用对象、锁的类型及锁的状态等。但在 MySQL 5.7 中，该表默认为空，因为与之相关的 `instrument` 默认没有开启，MySQL 8.0 才默认开启。

```sql
 select * from performance_schema.setup_instruments where name='wait/lock/metadata/sql/mdl';
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -+-- -- -- -+
| NAME                       | ENABLED | TIMED |
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -+-- -- -- -+
| wait/lock/metadata/sql/mdl | NO      | NO    |
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -+-- -- -- -+
1 row in set (0.06 sec)

 UPDATE PERFORMANCE_SCHEMA.setup_instruments SET ENABLED = 'YES', TIMED = 'YES' WHERE NAME = 'wait/lock/metadata/sql/mdl';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

[mysqld]
performance-schema-instrument ='wait/lock/metadata/sql/mdl=ON'
```

1. 执行 `show processlist`，如果 DDL 的状态是 `Waiting for table metadata lock` ，则意味着这个 DDL 被阻塞了。
2. 定位导致 DDL 被阻塞的会话，常用的方法如下：sys.schema_table_lock_waits

```sql
-- 这种方法适用于 MySQL 5.7 和 8.0。
select sql_kill_blocking_connection from sys.schema_table_lock_waits WHERE blocking_lock_type <> 'SHARED_UPGRADABLE' and (waiting_query like 'alter%' OR waiting_query like 'create%' OR waiting_query like 'drop%' OR waiting_query like 'truncate%' OR waiting_query like 'rename%');
```

kill ddl之前的会话

```sql
select concat('kill',i.trx_mysql_thread_id,';') from information_schema.innodb_trx i, ( select max(time) as max_time from information_schema.processlist where state = 'Waiting for table metadata lock' and (info like 'alter%' OR info like 'create%' OR info like 'drop%' OR info like 'truncate%' OR info like 'rename%')) p WHERE timestampdiff(second, i.trx_started ,now()) > p.max_time;
```

如果 MySQL 5.7 中 MDL 相关的 instrument 没有打开，可使用该方法。

## 6	内存使用监控：

默认只对 performance_schema 库进行内存统计，对全局内存统计需要手工开启

```sql
-- 动态开启，开启后开始统计
update performance_schema.setup_instruments set
enabled = 'yes' where name like 'memory%';
-- 配置文件中添加，重启生效
performance-schema-instrument='memory/%=COUNTED'
查看实例内存消耗分布，sys 库下有多张 memory 相关视图用于协助用户定位分析内存溢出类问题
 update performance_schema.setup_instruments set
    enabled = 'yes' where name like 'memory%';
Query OK, 321 rows affected (0.00 sec)
Rows matched: 391  Changed: 321  Warnings: 0

 SELECT event_name,
     current_alloc
    FROM sys.memory_global_by_current_bytes
    WHERE event_name LIKE 'memory%innodb%';
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+
| event_name              | current_alloc |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+
| memory/innodb/trx0undo  | 29.56 KiB     |
| memory/innodb/mem0mem   | 15.32 KiB     |
| memory/innodb/btr0pcur  | 4.99 KiB      |
| memory/innodb/ha_innodb | 528 bytes     |
| memory/innodb/row0sel   | 192 bytes     |
| memory/innodb/rem0rec   | 41 bytes      |
+-- -- -- -- -- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -+
6 rows in set (0.04 sec)
```

## 7	分区表：

查看实例中的分区表相关信息

```sql
 SELECT TABLE_SCHEMA,
     TABLE_NAME,
     count(PARTITION_NAME) AS PARTITION_COUNT,
     sum(TABLE_ROWS) AS TABLE_TOTAL_ROWS,
     CONCAT(ROUND(SUM(DATA_LENGTH) / (1024 * 1024), 2),'M') DATA_LENGTH,
     CONCAT(ROUND(SUM(INDEX_LENGTH) / (1024 * 1024), 2),'M') INDEX_LENGTH,
     CONCAT(ROUND(ROUND(SUM(DATA_LENGTH + INDEX_LENGTH)) / (1024 * 1024),2),'M')
    TOTAL_SIZE
    FROM INFORMATION_SCHEMA.PARTITIONS
    WHERE TABLE_NAME NOT IN ('sys',
     'mysql',
     'INFORMATION_SCHEMA',
     'performance_schema')
     AND PARTITION_NAME IS NOT NULL
    GROUP BY TABLE_SCHEMA,
     TABLE_NAME
    ORDER BY sum(DATA_LENGTH + INDEX_LENGTH) DESC ;
Empty set (0.06 sec)
-- 查看某分区表具体信息，此处以库名为 db、表名为 e 的分区表为例
 SELECT TABLE_SCHEMA,
     TABLE_NAME,
     PARTITION_NAME,
     PARTITION_EXPRESSION,
     PARTITION_METHOD,
     PARTITION_DESCRIPTION,
     TABLE_ROWS,
     CONCAT(ROUND(DATA_LENGTH / (1024 * 1024), 2),'M') DATA_LENGTH,
     CONCAT(ROUND(INDEX_LENGTH / (1024 * 1024), 2),'M') INDEX_LENGTH,
     CONCAT(ROUND(ROUND(DATA_LENGTH + INDEX_LENGTH) / (1024 * 1024),2),'M')
    TOTAL_SIZE
    FROM INFORMATION_SCHEMA.PARTITIONS
    WHERE TABLE_SCHEMA NOT IN ('sys',
     'mysql',
     'INFORMATION_SCHEMA',
     'performance_schema')
     AND PARTITION_NAME IS NOT NULL
     AND TABLE_SCHEMA='db'
     AND TABLE_NAME='e';
Empty set (0.00 sec)
```

## 8	数据库信息概览：

统计实例中各数据库大小

```sql
 SELECT TABLE_SCHEMA,
     round(SUM(data_length+index_length)/1024/1024,2) AS TOTAL_MB,
     round(SUM(data_length)/1024/1024,2) AS DATA_MB,
     round(SUM(index_length)/1024/1024,2) AS INDEX_MB,
     COUNT(*) AS TABLES
    FROM INFORMATION_SCHEMA.tables
    WHERE TABLE_SCHEMA NOT IN ('sys',
     'mysql',
     'INFORMATION_SCHEMA',
    'performance_schema')
    GROUP BY TABLE_SCHEMA
    ORDER BY 2 DESC;
+-- -- -- -- -- -- -- +-- -- -- -- -- +-- -- -- -- -+-- -- -- -- -- +-- -- -- -- +
| TABLE_SCHEMA | TOTAL_MB | DATA_MB | INDEX_MB | TABLES |
+-- -- -- -- -- -- -- +-- -- -- -- -- +-- -- -- -- -+-- -- -- -- -- +-- -- -- -- +
| nglicps2     | 15370.53 | 8940.91 |  6429.63 |    100 |
| tpcc         |  3010.94 | 2973.27 |    37.67 |     16 |
| nglicps      |  1959.36 | 1788.73 |   170.63 |     50 |
| csdev        |     5.56 |    3.05 |     2.52 |     21 |
+-- -- -- -- -- -- -- +-- -- -- -- -- +-- -- -- -- -+-- -- -- -- -- +-- -- -- -- +
4 rows in set (0.01 sec)
```

统计某库下各表大小

```sql
 SELECT TABLE_SCHEMA,
     TABLE_NAME TABLE_NAME,
     CONCAT(ROUND(data_length / (1024 * 1024), 2),'M') data_length,
     CONCAT(ROUND(index_length / (1024 * 1024), 2),'M') index_length,
     CONCAT(ROUND(ROUND(data_length + index_length) / (1024 * 1024),2),'M')
     total_size,
     engine
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA NOT IN ('INFORMATION_SCHEMA' ,
     'performance_schema',
     'sys',
     'mysql')
     AND TABLE_SCHEMA='nglicps2'
    ORDER BY (data_length + index_length) DESC LIMIT 10;
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- +-- -- -- -- -- -- +-- -- -- -- +
| TABLE_SCHEMA | TABLE_NAME               | data_length | index_length | total_size | engine |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- +-- -- -- -- -- -- +-- -- -- -- +
| nglicps2     | cps_transactions         | 4370.98M    | 3494.89M     | 7865.88M   | InnoDB |
| nglicps2     | cps_transactions_copy2   | 1473.00M    | 2012.30M     | 3485.30M   | InnoDB |
| nglicps2     | cps_req_bat_deal_dtl     | 1009.98M    | 530.38M      | 1540.36M   | InnoDB |
| nglicps2     | cps_flowpath             | 473.92M     | 222.19M      | 696.11M    | InnoDB |
| nglicps2     | cps_req_bat_deal_dtl_fld | 546.00M     | 0.00M        | 546.00M    | InnoDB |
| nglicps2     | cps_approve_info         | 268.83M     | 54.59M       | 323.42M    | InnoDB |
| nglicps2     | _cps_approve_info_del    | 258.81M     | 54.59M       | 313.41M    | InnoDB |
| nglicps2     | cps_financial_copy6      | 90.66M      | 0.00M        | 90.66M     | InnoDB |
| nglicps2     | cps_financial            | 72.64M      | 0.00M        | 72.64M     | InnoDB |
| nglicps2     | sheet1                   | 53.58M      | 9.03M        | 62.61M     | InnoDB |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- +-- -- -- -- -- -- +-- -- -- -- +
10 rows in set (0.01 sec)
```

查看某库下表的基本信息

```sql
 SELECT TABLE_SCHEMA,
     TABLE_NAME,
     table_collation,
     engine,
     table_rows
    FROM INFORMATION_SCHEMA.tables
    WHERE TABLE_SCHEMA NOT IN ('INFORMATION_SCHEMA' ,
     'sys',
     'mysql',
     'performance_schema')
     AND TABLE_TYPE='BASE TABLE'
     AND TABLE_SCHEMA='nglicps2'
    ORDER BY table_rows DESC limit 10;
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -+-- -- -- -- +-- -- -- -- -- -- +
| TABLE_SCHEMA | TABLE_NAME               | table_collation | engine | table_rows |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -+-- -- -- -- +-- -- -- -- -- -- +
| nglicps2     | cps_transactions         | utf8_bin        | InnoDB |    9969724 |
| nglicps2     | cps_req_bat_deal_dtl_fld | utf8_bin        | InnoDB |    5715758 |
| nglicps2     | cps_transactions_copy2   | utf8_bin        | InnoDB |    4553119 |
| nglicps2     | cps_req_bat_deal_dtl     | utf8_bin        | InnoDB |    4495366 |
| nglicps2     | _cps_approve_info_del    | utf8_bin        | InnoDB |    2176772 |
| nglicps2     | cps_approve_info         | utf8_bin        | InnoDB |    2150936 |
| nglicps2     | cps_flowpath             | utf8_general_ci | InnoDB |    1519448 |
| nglicps2     | cps_financial_copy6      | utf8_general_ci | InnoDB |     384139 |
| nglicps2     | cps_financial_copy5      | utf8_general_ci | InnoDB |     216544 |
| nglicps2     | cps_financial            | utf8_general_ci | InnoDB |     211444 |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -+-- -- -- -- +-- -- -- -- -- -- +
10 rows in set (0.01 sec)
```

查询 某张表关联的存储过程

```sql
SELECT
    r.ROUTINE_SCHEMA,
    r.ROUTINE_NAME,
    r.ROUTINE_TYPE,
    r.ROUTINE_DEFINITION,
    p.PARAMETER_NAME,
    p.DATA_TYPE
FROM
    information_schema.routines r
LEFT JOIN
    information_schema.parameters p
ON
    r.SPECIFIC_NAME = p.SPECIFIC_NAME
WHERE
    r.ROUTINE_DEFINITION LIKE '%t_re%'
    AND r.ROUTINE_TYPE = 'PROCEDURE'
    AND r.ROUTINE_SCHEMA = 'ats';
```



某张表关联的视图

```sql
SELECT
    r.ROUTINE_SCHEMA,
    r.ROUTINE_NAME,
    r.ROUTINE_TYPE,
    r.ROUTINE_DEFINITION,
    p.PARAMETER_NAME,
    p.DATA_TYPE
FROM
    information_schema.routines r
LEFT JOIN
    information_schema.parameters p
ON
    r.SPECIFIC_NAME = p.SPECIFIC_NAME
WHERE
    r.ROUTINE_DEFINITION LIKE '%t_re%'
    AND r.ROUTINE_TYPE = 'PROCEDURE'
    AND r.ROUTINE_SCHEMA = 'ats';
```





## 9	长时间未更新的表：

UPDATE_TIME 为 NULL 表示实例启动后一直未更新过

```sql
 SELECT TABLE_SCHEMA,
     TABLE_NAME,
     UPDATE_TIME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA NOT IN ('SYS',
     'MYSQL',
     'INFORMATION_SCHEMA',
     'PERFORMANCE_SCHEMA')
     AND TABLE_TYPE='BASE TABLE'
    ORDER BY UPDATE_TIME limit 10 ;
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
| TABLE_SCHEMA | TABLE_NAME           | UPDATE_TIME |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
| nglicps2     | caf_inst             | NULL        |
| nglicps2     | caf_user_copy1       | NULL        |
| nglicps      | caf_illegal_access   | NULL        |
| nglicps2     | cps_bankarea         | NULL        |
| nglicps      | caf_userrole         | NULL        |
| nglicps2     | cps_financial_copy1  | NULL        |
| nglicps      | cps_qry_busno        | NULL        |
| nglicps2     | pay_detail           | NULL        |
| nglicps2     | pay_revisehistory    | NULL        |
| nglicps2     | cps_ns_payment_group | NULL        |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+
10 rows in set (0.01 sec)
```

## 10	主键、索引：

无主键、唯一键及二级索引基表

- MySQL Innodb 存储引擎为索引组织表，因此设置合适的主键字段对性能至关重要

```sql
 SELECT T1.TABLE_SCHEMA,
     T1.TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS T1 JOIN INFORMATION_SCHEMA.TABLES T2 ON
    T1.TABLE_SCHEMA=T2.TABLE_SCHEMA AND T1.TABLE_NAME=T2.TABLE_NAME
    WHERE T1.TABLE_SCHEMA NOT IN ('SYS',
     'MYSQL',
     'INFORMATION_SCHEMA',
     'PERFORMANCE_SCHEMA')
     AND T2.TABLE_TYPE='BASE TABLE'
     AND T1.TABLE_SCHEMA='nglicps2'
    GROUP BY T1.TABLE_SCHEMA,
     T1.TABLE_NAME HAVING MAX(COLUMN_KEY)='';
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -+
| TABLE_SCHEMA | TABLE_NAME        |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -+
| nglicps2     | caf_inst          |
| nglicps2     | pay_code          |
| nglicps2     | pay_detail_copy_1 |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -+
3 rows in set (0.07 sec)
```

该类型表因无高效索引，因此从库回放时容易导致复制延迟

```sql
 SELECT T1.TABLE_SCHEMA,
     T1.TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS T1 JOIN INFORMATION_SCHEMA.TABLES T2 ON
    T1.TABLE_SCHEMA=T2.TABLE_SCHEMA AND T1.TABLE_NAME=T2.TABLE_NAME
    WHERE T1.TABLE_SCHEMA NOT IN ('SYS',
     'MYSQL',
     'INFORMATION_SCHEMA',
     'PERFORMANCE_SCHEMA')
     AND T2.TABLE_TYPE='BASE TABLE'
     AND T1.COLUMN_KEY != ''
    GROUP BY T1.TABLE_SCHEMA,
     T1.TABLE_NAME HAVING group_concat(COLUMN_KEY) NOT REGEXP 'PRI|UNI';
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
| TABLE_SCHEMA | TABLE_NAME             |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
| csdev        | ip_risk_cv             |
| nglicps2     | cps_financial_code     |
| nglicps2     | pay_detail             |
| nglicps2     | pay_detail_copy        |
| nglicps2     | pay_history            |
| nglicps2     | pay_history_copy       |
| nglicps2     | pay_init               |
| nglicps2     | pay_init_copy          |
| nglicps2     | pay_revisehistory      |
| nglicps2     | pay_revisehistory_copy |
| nglicps2     | temp_bankcode          |
| nglicps2     | temp_city              |
| nglicps2     | temp_province          |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
13 rows in set (0.04 sec)
```

仅有主键、唯一键表 该类型表结构因无二级索引，可能导致应用 SQL 语句上线后频繁全表扫描出现性能抖动

```sql
 SELECT T1.TABLE_SCHEMA,
     T1.TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS T1 JOIN INFORMATION_SCHEMA.TABLES T2 ON
    T1.TABLE_SCHEMA=T2.TABLE_SCHEMA AND T1.TABLE_NAME=T2.TABLE_NAME
    WHERE T1.TABLE_SCHEMA NOT IN ('SYS',
     'MYSQL',
     'INFORMATION_SCHEMA',
    'PERFORMANCE_SCHEMA')
     AND T2.TABLE_TYPE='BASE TABLE'
     AND T1.COLUMN_KEY != ''
     AND T1.TABLE_SCHEMA='nglicps2'
    GROUP BY T1.TABLE_SCHEMA,
     T1.TABLE_NAME HAVING group_concat(COLUMN_KEY) NOT REGEXP 'MUL';
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
| TABLE_SCHEMA | TABLE_NAME                    |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
| nglicps2     | basic_serverprops             |
| nglicps2     | basic_setinfo                 |
| nglicps2     | basic_transysvar              |
| nglicps2     | basic_wsdocument              |
| nglicps2     | basic_wsnode                  |
| nglicps2     | caf_areacode                  |
| nglicps2     | caf_audit_log                 |
| nglicps2     | caf_audit_log_des             |
..
| nglicps2     | t_pub_useronline_log          |
| nglicps2     | t_tech_webservice_endpoint    |
| nglicps2     | user_t                        |
| nglicps2     | wechat_token                  |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+
57 rows in set (0.02 sec)
```

### 10.1	无主键、唯一键表：

```sql
  SELECT T1.TABLE_SCHEMA,
     T1.TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS T1 JOIN INFORMATION_SCHEMA.TABLES T2 ON
    T1.TABLE_SCHEMA=T2.TABLE_SCHEMA AND T1.TABLE_NAME=T2.TABLE_NAME
    WHERE T1.TABLE_SCHEMA NOT IN ('SYS',
     'MYSQL',
     'INFORMATION_SCHEMA',
     'PERFORMANCE_SCHEMA')
    AND T2.TABLE_TYPE='BASE TABLE'
    GROUP BY T1.TABLE_SCHEMA,
     T1.TABLE_NAME HAVING group_concat(COLUMN_KEY) NOT REGEXP 'PRI|UNI';
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
| TABLE_SCHEMA | TABLE_NAME             |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
| csdev        | ip_risk_cv             |
| csdev        | ip_risk_prem_scf       |
| csdev        | li_pb_output_item_s    |
| csdev        | li_pm_column_conf      |
..
| nglicps2     | pay_history_copy       |
| nglicps2     | pay_init               |
| nglicps2     | pay_init_copy          |
| nglicps2     | pay_revisehistory      |
| nglicps2     | pay_revisehistory_copy |
| nglicps2     | temp_bankcode          |
| nglicps2     | temp_city              |
| nglicps2     | temp_province          |
| tpcc         | history                |
| tpcc         | t2                     |
+-- -- -- -- -- -- -- +-- -- -- -- -- -- -- -- -- -- -- -- +
28 rows in set (0.09 sec)
```

查看索引大小

```sql
 SELECT sum(stat_value) pages ,index_name ,
    (round((sum(stat_value) * @@innodb_page_size)/1024/1024)) as MB
     FROM mysql.innodb_index_stats
     WHERE table_name = 'blcdtlnewcont_83'
     AND database_name = 'csdev'
     AND stat_description = 'Number of pages in the index'
     GROUP BY index_name;
+-- -- -- -+-- -- -- -- -- -- +-- -- -- +
| pages | index_name | MB   |
+-- -- -- -+-- -- -- -- -- -- +-- -- -- +
|   739 | PRIMARY    |   12 |
+-- -- -- -+-- -- -- -- -- -- +-- -- -- +
1 row in set (0.86 sec)
```



## 11	存储引擎：

存储引擎分布

```sql
 SELECT TABLE_SCHEMA,
     ENGINE,
     COUNT(*)
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA NOT IN ('INFORMATION_SCHEMA' ,
     'PERFORMANCE_SCHEMA',
     'SYS',
     'MYSQL')
     AND TABLE_TYPE='BASE TABLE'
    GROUP BY TABLE_SCHEMA,
     ENGINE;
+-- -- -- -- -- -- -- +-- -- -- -- +-- -- -- -- -- +
| TABLE_SCHEMA | ENGINE | COUNT(*) |
+-- -- -- -- -- -- -- +-- -- -- -- +-- -- -- -- -- +
| csdev        | InnoDB |       21 |
| nglicps      | InnoDB |       49 |
| nglicps2     | InnoDB |      100 |
| tpcc         | InnoDB |       16 |
+-- -- -- -- -- -- -- +-- -- -- -- +-- -- -- -- -- +
4 rows in set (0.00 sec)
```

非 INNODB 存储引擎表

```sql
 SELECT TABLE_SCHEMA,
     TABLE_NAME,
     TABLE_COLLATION,
     ENGINE,
     TABLE_ROWS
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA NOT IN ('INFORMATION_SCHEMA' ,
     'SYS',
     'MYSQL',
     'PERFORMANCE_SCHEMA')
     AND TABLE_TYPE='BASE TABLE'
     AND ENGINE NOT IN ('INNODB')
    ORDER BY TABLE_ROWS DESC ;
Empty set (0.01 sec)
```

## 12	实时负载：

```sql
-- 其一
[root@postgre nglicps]# /data/mysql_basedir_3306/bin/mysqladmin -h192.168.97.222 -ulixl -p -r -i 5 ext |gawk -F"|" "BEGIN{ count=0; }"'{ if($2 ~ /Variable_name/ && ++count == 1){\
>     print "-- -- -- -- -- |-- -- -- -|-- -- -|-- - MySQL Command Status -- |--   Innodb row operation   -- |Buffer Pool Read|-- --    Buffer Pool Pages   -- -- |--   Key Read  -- |";\
>     print "-- -Time-- -|-- QPS-- |-TPS-|select insert update delete|   read  insert update delete|      req    phy|   data  free  misc dirty flush|     req     phy|";\
> }\
> else if ($2 ~ /Questions/){questions=$3;}\
> else if ($2 ~ /Com_commit/){com_commit=$3;}\
> else if ($2 ~ /Com_rollback/){com_rollback=$3;}\
> else if ($2 ~ /Com_select/){com_select=$3;}\
> else if ($2 ~ /Com_insert/){com_insert=$3;}\
> else if ($2 ~ /Com_update/){com_update=$3;}\
> else if ($2 ~ /Com_delete/){com_delete=$3;}\
> else if ($2 ~ /Innodb_rows_read/){innodb_rows_read=$3;}\
> else if ($2 ~ /Innodb_rows_deleted/){innodb_rows_deleted=$3;}\
> else if ($2 ~ /Innodb_rows_inserted/){innodb_rows_inserted=$3;}\
> else if ($2 ~ /Innodb_rows_updated/){innodb_rows_updated=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_read_requests/){innodb_req=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_reads/){innodb_phr=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_pages_data/){pages_data=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_pages_dirty/){pages_dirty=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_pages_flushed/){pages_flushed=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_pages_free/){pages_free=$3;}\
> else if ($2 ~ /Innodb_buffer_pool_pages_misc/){pages_misc=$3;}\
> else if ($2 ~ /Key_read_requests/){key_req=$3;}\
> else if ($2 ~ /Key_reads/){key_phr=$3;}\
> else if ($2 ~ /Uptime / && count >= 2){\
>   printf(" %s |%7d|%5d",strftime("%H:%M:%S"),questions/5,(com_commit+com_rollback)/5);\
>   printf("|%6d %6d %6d %6d",com_select,com_insert,com_update,com_delete);\
>   printf("|%8d %6d %6d %6d",innodb_rows_read,innodb_rows_inserted,innodb_rows_updated,innodb_rows_deleted);\
>   printf("|%9d %6d",innodb_req,innodb_phr);\
>   printf("|%7d %5d %5d %5d %5d",pages_data,pages_free,pages_misc,pages_dirty,pages_flushed);\
>   printf("|%9d %6d\n",key_req,key_phr);\
> }}'
Enter password:
-- -- -- -- -- |-- -- -- -|-- -- -|-- - MySQL Command Status -- |--   Innodb row operation   -- |Buffer Pool Read|-- --    Buffer Pool Pages   -- -- |--   Key Read  -- |
-- -Time-- -|-- QPS-- |-TPS-|select insert update delete|   read  insert update delete|      req    phy|   data  free  misc dirty flush|     req     phy|
 14:52:42 |      2|    0|     6      0      0      0|      17     17      0      0|       28      0|      0     0     0     3     0|        0      0
 14:52:42 |      6|    0|    16      0      0      0|      29     29      0      0|       51      0|      0     0     0     0     6|        0      0
 14:52:52 |      2|    0|     6      0      0      0|      17     17      0      0|       28      0|      0     0     0     0     3|        0      0
 14:52:52 |      6|    0|    16      0      0      0|      29     29      0      0|       51      0|      0     0     0     0     6|        0      0
 14:52:57 |      2|    0|     6      0      0      0|      17     17      0      0|       28      0|      0     0     0     0     3|        0      0
..

-- 其二
[root@postgre nglicps]# /data/mysql_basedir_3306/bin/mysqladmin -ulixl -plixl extended-status -r -i 1 -c 30 -- socket=/data/mysql_3306/mysql_sock/mysql.sock 2>/dev/null | awk -F"|" 'BEGIN{
>         count = 0;
>     }
>     {
>         if ($2 ~ /Variable_name/ && ++count == 1) {
>             print "-- -- -- -- -- |-- -- -- -- -|-- - MySQL Command Status -- |-- -- - Innodb row operation -- -- |--  Buffer Pool Read -- ";
>             print "-- -Time-- -|-- -QPS-- -|select insert update delete| read inserted updated deleted| logical physical";
>         }
>         else if ($2 ~ /Queries/) {
>             queries = $3;
>         }
>         else if ($2 ~ /Com_select /) {
>             com_select = $3;
>         }
>         else if ($2 ~ /Com_insert /) {
>             com_insert = $3;
>         }
>         else if ($2 ~ /Com_update /) {
>             com_update = $3;
>         }
>         else if ($2 ~ /Com_delete /) {
>             com_delete = $3;
>         }
>         else if ($2 ~ /Innodb_rows_read/) {
>             innodb_rows_read = $3;
>         }
>         else if ($2 ~ /Innodb_rows_deleted/) {
>             innodb_rows_deleted = $3;
>         }
>         else if ($2 ~ /Innodb_rows_inserted/) {
>             innodb_rows_inserted = $3;
>         }
>         else if ($2 ~ /Innodb_rows_updated/) {
>             innodb_rows_updated = $3;
>         }
>         else if ($2 ~ /Innodb_buffer_pool_read_requests/) {
>             innodb_lor = $3;
>         }
>         else if ($2 ~ /Innodb_buffer_pool_reads/) {
>             innodb_phr = $3;
>         }
>         else if ($2 ~ /Uptime / && count >= 2) {
>             printf(" %s |%9d", strftime("%H:%M:%S"), queries);
>             printf("|%6d %6d %6d %6d", com_select, com_insert, com_update, com_delete);
>             printf("|%6d %8d %7d %7d", innodb_rows_read, innodb_rows_inserted, innodb_rows_updated, innodb_rows_deleted);
>             printf("|%10d %11d\n", innodb_lor, innodb_phr);
>         }
>     }'
-- -- -- -- -- |-- -- -- -- -|-- - MySQL Command Status -- |-- -- - Innodb row operation -- -- |--  Buffer Pool Read -- 
-- -Time-- -|-- -QPS-- -|select insert update delete| read inserted updated deleted| logical physical
 14:58:57 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:58:58 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:58:59 |       16|     7      0      0      0|    13       13       0       0|        24           0
 14:59:00 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:59:01 |       38|    22      0      0      0|  6356     6314       0       0|      5266           0
 14:59:02 |        7|     3      0      0      0|     0        0       0       0|         1           0
 14:59:03 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:59:03 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:59:05 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:59:05 |       12|     6      0      0      0|    17       17       0       0|        24           0
 14:59:07 |        1|     0      0      0      0|     0        0       0       0|         1           0
 14:59:07 |        1|     0      0      0      0|     0        0       0       0|         1           0

```

## 13	DDL：

### 13.1	DDL进度查验：

启动相关服务参数：

```sql
-- 启动相关服务参数：
 UPDATE performance_schema.setup_instruments
           SET ENABLED = 'YES'
           WHERE NAME LIKE 'stage/innodb/alter%';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 7  Changed: 0  Warnings: 0


  UPDATE performance_schema.setup_consumers
           SET ENABLED = 'YES'
           WHERE NAME LIKE '%stages%';
Query OK, 3 rows affected (0.00 sec)
Rows matched: 3  Changed: 3  Warnings: 0

 select stmt.SQL_TEXT as sql_text,
           concat(WORK_COMPLETED, '/', WORK_ESTIMATED) as progress,
           (stage.TIMER_END - stmt.TIMER_START) / 1e12 as current_seconds,
           (stage.TIMER_END - stmt.TIMER_START) / 1e12 * (WORK_ESTIMATED - WORK_COMPLETED) /
           WORK_COMPLETED as remaining_seconds
    from performance_schema.events_stages_current stage,
         performance_schema.events_statements_current stmt
    where stage.THREAD_ID = stmt.THREAD_ID
      and stage.NESTING_EVENT_ID = stmt.EVENT_ID;
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- +-- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +
| sql_text                                               | progress   | current_seconds | remaining_seconds  |
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- +-- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +
| alter table cps_approve_info add column t3 varchar(12) | 8162/67639 |     1.601721593 | 11.671844546295148 |
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- +-- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +
1 row in set (0.00 sec)

 select stmt.SQL_TEXT as sql_text,
           concat(WORK_COMPLETED, '/', WORK_ESTIMATED) as progress,
           (stage.TIMER_END - stmt.TIMER_START) / 1e12 as current_seconds,
           (stage.TIMER_END - stmt.TIMER_START) / 1e12 * (WORK_ESTIMATED - WORK_COMPLETED) /
           WORK_COMPLETED as remaining_seconds
    from performance_schema.events_stages_current stage,
         performance_schema.events_statements_current stmt
    where stage.THREAD_ID = stmt.THREAD_ID
      and stage.NESTING_EVENT_ID = stmt.EVENT_ID;
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +
| sql_text                                               | progress    | current_seconds | remaining_seconds  |
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +
| alter table cps_approve_info add column t3 varchar(12) | 33388/77421 |     7.735420941 | 10.201682948815533 |
+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- +-- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -+-- -- -- -- -- -- -- -- -- -- +
1 row in set (0.00 sec)

-- 注解
select stmt.SQL_TEXT as sql_text,
       concat(WORK_COMPLETED, '/', WORK_ESTIMATED) as progress, -- 当前进度
       (stage.TIMER_END - stmt.TIMER_START) / 1e12 as current_seconds, -- 运行时间 = 当前时间 - 语句开始时间
       (stage.TIMER_END - stmt.TIMER_START) / 1e12 * (WORK_ESTIMATED - WORK_COMPLETED) /
       WORK_COMPLETED as remaining_seconds -- 剩余时间估算 = 运行时间* （1-当前进度）
from performance_schema.events_stages_current stage,
     performance_schema.events_statements_current stmt
where stage.THREAD_ID = stmt.THREAD_ID
  and stage.NESTING_EVENT_ID = stmt.EVENT_ID; -- 关联键 = 进程号+父事件ID
  
-- 原理
 SELECT *FROM performance_schema.events_stages_current\G;
*************************** 1. row ***************************
         THREAD_ID: 51
          EVENT_ID: 34
      END_EVENT_ID: NULL
        EVENT_NAME: stage/innodb/alter table (insert) -- 当前阶段
            SOURCE:
       TIMER_START: 719028748009000
         TIMER_END: 723982407319000		-- 任务未结束前 为当前时间
        TIMER_WAIT: 4953659310000
    WORK_COMPLETED: 15470995		-- 工作量评估
    WORK_ESTIMATED: 19330513
  NESTING_EVENT_ID: 6			-- 父事件id
NESTING_EVENT_TYPE: STATEMENT
1 row in set (0.00 sec)

-- 官网文档 https:-- dev.mysql.com/doc/refman/5.7/en/monitor-alter-table-performance-schema.html
```

### 13.2	DDL辅助工具：

- ###### 	pt-online-schema-change

- ###### 	ghost

  - pt-online-schema-change -- host=192.168.97.51 -- user=lixl -- password=lixl -- alter="ADD index ol_i_id_in(ol_i_id)" D=testg,t=order_line -- execu|-- dry-run -- print

  - ghost {https:-- mp.weixin.qq.com/s/qRgUu7uYnTitI8nOgYBm_Q|https:-- mp.weixin.qq.com/s/5eO6NqBvX2T2Qd6T4Y5Qzg}

    ​	

## 14  故障分析：

#### 14.1	[CPU高利用率及IO高负载定位分析 ：](https:-- www.cnblogs.com/broadway/p/16805847.html)

MySQL 5.7 版本起，performance_schema.threads线程表可以查询各个线程的信息，THREAD_OS_ID值对应OS中的线程（PID），这就为故障定位提供了便捷，SQL如下：

top -H -u MySQL  （查看用户mysql所有线程详细信息）

```sql
select
    t.THREAD_ID,
    t.PROCESSLIST_ID,
    t.THREAD_OS_ID,
    t.PROCESSLIST_USER,
    t.PROCESSLIST_HOST,
    t.PROCESSLIST_DB,
    t.PROCESSLIST_TIME,
    t.PROCESSLIST_STATE,
--    esc.SQL_TEXT
	 p.info
from
    performance_schema.threads t
--    join performance_schema.events_statements_current esc on t.THREAD_ID = esc.THREAD_ID
join information_schema.processlist p on t.processlist_id = p.id
where
    t.THREAD_OS_ID =?
```

events_statements_current 中的sql_text 会截断长sql、information_schema.processlist 中可查验完整sql

#### 14.2	高IO负载定位分析：

iotop -ou mysql

SQL同上



通过TID查找执行的SQL:
select p.* from information_schema.processlist p,performance_schema.threads t where t.PROCESSLIST_ID=p.id and THREAD_OS_ID in (**23114**)

## 15	查看最近SQL：

SELECT THREAD_ID,EVENT_NAME,SOURCE,sys.format_time(timer_wait),sys.format_time(lock_time),sql_text,CURRENT_SCHEMA,MESSAGE_TEXT,ROWS_SENT,
ROWS_EXAMINED FROM events_statements_history WHERE CURRENT_SCHEMA != 'performance_schema' ORDER BY TIMER_WAIT DESC LIMIT 100
