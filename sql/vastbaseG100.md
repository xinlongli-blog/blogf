# vastbase日常运维汇总

## 1、连接数据库

shell

```
#切换数据库用户
su vastbase -

vsql -r -d vastbase
vsql -d vastbase -h 10.53.136.14 -U root -p 5432 (输入密码)

vb_ctl start
vb_ctl stop
vb_ctl restart
vb_ctl status
```

## 2、常用命令

css

```
\h -- 查看帮助
\l -- 列出所有数据库
\c dbname -- 切换数据库
\dt -- 列出当前数据库所有表
\d tablename -- 列出表的所有字段
\d+ tablename --列出表的基本情况
\di -- 查看索引
\dtS -- 查看系统表
\du+ \dg+ --查看用户
\dp -- 显示表的权限分配情况
\dn -- 显示schemas
\conninfo -- 显示当前登录信息

1、查看某用户的系统权限
SELECT * FROM  pg_roles WHERE rolname='postgres';
2、查看某用户的表权限
select * from information_schema.table_privileges where grantee='postgres';
3、查看某用户的usage权限
select * from information_schema.usage_privileges where grantee='postgres';
4、查看某用户在存储过程函数的执行权限
select * from information_schema.routine_privileges where grantee='postgres'; 
5、查看某用户在某表的列上的权限
select * from information_schema.column_privileges where grantee='postgres';
6、查看当前用户能够访问的数据类型
select * from information_schema.data_type_privileges ; 
7、查看用户自定义类型上授予的USAGE权限
select * from information_schema.udt_privileges where grantee='postgres';

show sql_compatibility; -- 查看数据库初始化时设置的兼容模式,取值范围：A、B、C、PG、MSSQL分别表示兼容Oracle、MySQL、Teradata、PostgreSQL和SQL Server

#查询当前的schema
select current_schema; 
#切换路径到对应的schema下
set search_path to myschema;

#执行sql脚本
vsql -d vastbase -f sql.sql
\i /home/vastbase/sql.sql (命令行执行)

#命令行导出导入某张表数据
\copy testtab1 to /home/vastbase/testtab1.txt
\copy (select col1,col2 from testtab1) to /home/vastbase/testtab1.txt
truncate table testtab1
\copy testtab1 from /home/vastbase/testtab1.txt

vb_guc set -I all -N all -c "wal_level=logical" --修改设置数据库参数值
vsql -c "show wal_level" --查询数据库参数当前值
vb_guc set -I all -N all -c "max_wal_senders=10"
vsql -c "show max_wal_senders"
vb_ctl reload --加载配置

#查看数据库实例状态
vb_ctl status 
#查询主从同步状态
vb_ctl query
cp -a /data/vastbasedata/install/data/dn /data/vastbasedata/install/data/dn_bak20250102 --备份

#查看license授权
show license_path;
vb_licensetool --dump /home/vastbase/.license

#查看表膨胀情况
select reltuples,relpages,relname from pg_class where relname = 'tk_kdyq_yq_xm';
#手动清理回收
vacuum full tk_kdyq_yq_xm;

#解锁或锁定账号
alter user joe account unlock;
alter user joe account lock;

#切换用户
\c - [user_name]

#查询数据库启动时间
vsql -c "select pg_postmaster_start_time();"

#查询数据库的编码方式
vsql -c "select getdatabaseencoding();"

#查询数据库服务版本
vsql -c "select version();"

#查询vastbase产品版本信息
vsql -c "select vb_version();"

#查询复制槽
select * from pg_replication_slots;

#查看集群状态-高可用组件，主备集群下主恢复完数据以后，备会自动build数据，磁盘数据量会变化
has_ctl query -Civ
```



## 3、创建用户并赋权

shell

