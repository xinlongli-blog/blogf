限流dump数据：

辅助工具pv （yum install pv -y）

[root@postgre data]# /data/mysql_basedir_3306/bin/mysqldump \
> -h127.0.0.1 -ulixl -plixl -P3306 \
> --default-character-set=utf8mb4 --master-data=2 \
> --single-transaction --set-gtid-purged=off --hex-blob \
> --force --tables nglicps2 cps_approve_info >/tmp/dump.sql
> mysqldump: [Warning] Using a password on the command line interface can be insecure.
> [root@postgre data]# ll /tmp/dump.sql
> -rw-r--r--. 1 root root 262708541 5月  23 16:23 /tmp/dump.sql
> [root@postgre data]# du -sh /tmp/dump.sql
> 251M    /tmp/dump.sql
> [root@postgre data]# pv
> pv         pvchange   pvck       pvcreate   pvdisplay  pvmove     pvremove   pvresize   pvs        pvscan
> [root@postgre data]# pv -p -a -L1M /tmp/dump.sql | ./use nglicps
> -bash: ./use: 没有那个文件或目录
> [   0 B/s] [>                                                                                                     ]  0%
> [root@postgre data]# pv -p -a -L1M /tmp/dump.sql | mysql -ulixl -plixl  nglicps
> mysql: [Warning] Using a password on the command line interface can be insecure.
> [1023kiB/s] [===================================>                                                                 ] 36%

PV 工具既可以用于显示文件流的进度，也可以用于文件流的限速。 在本实验中，我们用 PV 来限制 SQL 文件发到 MySQL client 的速度，从而限制 SQL 的回放速 度，达到不影响其他业务的效果。



-p 显示进度

-a 显示平均速度

-L1M 限速1M/s