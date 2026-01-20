### 网络协议

本文以数据库抓包为基础简述。（相关信息来自转载，例：图）

##### 部署：

```sql
yum install -y epel-release
yum install -y wireshark

[root@postgre pg_log]# tshark -v
TShark 1.10.14 (Git Rev Unknown from unknown)

# rpm
相关依赖：
libcares-1.18.1-alt1.x86_64.rpm     -- https://pkgs.org/download/libcares                                                                                              
libsmi-0.4.8-13.el7.x86_64.rpm      -- https://pkgs.org/download/libsmi
wireshark-1.10.14-25.el7.x86_64.rpm -- https://pkgs.org/download/wireshark
rpm -Uvh *.rpm --nodeps --force
[root@postgre pg_log]# tshark -v
TShark 1.10.14 (Git Rev Unknown from unknown)
```

##### 基础知识：

##### 三次握手和四次挥手：

三次握手：

```sql
客户端向服务器发送 SYN 报文（请求建立连接）
服务器收到 SYN 报文后，回复 SYN+ACK 报文（同意建立连接）
客户端收到 SYN+ACK 报文后，再回复 ACK 报文（确认连接建立）
```

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/a4DRmyJYHOzVDkgNTicKdJXvjibmkSlCibWDreQLNQmVjempzOgxHFKYZgl8uBUBkHibpUMTRuob9wPaqjDq4oodfQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

四次挥手：

```sql
客户端向服务器发送 FIN 报文（请求断开连接）
服务器收到 FIN 报文后，回复 ACK 报文（确认收到请求）
当服务器确认数据已经全部发送完毕后，它会向客户端发送 FIN 报文（关闭连接）
客户端收到 FIN 报文后，回复 ACK 报文（表示确认收到关闭请求），至此，整个 TCP 连接就被彻底关闭了
```