```
create user ccci_user with password 'ccci@2024';
create user ccci_read_user with password 'read#2024';

grant connect on database "ccci_contract" to ccci_user;
\c ccci_contract
grant usage on schema ccci_contract to ccci_user;
grant select on all tables in schema ccci_contract to ccci_user;
grant all privileges on all tables in schema ccci_contract to ccci_user;

# 给用户赋予某种角色
create user sysadmin with SYSADMIN password "Bigdata@123";
alter user ccci_user SYSADMIN;

# 根据需要赋予any权限
GRANT CREATE ANY TABLE,SELECT ANY TABLE,INSERT ANY TABLE,UPDATE ANY TABLE,DELETE ANY TABLE,CREATE ANY SEQUENCE,CREATE ANY INDEX,CREATE ANY FUNCTION,EXECUTE ANY FUNCTION,CREATE ANY PACKAGE,EXECUTE ANY PACKAGE,CREATE ANY TYPE,ALTER ANY TYPE,DROP ANY TYPE,ALTER ANY SEQUENCE,DROP ANY SEQUENCE,SELECT ANY SEQUENCE,ALTER ANY INDEX,DROP ANY INDEX,CREATE ANY SYNONYM,DROP ANY SYNONYM,CREATE ANY TRIGGER,ALTER ANY TRIGGER,DROP ANY TRIGGER TO qx_rw;

# 权限分类
select -- 允许对指定的表、视图、序列执行select命令
insert -- 允许对指定的表执行insert命令
update -- 允许对声明的表中任意字段执行update命令
delete -- 允许执行delete命令删除指定表中的数据
truncate -- 允许执行truncate语句删除指定表中的所有记录
references -- 创建一个外键约束，必须拥有参考表和被参考表的references权限

create -- 对于库允许在数据库里创建新模式，对于模式允许创建新的对象，对于表空间允许创建表
connect -- 允许用户连接到指定的数据库
temporary -- 允许在指定的数据库中创建临时表
execute -- 允许使用指定的函数
usage -- 对于模式，允许访问包含在指定模式中的对象
alter -- 修改数据库表的结构，非表中的数据
drop -- 允许用户删除指定的对象，库
index -- 允许用户在指定的表上创建索引并管理索引
comment -- 允许用户定义或修改指定对象的注释
VACUUM -- 允许用户对指定的表执行ANALYZE和VACUUM操作
ALL PRIVILEGES -- 一次性给指定用户/角色赋予所有可赋予的权限。只有系统管理员有权执行GRANT ALL PRIVILEGES
```

