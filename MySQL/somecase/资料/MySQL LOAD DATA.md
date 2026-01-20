LOAD DATA

官方叙述，一种速度很快的导入导出方式。

> The [`LOAD DATA`](https://dev.mysql.com/doc/refman/8.0/en/load-data.html) statement reads rows from a text file into a table at a very high speed.

```sql
CREATE TABLE `datetest` (
  `datetime_column` datetime DEFAULT NULL,
  `timestamp_column` timestamp NULL DEFAULT NULL,
  `date_column` date DEFAULT NULL,
  `time_column` time DEFAULT NULL,
  `year_column` year DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```



LOAD 导出TXT：

```sql
-- SELECT count(*) FROM orders;					
count(*)					
358138					
-- DESC orders;					
Field	Type	Null	Key	Default	Extra
o_id	int	NO	PRI		
o_w_id	int	NO	PRI		
o_d_id	int	NO	PRI		
o_c_id	int	YES			
o_carrier_id	int	YES			
o_ol_cnt	int	YES			
o_all_local	int	YES			
o_entry_d	datetime	YES							
```

```sql
msql[testg]> SELECT * INTO OUTFILE '/data/mysql_8034/file/order1.txt'
    -> CHARACTER SET utf8mb4
    -> FIELDS TERMINATED BY ','
    -> ENCLOSED BY '\"'
    -> LINES TERMINATED BY '\n'
    -> FROM testg.orders;
Query OK, 358138 rows affected (0.42 sec)

-- 查看TXT
"1","1","1","2978","7","7","1","2023-12-08 13:00:34"
"2","1","1","1062","5","8","1","2023-12-08 13:00:34"
"3","1","1","1182","8","5","1","2023-12-08 13:00:34"
"4","1","1","1526","5","14","1","2023-12-08 13:00:34"
...
```

导入数据示例：

```sql
msql[testg]> LOAD DATA INFILE '/data/mysql_8034/file/order1.txt'
    ->      REPLACE INTO TABLE testg.orders1
    ->      CHARACTER SET utf8mb4
    ->      FIELDS TERMINATED BY ','
    ->      ENCLOSED BY '"'
    ->      LINES TERMINATED BY '\n'
    ->      (@C1, @C2, @C3, @C4, @C5, @C6, @C7, @C8) -- 对应txt中的8列数据
    ->      SET o_id=@C1,o_w_id=@C2,o_d_id=@C3,o_c_id=@C4,o_entry_d=@C8; -- 指定txt列与字段对应关系，
Query OK, 358138 rows affected (6.30 sec)
Records: 358138  Deleted: 0  Skipped: 0  Warnings: 0
```

![image-20240229141732625](C:\Users\itwb_lixl\AppData\Roaming\Typora\typora-user-images\image-20240229141732625.png)