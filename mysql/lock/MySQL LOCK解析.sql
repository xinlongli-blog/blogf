-- *** SqlDbx Personal Edition ***
-- !!! Not licensed for commercial use beyound 90 days evaluation period !!!
-- For version limitations please check http://www.sqldbx.com/personal_edition.htm
-- Number of queries executed: 1337, number of rows retrieved: 1176540
SELECT 
* FROM mysql.user

SHOW
 variables LIKE 'innodb_thread_concurrency'
 
 SELECT
  *FROM information_schema.tables WHERE table_name='sbtest1'

SELECT
 count(*) FROM sbtest1

SELECT connection_id()

-- 找全局读锁
-- **全局读锁ftwrl即 flush table with read lock 加的、须有reload权限 排查流程如下:
-- **performance_schema.processlist 查询state为waiting for global read lock 等待全局读锁
-- **information_schema.innodb_locks、innodb_locks_waits、innodb_trx、show engine innodb status 无有效信息
-- **performance_schema.metadata_locks 记录各种server层锁的信息 包括全局和MDL锁
-- **SELECT*FROM metadata_locks WHERE OWNER_THREAD_ID != sys.ps_thread_id(connection_id()) \全局读锁在该表中通常记录着同一个会话的OBJECT TYPE为qlobal和commit、LOCKTYPE都为SHARED的两把显式锁\
-- **'SHARED'共享锁 'EXPLICIT'显示 'GRANTED'已授予 'OWNER_THREAD_ID'持有锁的内部线程id为3349 (补充:'INTENTION_EXCLUSIVE'意向排他锁 'STATEMENT'语句 'PENDING'表示正在等待被授予)
-- **查看process id 线程各自对应的内部线程ID是多少、 如果process id的线程对应内部线程ID 表示process id的线程持有了全局读锁
SELECT
 * FROM performance_schema.processlist;

SELECT
 *FROM
metadata_locks WHERE OWNER_THREAD_ID != sys.ps_thread_id(connection_id())


SELECT THREAD_ID,EVENT_NAME,SOURCE,sys.format_time(timer_wait),sys.format_time(lock_time),sql_text,CURRENT_SCHEMA,MESSAGE_TEXT,ROWS_SENT,
ROWS_EXAMINED FROM events_statements_history WHERE CURRENT_SCHEMA != 'performance_schema' ORDER BY TIMER_WAIT DESC LIMIT 100

SELECT SCHEMA_NAME,DIGEST_TEXT,COUNT_STAR,sys.format_time(sum_timer_wait) AS sum_time,
sys.format_time(MIN_TIMER_WAIT) AS min_time,
sys.format_time(AVG_TIMER_WAIT) AS agv_time,
sys.format_time(MAX_TIMER_WAIT) AS max_time,
sys.format_time(SUM_LOCK_TIME) AS sum_lock_time,
SUM_ROWS_AFFECTED,SUM_ROWS_SENT,SUM_ROWS_EXAMINED FROM events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL ORDER BY COUNT_STAR DESC  

SHOW variables LIKE 'gen%'

SET GLOBAL general_log ='ON'
SET GLOBAL general_log_file ='/data/mysql_8034/log/general.log'

SHOW GLOBAL STATUS LIKE 'innodb_redo_log_enabled'

-- *** SqlDbx Personal Edition ***
-- !!! Not licensed for commercial use beyound 90 days evaluation period !!!
-- For version limitations please check http://www.sqldbx.com/personal_edition.htm
-- Number of queries executed: 1377, number of rows retrieved: 1181560


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



DESC events_statements_history
DESC events_statements_summary_by_digest
SELECT THREAD_ID,'EVENT_NAME','SOURCE',sys.format_time(timer_wait),sys.format_time(lock_time),sql_text,'CURRENT_SCHEMA','MESSAGE_TEXT','ROWS_SENT',

'ROWS_EXAMINED' FROM events_statements_history WHERE CURRENT_SCHEMA != 'performance_schema' ORDER BY TIMER_WAIT DESC LIMIT 100


SELECT THREAD_ID,EVENT_NAME,SOURCE,sys.format_time(timer_wait),sys.format_time(lock_time),sql_text,CURRENT_SCHEMA,MESSAGE_TEXT,ROWS_SENT,
ROWS_EXAMINED FROM events_statements_history WHERE CURRENT_SCHEMA != 'performance_schema' ORDER BY TIMER_WAIT DESC LIMIT 100

SELECT SCHEMA_NAME,DIGEST_TEXT,COUNT_STAR,sys.format_time(sum_timer_wait) AS sum_time,
sys.format_time(MIN_TIMER_WAIT) AS min_time,
sys.format_time(AVG_TIMER_WAIT) AS agv_time,
sys.format_time(MAX_TIMER_WAIT) AS max_time,
sys.format_time(SUM_LOCK_TIME) AS sum_lock_time,
SUM_ROWS_AFFECTED,SUM_ROWS_SENT,SUM_ROWS_EXAMINED FROM events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL ORDER BY COUNT_STAR DESC  