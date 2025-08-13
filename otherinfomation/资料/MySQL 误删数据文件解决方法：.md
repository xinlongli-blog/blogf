误删数据文件解决方法：

模拟rm ibd

```sh
[root@postgre nglicps2]# du -sh *|sort -rh|head -n 19
7.8G    cps_transactions.ibd
3.7G    cps_transactions_copy2.ibd
3.7G    cps_req_bat_deal_dtl_fld.ibd
3.2G    cps_req_bat_deal_dtl.ibd
3.2G    cps_flowpath.ibd
720M    cps_financial.ibd
344M    _cps_approve_info_del.ibd
316M    cps_approve_info.ibd
276M    fifi35_report.ibd
124M    sheet1.ibd
100M    cps_financial_copy6.ibd
60M     cps_financial_copy5.ibd
44M     fifi35_report_copy2.ibd
44M     cps_req_bat_deal.ibd
44M     cps_financial_copy4.ibd
44M     cps_financial_copy3.ibd
40M     cps_financial_copy2.ibd
40M     cps_bankid_copy.ibd
36M     cps_pi_refndintf.ibd
[root@postgre nglicps2]# rm -rf cps_transactions.ibd
[root@postgre nglicps2]#

```

查看mysql占用句柄：

```sh
ls -alh /proc/$(cat mysql.pid)/fd
文件句柄44
[root@postgre data]# ls -alh /proc/$(cat mysql.pid)/fd|grep delete
lrwx------. 1 root  root  64 5月  23 15:33 12 -> /data/mysql_3306/tmp/ibWDvt5U (deleted)
lrwx------. 1 root  root  64 5月  23 15:33 44 -> /data/mysql_3306/data/nglicps2/cps_transactions.ibd (deleted)
lrwx------. 1 root  root  64 5月  23 15:33 6 -> /data/mysql_3306/tmp/ibcGiski (deleted)
lrwx------. 1 root  root  64 5月  23 15:33 7 -> /data/mysql_3306/tmp/ibBMYYjH (deleted)
lrwx------. 1 root  root  64 5月  23 15:33 8 -> /data/mysql_3306/tmp/ibrTVApv (deleted)
```

然后锁流量 super_read_only参数ON之后 实例不可写；
校验对下数据和checksum 为了恢复后作对比

```sh
mysql> set global super_read_only=ON;
Query OK, 0 rows affected (0.01 sec)

mysql> select count(*) from nglicps2.cps_transactions;
+----------+
| count(*) |
+----------+
| 10024723 |
+----------+
1 row in set (19.79 sec)

mysql> checksum table nglicps2.cps_transactions;
+---------------------------+-----------+
| Table                     | Checksum  |
+---------------------------+-----------+
| nglicps2.cps_transactions | 139925644 |
+---------------------------+-----------+
1 row in set (2 min 25.33 sec)

mysql>
```

找出rm的ibd文件：

```sh
[root@postgre data]# cat /proc/$(cat mysql.pid)/fd/44 > /tmp/cps_transactions.ibd.recover
[root@postgre data]# mv /tmp/cps_transactions.ibd.recover /data/mysql_3306/data/nglicps2/cps_transactions.ibd
[root@postgre data]# chown -R mysql.mysql /data/mysql_3306/
[root@postgre data]# systemctl restart mysql
[root@postgre data]#
```

最后检验数据:

```sql
mysql> select count(*) from nglicps2.cps_transactions;
+----------+
| count(*) |
+----------+
| 10024723 |
+----------+
1 row in set (4 min 41.56 sec)

mysql> checksum table nglicps2.cps_transactions;
+---------------------------+-----------+
| Table                     | Checksum  |
+---------------------------+-----------+
| nglicps2.cps_transactions | 139925644 |
+---------------------------+-----------+
1 row in set (3 min 39.49 sec)

mysql>
```

实验原理 Linux 删除文件其实是减少了对文件的使用数，当使用数降为 0 时，才正式删除文件。 所以当我们执行 rm 时，由于 ibd 文件还在被 MySQL 使用，文件其实并没有被真实删除，只是没办法 通过文件系统访问。 通过 procfs 查找文件句柄，可以让我们追踪到消失的文件。