![图片](https://mmbiz.qpic.cn/sz_mmbiz_png/a4DRmyJYHOzVDkgNTicKdJXvjibmkSlCibWqO1x5O2qxAEp13z0DxQkTexPS6YS5VSF2KJwUnEl2QeeZmmAtdibiceg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

三次握手用于建立连接，是双方协商建立 TCP 连接的过程；四次挥手用于断开连接，是双方结束 TCP 连接的过程；不过，有时候四次挥手也会变成三次（如果没有数据发送，2 个包会合并传输）。

##### 三次握手和四次挥手的过程：

通过tshark抓包观察TCP连接、断开的具体过程。

```sql
--服务端 tshark进行抓包
[root@postgre pg_log]# tshark -i ens33 -f 'tcp port 3306 and host 192.168.97.222'
Running as user "root" and group "root". This could be dangerous.
Capturing on 'ens33'
==> 等待捕获 TCP 包直到有内容输出
 # -i，默认会选择第一个非 loopback 的网络接口（可简写为 lo），效果与指定 -i eth0 相同
 # -f，指定捕获过滤器的表达式，可指定需要捕获的内容，如：协议、端口、主机IP等
 
 -- 通过 MySQL 客户端远程(Navicat)连接到 MySQL 实例，等待片刻后再退出
 
 -- 观察屏幕输出
 # 从左到右的字段依次代表序号、时间戳（纳秒）、源端 IP、目标端 IP、协议、包的长度（字节）、具体信息（包括源/目标端口号或设备名、标志位等内容）
  1 0.000000000 192.168.97.91 -> 192.168.97.222 MySQL 60 Request Quit
  2 0.000029644 192.168.97.91 -> 192.168.97.222 TCP 60 62738 > mysql [FIN, ACK] Seq=6 Ack=1 Win=8208 Len=0
  3 0.000173413 192.168.97.222 -> 192.168.97.91 TCP 54 mysql > 62738 [FIN, ACK] Seq=1 Ack=7 Win=262 Len=0
  4 0.000274852 192.168.97.91 -> 192.168.97.222 TCP 60 62738 > mysql [ACK] Seq=7 Ack=2 Win=8208 Len=0
  5 21.380736490 192.168.97.91 -> 192.168.97.222 TCP 66 62288 > mysql [SYN] Seq=0 Win=64240 Len=0 MSS=1460 WS=256 SACK_PERM=1
  6 21.380779912 192.168.97.222 -> 192.168.97.91 TCP 66 mysql > 62288 [SYN, ACK] Seq=0 Ack=1 Win=29200 Len=0 MSS=1460 SACK_PERM=1 WS=128
  7 21.380872215 192.168.97.91 -> 192.168.97.222 TCP 60 62288 > mysql [ACK] Seq=1 Ack=1 Win=2102272 Len=0
  8 21.381091385 192.168.97.222 -> 192.168.97.91 MySQL 136 Server Greeting proto=10 version=5.7.27-log
  9 21.381230559 192.168.97.91 -> 192.168.97.222 MySQL 265 Login Request user=lixl
 10 21.381254694 192.168.97.222 -> 192.168.97.91 TCP 54 mysql > 62288 [ACK] Seq=83 Ack=212 Win=30336 Len=0
 11 21.381320658 192.168.97.222 -> 192.168.97.91 MySQL 65 Response OK
 12 21.381425714 192.168.97.91 -> 192.168.97.222 MySQL 76 Request Query
 13 21.381516347 192.168.97.222 -> 192.168.97.91 MySQL 165 Response OK
 14 21.383817401 192.168.97.91 -> 192.168.97.222 MySQL 217 Request Query
 15 21.385415437 192.168.97.222 -> 192.168.97.91 MySQL 293 Response
 16 21.386518076 192.168.97.222 -> 192.168.97.91 MySQL 384 Response
 17 21.386696295 192.168.97.91 -> 192.168.97.222 TCP 60 62288 > mysql [ACK] Seq=397 Ack=774 Win=2101504 Len=0
 18 21.386832116 192.168.97.222 -> 192.168.97.91 MySQL 120 Response
 19 21.388410903 192.168.97.91 -> 192.168.97.222 MySQL 162 Request Query
 20 21.388815454 192.168.97.222 -> 192.168.97.91 MySQL 622 Response
 21 21.429155253 192.168.97.91 -> 192.168.97.222 TCP 60 62288 > mysql [ACK] Seq=505 Ack=1408 Win=2100992 Len=0
 
 # 序号2-4的包，即TCP四次挥手的过程（为什么有三次，其因是所以将 FIN 和 ACK 合并在一个 TCP 包中了，即所谓的四次挥手变成了三次。 流程图如上--四次挥手）
  2 0.000029644 192.168.97.91 -> 192.168.97.222 TCP 60 62738 > mysql [FIN, ACK] Seq=6 Ack=1 Win=8208 Len=0
  3 0.000173413 192.168.97.222 -> 192.168.97.91 TCP 54 mysql > 62738 [FIN, ACK] Seq=1 Ack=7 Win=262 Len=0
  4 0.000274852 192.168.97.91 -> 192.168.97.222 TCP 60 62738 > mysql [ACK] Seq=7 Ack=2 Win=8208 Len=0

 # 序号5-7的包，即三次握手
  5 21.380736490 192.168.97.91 -> 192.168.97.222 TCP 66 62288 > mysql [SYN] Seq=0 Win=64240 Len=0 MSS=1460 WS=256 SACK_PERM=1
  6 21.380779912 192.168.97.222 -> 192.168.97.91 TCP 66 mysql > 62288 [SYN, ACK] Seq=0 Ack=1 Win=29200 Len=0 MSS=1460 SACK_PERM=1 WS=128
  7 21.380872215 192.168.97.91 -> 192.168.97.222 TCP 60 62288 > mysql [ACK] Seq=1 Ack=1 Win=2102272 Len=0
```

##### TCP 包标志位的说明：

TCP （传输控制协议）包头部有 6 个标志位（Flag），分别为 URG、ACK、PSH、RST、SYN、FIN，它们的十六进制值分别为：0x20、0x10、0x08、0x04、0x02、0x01，其中每个标志位的意义如下：

- URG 标志：紧急指针是否有效
- ACK 标志：确认号是否有效
- PSH 标志：Push操作，尽可能快地将数据交给应用层
- RST 标志：重置连接
- SYN 标志：发起一个新的连接
- FIN 标志：释放连接

##### tshark使用案例：

```sql
-- 服务端进行抓包
[root@postgre bin]# tshark -i ens33 -d tcp.port==3306,mysql -f "host 192.168.97.222 and tcp port 3306" -T fields -e frame.time -e ip.host -e tcp.flags
Running as user "root" and group "root". This could be dangerous.
Capturing on 'ens33'
 # -T fields，可以指定需要输出的字段，需配合-e一起使用，此处将分别打印获取包的时间、主机IP及TCP的标志位，这些字段会按照-e的顺序进行排列展示
 # -e，支持多种协议下的字段展示，具体用法查询路径：Wireshark -> 分析 -> 显示过滤器表达式

  -- 通过 MySQL 客户端连接实例，执行一个查询，再退出（共有 3 部分：连接、通信、断连）
  	[root@localhost ~]# mysql -h192.168.97.222 -P3306 -ulixl -p
	Enter password:
	Welcome to the MySQL monitor.  Commands end with ; or \g.
	Your MySQL connection id is 16121
	Server version: 5.7.27-log MySQL Community Server (GPL)
	
	Copyright (c) 2000, 2022, Oracle and/or its affiliates.
	
	Oracle is a registered trademark of Oracle Corporation and/or its
	affiliates. Other names may be trademarks of their respective
	owners.
	
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
	
	mysql> select version();
	+------------+
	| version()  |
	+------------+
	| 5.7.27-log |
	+------------+
	1 row in set (0.29 sec)
	
	mysql> exit
	Bye

-- 观察屏幕
1、三次握手
"Jun 20, 2023 11:08:10.482537473 CST"   172.18.100.194,192.168.97.222   0x00000002
"Jun 20, 2023 11:08:10.482576920 CST"   192.168.97.222,172.18.100.194   0x00000012
"Jun 20, 2023 11:08:10.691785632 CST"   172.18.100.194,192.168.97.222   0x00000010
"Jun 20, 2023 11:08:10.692024233 CST"   192.168.97.222,172.18.100.194   0x00000018
"Jun 20, 2023 11:08:10.923236415 CST"   172.18.100.194,192.168.97.222   0x00000010
"Jun 20, 2023 11:08:10.923518555 CST"   172.18.100.194,192.168.97.222   0x00000018
"Jun 20, 2023 11:08:10.923531717 CST"   192.168.97.222,172.18.100.194   0x00000010
"Jun 20, 2023 11:08:10.923647469 CST"   192.168.97.222,172.18.100.194   0x00000018
"Jun 20, 2023 11:08:11.174150634 CST"   172.18.100.194,192.168.97.222   0x00000018
"Jun 20, 2023 11:08:11.174318189 CST"   192.168.97.222,172.18.100.194   0x00000018
"Jun 20, 2023 11:08:11.469253513 CST"   172.18.100.194,192.168.97.222   0x00000010
"Jun 20, 2023 11:08:26.230115563 CST"   172.18.100.194,192.168.97.222   0x00000018
"Jun 20, 2023 11:08:26.230269822 CST"   192.168.97.222,172.18.100.194   0x00000018
"Jun 20, 2023 11:08:26.429483932 CST"   172.18.100.194,192.168.97.222   0x00000010
"Jun 20, 2023 11:09:11.865531067 CST"   172.18.100.194,192.168.97.222   0x00000018
"Jun 20, 2023 11:09:11.865662294 CST"   172.18.100.194,192.168.97.222   0x00000011
"Jun 20, 2023 11:09:11.865690810 CST"   192.168.97.222,172.18.100.194   0x00000011
"Jun 20, 2023 11:09:11.865760205 CST"   192.168.97.222,172.18.100.194   0x00000010
"Jun 20, 2023 11:09:12.097150856 CST"   172.18.100.194,192.168.97.222   0x00000010

	
 # 前三个包分别为：0x02 [SYN] 、0x12 [SYN, ACK] 、0x10 [ACK]，即三次握手的过程
 # 后面的几个包：0x18 [PSH, ACK]、0x10 [ACK]，是数据传输的过程
2、执行一个查询
"Jun 20, 2023 11:08:26.230115563 CST"   172.18.100.194,192.168.97.222   0x00000018
"Jun 20, 2023 11:08:26.230269822 CST"   192.168.97.222,172.18.100.194   0x00000018
"Jun 20, 2023 11:08:26.429483932 CST"   172.18.100.194,192.168.97.222   0x00000010

# 当 TCP 连接完成后，在数据传输过程中获取的包，其标志位为 0x18 [PSH, ACK] 或 0x10 [ACK]

3、四次挥手
"Jun 20, 2023 11:09:11.865531067 CST"   172.18.100.194,192.168.97.222   0x00000018
"Jun 20, 2023 11:09:11.865662294 CST"   172.18.100.194,192.168.97.222   0x00000011
"Jun 20, 2023 11:09:11.865690810 CST"   192.168.97.222,172.18.100.194   0x00000011
"Jun 20, 2023 11:09:11.865760205 CST"   192.168.97.222,172.18.100.194   0x00000010
"Jun 20, 2023 11:09:12.097150856 CST"   172.18.100.194,192.168.97.222   0x00000010
# 看最后 4 个包，0x11 [FIN,ACK]、0x10 [ACK]、0x11 [FIN,ACK]、0x10 [ACK]，这是标准的四次挥手过程
```

###### tshark 抓取 MySQL 中执行的 SQL：

```sql
-- 服务器进行抓包（以下实例主从关系断开）
[root@uat-fanqiz-mycat ~]# tshark -i ens160 -f 'tcp port 3306' -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.src -e ip.dst -e mysql.query
Running as user "root" and group "root". This could be dangerous.
Capturing on 'ens160'
"Jun 20, 2023 11:30:01.226412955 CST"   172.18.100.169  172.18.100.176  select user()
"Jun 20, 2023 11:30:01.226511393 CST"   172.18.100.169  172.18.100.173  select user()
"Jun 20, 2023 11:30:02.125123861 CST"   172.18.100.74   172.18.100.169  SELECT @@version
"Jun 20, 2023 11:30:02.125574321 CST"   172.18.100.74   172.18.100.169
        SELECT
            column_name
          FROM information_schema.columns
          WHERE table_schema = 'information_schema'
            AND table_name = 'INNODB_METRICS'
            AND column_name IN ('status', 'enabled')
          LIMIT 1

"Jun 20, 2023 11:30:02.126862408 CST"   172.18.100.74   172.18.100.169
                SELECT
                  name, subsystem, type, comment,
                  count
                  FROM information_schema.innodb_metrics
                  WHERE `status` = 'enabled'
"Jun 20, 2023 11:30:02.126903751 CST"   172.18.100.74   172.18.100.169  SHOW GLOBAL STATUS
"Jun 20, 2023 11:30:02.127421049 CST"   172.18.100.74   172.18.100.169  /*!50700 SELECT CHANNEL_NAME as channel_name, MEMBER_ID as member_id, MEMBER_HOST as member_host, MEMBER_PORT as member_port, MEMBER_STATE as member_state, CASE WHEN MEMBER_STATE = 'ONLINE' THEN 1 WHEN MEMBER_STATE = 'RECOVERING' THEN 2 WHEN MEMBER_STATE = 'OFFLINE' THEN 3 WHEN MEMBER_STATE = 'ERROR' THEN 4 WHEN MEMBER_STATE = 'UNREACHABLE' THEN 5 END as member_info FROM performance_schema.replication_group_members WHERE MEMBER_ID=@@server_uuid and (SELECT SUBSTRING(@@VERSION,1,1) = 5) */
"Jun 20, 2023 11:30:02.133776595 CST"   172.18.100.74   172.18.100.169  /*!80000 SELECT COUNT_TRANSACTIONS_IN_QUEUE as transactions_in_queue, COUNT_TRANSACTIONS_CHECKED as transactions_checked_total, COUNT_CONFLICTS_DETECTED as conflicts_detected_total, COUNT_TRANSACTIONS_ROWS_VALIDATING as transactions_rows_validating_total, COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE as transactions_remote_in_applier_queue, COUNT_TRANSACTIONS_REMOTE_APPLIED as transactions_remote_applied_total, COUNT_TRANSACTIONS_LOCAL_PROPOSED as transactions_local_proposed_total, COUNT_TRANSACTIONS_LOCAL_ROLLBACK as transactions_local_rollback_total FROM performance_schema.replication_group_member_stats WHERE MEMBER_ID=@@server_uuid */
"Jun 20, 2023 11:30:02.134501408 CST"   172.18.100.74   172.18.100.169  /*!50700 SELECT COUNT_TRANSACTIONS_IN_QUEUE as transactions_in_queue, COUNT_TRANSACTIONS_CHECKED as transactions_checked_total, COUNT_CONFLICTS_DETECTED as conflicts_detected_total, COUNT_TRANSACTIONS_ROWS_VALIDATING as transactions_rows_validating_total FROM performance_schema.replication_group_member_stats WHERE MEMBER_ID=@@server_uuid and (SELECT SUBSTRING(@@VERSION,1,1) = 5) */
"Jun 20, 2023 11:30:02.135094194 CST"   172.18.100.74   172.18.100.169  /*!80000 SELECT conn_status.channel_name as channel_name, conn_status.service_state as IO_thread, applier_status.service_state as SQL_thread, LAST_APPLIED_TRANSACTION_END_APPLY_TIMESTAMP - LAST_APPLIED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP 'rep_delay_seconds', LAST_QUEUED_TRANSACTION_START_QUEUE_TIMESTAMP - LAST_QUEUED_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP 'transport_time_seconds', LAST_QUEUED_TRANSACTION_END_QUEUE_TIMESTAMP - LAST_QUEUED_TRANSACTION_START_QUEUE_TIMESTAMP 'time_RL_seconds', LAST_APPLIED_TRANSACTION_END_APPLY_TIMESTAMP - LAST_APPLIED_TRANSACTION_START_APPLY_TIMESTAMP 'apply_time_seconds', if(GTID_SUBTRACT(LAST_QUEUED_TRANSACTION, LAST_APPLIED_TRANSACTION) = '','0' , abs(time_to_sec(if(time_to_sec(APPLYING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP)=0,0,timediff(APPLYING_TRANSACTION_ORIGINAL_COMMIT_TIMESTAMP,now()))))) `lag_in_seconds` FROM performance_schema.replication_connection_status AS conn_status JOIN performance_schema.replication_applier_status_by_worker AS applier_status ON applier_status.channel_name = conn_status.channel_name WHERE conn_status.service_state = 'ON' ORDER BY lag_in_seconds, lag_in_seconds desc */
"Jun 20, 2023 11:30:02.135301825 CST"   172.18.100.74   172.18.100.169  /*!50700 SELECT conn_status.channel_name as channel_name, conn_status.service_state as IO_thread, applier_status.service_state as SQL_thread, 1 as info FROM performance_schema.replication_connection_status AS conn_status JOIN performance_schema.replication_applier_status_by_worker AS applier_status ON applier_status.channel_name = conn_status.channel_name WHERE conn_status.service_state = 'ON' and (SELECT SUBSTRING(@@VERSION,1,1) = 5) */
"Jun 20, 2023 11:30:02.136065720 CST"   172.18.100.74   172.18.100.169  /*!80000 SELECT CHANNEL_NAME as channel_name, MEMBER_ID as member_id, MEMBER_HOST as member_host, MEMBER_PORT as member_port, MEMBER_STATE as member_state, MEMBER_ROLE as member_role, MEMBER_VERSION as member_version, CASE WHEN MEMBER_STATE = 'ONLINE' THEN 1 WHEN MEMBER_STATE = 'RECOVERING' THEN 2 WHEN MEMBER_STATE = 'OFFLINE' THEN 3 WHEN MEMBER_STATE = 'ERROR' THEN 4 WHEN MEMBER_STATE = 'UNREACHABLE' THEN 5 END as member_info FROM performance_schema.replication_group_members WHERE MEMBER_ID=@@server_uuid */

# 通过指定 MySQL 协议解析模块，此处捕获到了 MySQL 从实例在启动复制时会执行的 SQL 语句
# 如已用 -d 选项指定了协议、端口等信息时，可省略 -f（抓包过滤器表达式），除非还有其他的过滤需求，但不建议省略 -Y（显示过滤器表达式），否则会输出非常多的信息，以下两种写法是等效的：
tshark -i ens160 -f 'tcp port 3306' -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.host -e mysql.query
tshark -i ens160 -Y "mysql.query" -d tcp.port==3306,mysql -T fields -e frame.time -e ip.host -e mysql.query

-- 获取类型为 Query 的 SQL （未加mysql.command=3,表示执行的 SQL 类型为 Query，共支持 30 多种预设值）（`-c 10` ：_捕获数据包数量10）
[root@postgre bin]# tshark -i ens33 -d tcp.port==3306,mysql -Y "mysql.command==3" -T fields -e ip.host -e mysql.query -e frame.time
Running as user "root" and group "root". This could be dangerous.
Capturing on 'ens33'
192.168.97.91,192.168.97.222    SELECT * FROM csdev.appcctyp    "Jun 20, 2023 11:34:05.568395708 CST"
192.168.97.91,192.168.97.222    SELECT database()       "Jun 20, 2023 11:34:05.730712249 CST"
..
192.168.97.91,192.168.97.222    start TRANSACTION       "Jun 20, 2023 11:34:43.257636884 CST"
192.168.97.91,192.168.97.222    SELECT database()       "Jun 20, 2023 11:34:43.260612059 CST"
192.168.97.91,192.168.97.222    INSERT INTO csdev.appcctyp ( recid , versionid , ccco , cctype , cccrcd , ccname , ccusag , ccflag , ac , dfgs , dfg , ccusr1 , ccusr2 ) VALUES ( 4120 , 0 , '001' , 'AGH' , 'RMB' , 'ũҵ▒▒▒▒' , 'Y' , '' , NULL , NULL , NULL , 'APC' , 'ũҵ▒▒▒▒' )       "Jun 20, 2023 11:34:49.025684490 CST"
192.168.97.91,192.168.97.222    SELECT database()       "Jun 20, 2023 11:34:49.048651768 CST"
192.168.97.91,192.168.97.222    ROLLBACK        "Jun 20, 2023 11:35:00.058124957 CST"
192.168.97.91,192.168.97.222    SELECT database()       "Jun 20, 2023 11:35:00.059256795 CST"

--  获取与 show 相关的 SQL
 [root@postgre pg_log]# tshark -i ens33 -d tcp.port==3306,mysql -Y 'mysql.query contains "SHOW"' -T fields -e ip.host -e mysql.query -e frame.time
Running as user "root" and group "root". This could be dangerous.
Capturing on 'ens33'
192.168.97.91,192.168.97.222    SHOW FULL PROCESSLIST	"Jun 20, 2023 11:51:52.306033522 CST"
192.168.97.91,192.168.97.222    SHOW STATUS			    "Jun 20, 2023 11:51:53.626191045 CST"
192.168.97.91,192.168.97.222    SHOW GLOBAL VARIABLES   "Jun 20, 2023 12:53:33.339465855 CST"
192.168.97.91,192.168.97.222    SHOW SESSION VARIABLES  "Jun 20, 2023 12:53:37.440425840 CST"

# contains 使用字符串进行匹配，只要在数据包中存在指定的字符串，就会匹配成功，不论该字符串出现在查询的任何位置
# matches 支持使用正则表达式进行匹配，匹配符合指定规则的数据包，如：^show
# 用 contains/maches 进行匹配查找时，关键词需用双引号包围，此时外层建议使用单引号，因为 maches 进行正则匹配时，外层使用双引号会报错，contains 则不限制
# 以上匹配方式类似模糊查询，但会区分大小写，如果指定 Show 或 SHOW 为关键词，可能获取不到 SQL
```

##### tshark 抓包后用 Wireshark 解析:

![image-20230620130157692](C:\Users\itwb_lixl\AppData\Roaming\Typora\typora-user-images\image-20230620130157692.png)

tshark 作为 Wireshark 的命令行工具，与我们比较熟悉的 tcpdump 相比，有其不少优点：

1. 更多的过滤条件

具有比 tcpdump 更多的过滤条件，可以更加精确地过滤所需的数据包，tshark 支持 Wireshark 过滤器语法的全部特性，并提供了更高级的功能。

2. 更加灵活的输出格式

可以以不同的文件格式和标准输出打印输出捕获数据，而 tcpdump 的输出格式非常有限。

3. 更好的可读性和易用性

输出会更加易于阅读，因为它会对分组进行解析并显示其中包含的各种数据，比如协议、参数和错误信息等。这些信息对数据包分析非常有帮助。

4. 更加轻量级

相比于 tcpdump，占用的系统资源较少，并且不需要将所有数据存储在内存中，从而能够处理更大的数据流。

5. 更多的网络协议

支持更多的网络协议，包括 IPv6、IS-IS、IPX 等，而 tcpdump 支持的协议种类相对较少。

综上，在一些较为复杂的数据包分析和网络问题诊断场景中，**更推荐使用 tshark**，而对于只需快速捕捉网络流量的简单应用场景，tcpdump 可能会更适合一些。