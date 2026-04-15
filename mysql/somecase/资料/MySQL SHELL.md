SHELL

利用SHELL 找MySQL 某个表中主键不连续的值(auto_increment) 测试该表1-100、模拟删除随机数字。

```sql
[root@postgre opt]# mysql -ulixl -p -D percona -e "select id from tmp" -ss > tmp.txt
Enter password:
[root@postgre opt]# less tmp.txt
[root@postgre opt]# for i in `seq 1 100`;do echo $i >> ids.txt;done;
[root@postgre opt]# grep -vwf tmp.txt ids.txt |sed ':label;N;s/\n/,/;b label'
9,10,11,12,22,23,24,25,42,43,44,45,46,47,48,49,50,51,52,80,81,82,83,84,94,95,96,97

#-ss 经测试去掉id字段首行、具体意义暂不知，
#grep -vwf tmp.txt ids.txt |sed ':label;N;s/\n/,/;b label'解释：
#这是一个结合使用 grep 和 sed 命令的管道命令。让我逐步解释每个部分的作用：
1.grep -vwf tmp.txt ids.txt：

grep 命令用于在文件中搜索匹配指定模式的行。
-v 选项表示反转匹配，即只显示不匹配的行。
-w 选项表示匹配整个单词，而不是部分匹配。
-f tmp.txt 选项指定要从 tmp.txt 文件中读取模式（即要排除的内容）。
ids.txt 是要搜索的文件。
因此，这个命令的作用是从 ids.txt 文件中排除掉在 tmp.txt 文件中出现的行（即，将匹配 tmp.txt 中的内容的行排除掉）。

2.sed ':label;N;s/\n/,/;b label'：

sed 是一个用于处理和转换文本的流编辑器。
:label 是一个标签，用于在 sed 命令中标识一个位置。
N 命令用于将下一行添加到模式空间中（在这里用于将下一行添加到当前行后面）。
s/\n/,/ 命令用于将模式空间中的换行符 \n 替换为逗号 ,。
b label 命令用于无条件地转移到 label 标签所在的位置。
这个命令的作用是将每个匹配到的行与其后面的行合并，并将它们之间的换行符替换为逗号。这样，最终输出的结果将是一行中逗号分隔的内容。

综合起来，这个管道命令的目的是从 ids.txt 文件中排除包含在 tmp.txt 文件中的行，并将剩余的行合并为一行，并使用逗号分隔内容。
```

相关binlog：

```sql
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000031 |grep "GTID$(printf '\t')last_committed" -B 1|head -n 10
# at 194
#230629  9:14:18 server id 2130706431  end_log_pos 259 CRC32 0x2bde37c8         GTID    last_committed=0        sequence_number=1       rbr_only=no
--
# at 392
#230629  9:14:18 server id 2130706431  end_log_pos 457 CRC32 0x56a98d76         GTID    last_committed=1        sequence_number=2       rbr_only=no
--
# at 737
#230629  9:15:53 server id 2130706431  end_log_pos 802 CRC32 0x410d98bb         GTID    last_committed=2        sequence_number=3       rbr_only=yes
--
# at 20897

#过滤信息将两行数据相减得出每个事物大小(`at 392` - `at 194` = 事务大小)
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000031 |grep "GTID$(printf '\t')last_committed" -B 1|grep -E '^# at'|awk '{print $3}' |awk 'NR==1 {tmp=$1} NR>1 {print ($1-tmp);tmp=$1}'|sort -n -r |head -n 10
20160
445
442
439
435
433
432
429
425
425

#解析binlog筛选关键
#忽略gtid --skip-gtids=true
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /data/mysql_3306/binlog/mysql-bin.000031 --database percona --base64-output=decode-rows -vv --skip-gtids=true | grep -C 1 -i "DELETE" |head -n 10
#230629  9:16:16 server id 2130706431  end_log_pos 21098 CRC32 0x7f1ce653       Rows_query
# DELETE FROM percona.tmp
# WHERE id = 9
--
# at 21156
#230629  9:16:16 server id 2130706431  end_log_pos 21291 CRC32 0xee29ac2b       Delete_rows: table id 372982 flags: STMT_END_F
### DELETE FROM `percona`.`tmp`
### WHERE
--
#230629  9:16:16 server id 2130706431  end_log_pos 21524 CRC32 0x65fa7725       Rows_query

#直观查看组提交信息
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /root/mysql-bin.000013 | grep -a 'last_commit' | awk '{print $11}' | sort | uniq -d |head -n 10
last_committed=120416
last_committed=128345
last_committed=139306
last_committed=179801
last_committed=215436
last_committed=230472
last_committed=230477
last_committed=230490
last_committed=230502
last_committed=230527
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /root/mysql-bin.000013 | grep -a 'last_committed=120416'
#220606 17:42:43 server id 1110053  end_log_pos 105265545 CRC32 0x9eae9aa9      GTID    last_committed=120416   sequence_number=120417  rbr_only=yes
#220606 17:42:43 server id 1110053  end_log_pos 105266322 CRC32 0x2ff09f2e      GTID    last_committed=120416   sequence_number=120418  rbr_only=yes

#查看事务数
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /root/mysql-bin.000013 | grep -a 'last_commit'| awk '{print $11}'|wc -l
530770
[root@postgre opt]# /data/mysql_basedir_3306/bin/mysqlbinlog /root/mysql-bin.000013 | grep -a 'last_commit'| awk '{print $11}'|uniq|wc -l
529221
```