```sql
---查看表级权限
CREATE OR REPLACE FUNCTION table_privs(p_username text)
RETURNS TABLE(username text, relname text, privs text[])
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p_username,
    c.relname::text,
    ARRAY(
      SELECT priv 
      FROM unnest(ARRAY[
        CASE WHEN has_table_privilege(p_username, c.oid, 'SELECT') THEN 'SELECT' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'INSERT') THEN 'INSERT' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'UPDATE') THEN 'UPDATE' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'DELETE') THEN 'DELETE' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'TRUNCATE') THEN 'TRUNCATE' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'REFERENCES') THEN 'REFERENCES' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'TRIGGER') THEN 'TRIGGER' ELSE NULL END
      ]) AS priv WHERE priv IS NOT NULL
    )
  FROM pg_class c
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE n.nspname NOT IN ('information_schema','pg_catalog','sys')
    AND c.relkind IN ('r', 'v', 'm', 'f')
    AND has_table_privilege(p_username, c.oid, 'SELECT, INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
    AND has_schema_privilege(p_username, c.relnamespace, 'USAGE');
END;
$$;

SELECT 
    grantee AS user, 
    CONCAT(table_schema, '.', table_name) AS table, 
    CASE 
        WHEN COUNT(privilege_type) = 7 THEN 'ALL'
        ELSE ARRAY_TO_STRING(ARRAY_AGG(privilege_type::text), ', ')
    END AS grants
FROM information_schema.role_table_grants
GROUP BY table_name, table_schema, grantee;

---查看库级权限
CREATE OR REPLACE FUNCTION database_privs(p_username text)
RETURNS TABLE(username text, dbname text, privileges text[])
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p_username,
    d.datname::text,  -- 强制转换为 text
    ARRAY(
      SELECT priv
      FROM unnest(ARRAY[
        CASE WHEN has_database_privilege(p_username, d.oid, 'CONNECT') THEN 'CONNECT' ELSE NULL END,
        CASE WHEN has_database_privilege(p_username, d.oid, 'CREATE') THEN 'CREATE' ELSE NULL END,
        CASE WHEN has_database_privilege(p_username, d.oid, 'TEMPORARY') THEN 'TEMPORARY' ELSE NULL END,
        CASE WHEN has_database_privilege(p_username, d.oid, 'TEMP') THEN 'TEMP' ELSE NULL END
      ]) AS priv
      WHERE priv IS NOT NULL
    )
  FROM pg_database d
  WHERE datname NOT IN ('template0')
    AND has_database_privilege(p_username, d.oid, 'CONNECT,CREATE,TEMPORARY,TEMP');
END;
$$;

---查看模式权限
CREATE OR REPLACE FUNCTION schema_privs(p_username text)
RETURNS TABLE(username text, schemaname name, privileges text[])
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p_username,
    c.nspname,
    ARRAY(
      SELECT privs 
      FROM unnest(ARRAY[
        CASE WHEN has_schema_privilege(p_username, c.oid, 'CREATE') THEN 'CREATE' ELSE NULL END,
        CASE WHEN has_schema_privilege(p_username, c.oid, 'USAGE') THEN 'USAGE' ELSE NULL END
      ]) AS privs
      WHERE privs IS NOT NULL
    )
  FROM pg_namespace c
  WHERE has_schema_privilege(p_username, c.oid, 'CREATE,USAGE');
END;
$$;

select  
  r.usename as grantor, e.usename as grantee, nspname, privilege_type, is_grantable
from pg_namespace
join lateral (
  SELECT
    *
  from
    aclexplode(nspacl) as x
) a on true
join pg_user e on a.grantee = e.usesysid
join pg_user r on a.grantor = r.usesysid 
 where e.usename = 'itwb_songwh';
 
 
 ---查询视图权限
 CREATE OR REPLACE FUNCTION view_privs(p_username text)
RETURNS TABLE(username text, viewname regclass, privileges text[])
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p_username,
    c.oid::regclass,
    ARRAY(
      SELECT privs FROM unnest(ARRAY[
        CASE WHEN has_table_privilege(p_username, c.oid, 'SELECT') THEN 'SELECT' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'INSERT') THEN 'INSERT' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'UPDATE') THEN 'UPDATE' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'DELETE') THEN 'DELETE' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'TRUNCATE') THEN 'TRUNCATE' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'REFERENCES') THEN 'REFERENCES' ELSE NULL END,
        CASE WHEN has_table_privilege(p_username, c.oid, 'TRIGGER') THEN 'TRIGGER' ELSE NULL END
      ]) AS privs
      WHERE privs IS NOT NULL
    )
  FROM pg_class c 
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE n.nspname NOT IN ('information_schema','pg_catalog','sys')
    AND c.relkind = 'v'
    AND has_table_privilege(p_username, c.oid, 'SELECT, INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
    AND has_schema_privilege(p_username, c.relnamespace, 'USAGE');
END;
$$;


 ---查看表空间权限
 CREATE OR REPLACE FUNCTION tablespace_privs(p_username text)
RETURNS TABLE(username text, spcname name, privileges text[])
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p_username,
    spc.spcname,
    array_remove(ARRAY[
      CASE WHEN has_tablespace_privilege(p_username, spc.spcname, 'CREATE') THEN 'CREATE' ELSE NULL END
    ], NULL)
  FROM pg_tablespace spc
  WHERE has_tablespace_privilege(p_username, spc.spcname, 'CREATE');
END;
$$;

---查询权限
select * from (
select username,'SCHEMA' as object_type,schemaname as object_name,privileges
    FROM schema_privs('xiongcc')
 UNION ALL
SELECT username,'TABLE' as object_type ,relname::name as object_name ,privs
 FROM table_privs('xiongcc') 
  UNION ALL
SELECT username,'DATABASE' as object_type ,dbname as object_name ,privileges
 FROM database_privs('xiongcc') 
 UNION ALL
SELECT username,'TABLESPACE' as object_type ,spcname as object_name ,privileges
 FROM tablespace_privs('xiongcc') 
 ) as text1 order by 2 ;
```



## 4、修改数据库大小写敏感性

shell

```
# lower_case_column_names参数数据库返回字段名的大小写敏感性
# 查看参数方式
su - vastbase
vsql -r -d vastbase
show lower_case_table_names;
show lower_case_column_names;

# 修改参数方式
su - vastbase
cd $PGDATA
vi postgresql.conf
lower_case_table_names = 1 --对象名大小写不敏感
lower_case_column_names = 1 --字段大小写不敏感
wq保存

# 重启数据库使配置生效
vb_ctl restart
```

## 5、修改id自增

mysql

```
SELECT sequence_schema, sequence_name FROM information_schema.sequences;
grant usage on sequence ccci_infra.file_info_id_seq to ccci_user;
```

## 6、修改空闲会话超时设置（会影响seata事务回滚）

shell

```
# session_timeout 空闲会话超时设置,0为不限时间
su - vastbase
vsql -c "show session_timeout"
vb_guc set -I all -N all -c "session_timeout=0"
vb_ctl reload
```

## 7、归档文件删除（archive_wals）

shell

