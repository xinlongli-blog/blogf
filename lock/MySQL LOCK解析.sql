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

-- ��ȫ�ֶ���
-- **ȫ�ֶ���ftwrl�� flush table with read lock �ӵġ�����reloadȨ�� �Ų���������:
-- **performance_schema.processlist ��ѯstateΪwaiting for global read lock �ȴ�ȫ�ֶ���
-- **information_schema.innodb_locks��innodb_locks_waits��innodb_trx��show engine innodb status ����Ч��Ϣ
-- **performance_schema.metadata_locks ��¼����server��������Ϣ ����ȫ�ֺ�MDL��
-- **SELECT*FROM metadata_locks WHERE OWNER_THREAD_ID != sys.ps_thread_id(connection_id()) \ȫ�ֶ����ڸñ���ͨ����¼��ͬһ���Ự��OBJECT TYPEΪqlobal��commit��LOCKTYPE��ΪSHARED��������ʽ��\
-- **'SHARED'������ 'EXPLICIT'��ʾ 'GRANTED'������ 'OWNER_THREAD_ID'���������ڲ��߳�idΪ3349 (����:'INTENTION_EXCLUSIVE'���������� 'STATEMENT'��� 'PENDING'��ʾ���ڵȴ�������)
-- **�鿴process id �̸߳��Զ�Ӧ���ڲ��߳�ID�Ƕ��١� ���process id���̶߳�Ӧ�ڲ��߳�ID ��ʾprocess id���̳߳�����ȫ�ֶ���
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