```
# 可以在vastbase用户下建一个清理的定时任务，如下
* 1 * * * find /data/archive_wals -maxdepth 1 -name "00*" -mtime +7 -exec rm -f {} \;
# /data/archive_wals/替换成环境实际的归档目录路径
```

## 8、海量VEM监控配置

shell

```
# IP: 10.53.143.14
# 安装包目录: /usr/local/src/vastem_2.16.3
# 安装目录: /opt/vem
# 启停监控操作
./control.sh stop all
./control.sh start all
./control.sh status
# 报错是因为缺少libssl.so.10
find / -name libssl.so.10
yum install -y compat-openssl10
psql -d postgres -U vastem
```

## 9、动态内存修改

shell

```
# 显示某个数据库节点内存使用情况
select * from pg_total_memory_detail;
select case when 
memorytype='max_process_memory'      then 'VastbaseG100实例允许占用的最大内存'
     when memorytype='process_used_memory'     then '数据库进程占用的内存'
     when memorytype='max_dynamic_memory'      then '最大动态内存'
     when memorytype='dynamic_used_memory'     then '已使用的动态内存'
     when memorytype='dynamic_peak_memory'     then '内存的动态峰值'
     when memorytype='dynamic_used_shrctx'     then '最大动态共享内存上下文'
     when memorytype='dynamic_peak_shrctx'     then '共享内存上下文的动态峰值'
     when memorytype='max_shared_memory'       then '最大共享内存'
     when memorytype='shared_used_memory'      then '已使用的共享内存'
     when memorytype='max_cstore_memory'       then '列存所允许使用的最大内存'
     when memorytype='cstore_used_memory'      then '列存已使用的内存大小'
     when memorytype='max_sctpcomm_memory'  then 'sctp通信所允许使用的最大内存'
     when memorytype='sctpcomm_used_memory'    then 'sctp通信已使用的内存大小'
     when memorytype='sctpcomm_peak_memory'    then 'sctp通信的内存峰值'
     when memorytype='other_used_memory'       then '其他已使用的内存大小'
     when memorytype='gpu_max_dynamic_memory'  then 'GPU最大动态内存'
     when memorytype='gpu_dynamic_used_memory' then 'GPU已使用的动态内存'
     when memorytype='gpu_dynamic_peak_memory' then 'GPU内存的动态峰值'
     when memorytype='pooler_conn_memory'      then '链接池申请内存计数'
     when memorytype='pooler_freeconn_memory'  then '链接池空闲连接的内存计数'
    when memorytype='storage_compress_memory' then '存储模块压缩使用的内存大小'
     when memorytype='udf_reserved_memory'     then 'UDF预留的内存大小'
	 else memorytype end as memorytype
	 ,memorymbytes from pg_total_memory_detail; 
	 
# 设置数据库节点可用的最大物理内存
show max_process_memory; 
# 设置Vastbase使用的共享内存大小
show shared_buffers; 

# 计算内核参数的值
echo "kernel.sem= `cat /proc/sys/kernel/sem`" && cat /proc/meminfo|grep MemTotal|awk {'print $2'*1024*0.8/$(getconf PAGE_SIZE)}|awk '{printf "kernel.shmall=%d\n",$1}' && cat /proc/meminfo|grep MemTotal| awk '{printf "kernel.shmmax=%d\n",$2*1024*0.8}' && echo "kernel.shmmni =`cat /proc/sys/kernel/shmmni`"

kernel.sem= 250 6400000 1000    25600
kernel.shmall=611078
kernel.shmmax=40047634022
kernel.shmmni =8192

# 修改操作系统内核参数
vim /etc/sysctl.conf

fs.aio-max-nr=1048576
fs.file-max= 76724600
kernel.sem = 250 6400000 1000 25600
kernel.shmall = 611078
kernel.shmmax = 40047634022
kernel.shmmni = 8192
net.core.netdev_max_backlog = 10000
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 4194304
net.core.somaxconn = 4096
net.ipv4.tcp_fin_timeout = 5
vm.overcommit_memory = 0
vm.swappiness = 10
net.ipv4.ip_local_port_range = 40000 65535
fs.nr_open = 20480000

sysctl -p

# 修改配置文件
vim $PGDATA/postgresql.conf
work_mem =4MB
shared_buffers = 18GB
wal_buffers=128MB
max_process_memory=38GB
effective_cache_size=38GB
maintenance_work_mem = 512MB

vb_ctl reload

--- --- --- 
max_dynamic_memory = max_process_memory - cstore_buffers - udf_memory - shared_memory - backend_reserved_memory
max_dynamic_memory和max_process_memory正相关，和shared_buffers、max_connections、work_mem、maintenance_work_mem这些负相关，这些参数是相互影响的

shared_buffers 最大共享内存通常按照OS_MEM（1/4）设置
max_process_memory 实例允许占用的最大内存按照OS_MEM（3/4）设置

数据库服务器总内存32G：
max_connections=500
shared_buffers=8GB
max_process_memory = 24GB
effective_cache_size = 24GB
maintenance_work_mem = 512MB
work_mem=4MB
```

## 10、查看连接数

shell

```
# 查看当前连接总数
select count(1) from pg_stat_activity;
# 查看最大连接数
show max_connections;
# 修改配置文件
max_connections=2000 32G
# 查询参数生效是否需要重启，参数级别是postmaster的需重启生效 
select postmaster，*  from  pg_settings  where name='shared_buffers';
```

## 11、许可替换

shell

```
# 许可路径
license_path='/data/vastbasedata/install/app/.license'
# 步骤
# root用户执行
mv /data/vastbasedata/install/app/.license /data/vastbase/install/app/ol
cp 上传的授权文件 /data/vastbasedata/install/app/.license
chown vastbase vastbase /data/vastbasedata/install/app/.license
# vastbase用户执行
vim $PGDATA/postgresql.conf
#末行添加
license_path='/data/vastbasedata/install/app/.license'
#执行检查有效期
vb_licensetool --dump=/data/vastbasedata/install/app/.license
```

## 12、statscollector异常写入导致IO下降

shell

```
#原因：autovacuum相关参数的调整导致autovacuum执行更频繁
vacuum_cost_limit=200 --> 10000  #自动vacuum操作里使用的开销限制数值
autovacuum_max_workers=3 --> 5   #能同时运行的自动清理线程的最大数量
autovacuum_naptime=10min --> 20s （改回10min）  #设置两次自动清理操作的时间间隔
autovacuum_vacuum_cost_delay=20ms --> 10  #设置在自动vacuum操作里使用的开销延迟数值
autovacuum_vacuum_scale_factor=0.2 -->0.02 （改回0.2） #设置触发一个VACUUM时增加到autovacuum_vacuum_threshold的表大小的缩放系数
#以上参数的调整导致了autovacuum更频繁的执行，表的死元组会被更快的回收，统计信息会更准确，但同时也会消耗更多的cpu及io资源

enable_wdr_snapshot  #数据库postgres下新建snapshot导致暂用几十个G，最好关掉
wdr_snapshot_retention_days
```

## 13、vastbase备份

shell

```
1、创建备份目录
mkdir -p /data/backup/
chown vastbase:vastbase /data/backup

2、初始化备份目录
vb_probackup init -B /data/backup

3、添加备份实例
vb_probackup add-instance -B /data/backup -D /data/vastbasedata/install/data/dn --instance=ylt-prod-vb

4、设置备份配置
vb_probackup set-config -B /data/backup --instance=ylt-prod-vb -D /data/vastbasedata/install/data/dn --retention-redundancy=7 --retention-window=7 --wal-depth=2 --compress-algorithm=zlib --compress-level=6 -d vastbase -p 5432 --log-level-file=info --log-filename=full_backup-%Y%m%d.log --log-rotation-size=50MB

5、查看备份配置
vb_probackup show-config -B /data/backup --instance=ylt-prod-vb

6、查看备份内容
vb_probackup show -B /data/backup

7、全量备份
vb_probackup backup -B /data/backup --instance=ylt-prod-vb -b full -j 4 --delete-wal --delete-expired
vb_probackup backup -B /data/backup --instance=ylt-prod-vb -b full -j 8

8、校验备份
vb_probackup validate -B /data/backup/ --instance=ylt-prod-vb -j 8 -i SVZUC4

9、删除备份
vb_probackup delete -B /data/backup --instance=ylt-prod-vb -i SQ4EKE

10、恢复备份
cd $PGDATA
rm -rf *
vb_probackup restore -B /data/backup --instance ylt-prod-vb -D /data/vastbasedata/install/data/dn -j 8 -i SVZUC4

--- ---
逻辑备份
\l 
\c ccci_order
\dt
set search_path to ccci_order
/data/dump_data/0516
vb_dump -C -c -f ccci_contract_202505160859.sql ccci_contract
vb_dump -C -c -f ccci_order_202505160901.sql ccci_order
vb_dump -C -c -f ccci_storage_202505160921.sql ccci_storage
vb_dump -C -c -f ccci_settlement_202505160922.sql ccci_settlement

tar -zcvf ylt-prod-data_0516.tar.gz
tar -zxvf ylt-prod-data_0516.tar.gz
mv 0516 ylt-prod-data_0516
chown -R vastbase:vastbase ylt-prod-data_0516

cd /data/dump_data/ylt-prod-data_0516
vsql -r
clean connection to all force for database ccci_settlement;
\i ccci_settlement_202505160922.sql ccci_settlement

--- ---
逻辑备份2
# 生产环境 ccci_contract 库导入 PRE 环境步骤
1、备份 PRE 环境 ccci_contract 库
vb_dump -C -c -f ccci_contract_202505160859.sql ccci_contract
vb_dump -C -c -f ccci_contract_$(date +%Y%m%d%H%M%S).sql ccci_contract
2、备份生产环境 ccci_contract 库
vb_dump -C -c -f ccci_contract_202505160908.sql ccci_contract
vb_dump -C -c -f ccci_contract_$(date +%Y%m%d%H%M%S).sql ccci_contract
3、拷贝生产 ccci_contract 库备份到 PRE 服务器
cd /data/dump_data/0521
tar -czvf ylt-prod-data_0521.tar.gz 0521
scp -p ylt-prod-data_0521.tar.gz root@10.53.136.15:/tmp
PBData#123
切换到PRE服务器上
tar -xzf ylt-prod-data_0521.tar.gz
mv 0521 ylt-prod-data_0521
mv ylt-prod-data_0521 /data/dump_data/
cd /data/dump_data/
cd ylt-prod-data_0521/
md5sum * （只能校验文件，不能校验文件夹）
4、修改备份文件（替换用户名，备份文件内容中涉及到的数据库关键字处理）
cd /data/dump_data/ylt-prod-data_0521
sed -i 's/ccci_prod_user/ccci_user/g' *
vim ccci_contract_20250521164411.sql
CREATE TABLE sys_config下关键字key加引号，即"key"
5、停掉 ltd-ccci-svc-contract 服务并手动清理 PRE 环境 ccci_contract 库的连接，确保导入时删库成功
clean connection to all force for database ccci_contract;
6、导入备份到 PRE 环境 ccci_contract 库
vsql -r 
\i ccci_contract_20250521164411.sql
7、验证导入的数据，检查表数量和表数据条数及表结构
```

## 14、vastbase备份恢复

shell

```
mv /opt/software/vastdata /opt/software/vastdata_old
mkdir -p /opt/software/vastdata
vb_probackup restore -B /opt/software/backup --instance production -i SUB98Q -D /opt/software/vastdata
vb_probackup restore -B /opt/software/backup --instance production --recovery-target-time="2025-04-07 18:15:09+8" -D /opt/software/vastdata
vb_probackup validate -B /opt/software/backup --instance production -j 8
pg_controldata 得到识别号，修改pg_probackup.conf

#恢复数据，先恢复全备后不启动数据库，然后剩余的wal日志保存在一个目录下，通过在$PGDATAT目录下创建recovery.conf文件后启动数据库自动恢复数据
restore_command = 'cp /opt/software/backup/wal/production/%f %p'
recovery_target_time = '2025-04-08 18:15:09+08'
```

## 15、SQL语句报内存不足

shell

```
# 问题原因
排查会话内存使用情况发，数据库中存在大量的idle连接，idle连接会使用内存，导致动态内存达到上限，导致业务报错内存不足
# 优化建议
1、调整数据库参数sessiontimeout，对超时的idle连接进行释放。目前sessiontimeout=10min，表示会自动关闭超过10min的空闲连接，此值可进一步调小，前提是不会对业务产生影响
2、业务使用连接池，可以降低建立连接的代价，提高连接的使用率，防止连接用完不会收长时间占用内存。

# 数据库连接
select state,count(*) from pg_stat_activity group by state order by 2; 
# 数据库内存占用
select * from pg_total_memory_detail; 
# 查看连接的内存占用
select a.client_addr,a.usename,a.state,a.query_start,a.pid,left(a.query,50),sum(d.totalsize/1000/1000)||'MB' from dbe_perf.session_memory_detail d,pg_stat_activity a where a.pid=right(d.sessid,14)  group by 1,2,3,4,5,6 order by 7 desc; 
# 强制终止空闲的用户会话
select pg_terminate_backend(pid) from pg_stat_activity where state='idle';
```

Pager