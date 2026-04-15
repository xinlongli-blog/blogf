TEST:1

用管理员创建三个角色：db_owner, db_datareader, db_datawriter

```sql
root@mysqldb 16:14: [(none)]> create role db_owner,db_datareader,db_datawriter;
Query OK, 0 rows affected (0.04 sec)

root@mysqldb 16:17: [(none)]> grant all on ytt_new.* to db_owner;
Query OK, 0 rows affected (0.04 sec)

root@mysqldb 16:17: [(none)]> grant select on ytt_new.* to db_datareader;
Query OK, 0 rows affected (0.02 sec)

root@mysqldb 16:17: [(none)]> grant insert,delete,update on ytt_new.* to db_datawriter;
Query OK, 0 rows affected (0.00 sec)
```

创建三个普通用户，分别是ytt1、ytt2、ytt3

```sql
root@mysqldb 16:18: [(none)]> create user ytt1 identified by 'ytt',ytt2 identified by 'ytt',ytt3 identified
-> by 'ytt';
Query OK, 0 rows affected (0.02 sec)
```

授予三个用户对应的角色；

--授权角色

```sql
root@mysqldb 16:18: [(none)]> grant db_owner to ytt1;
Query OK, 0 rows affected (0.02 sec)
```

--激活角色

```sql
root@mysqldb 16:18: [(none)]> set default role db_owner to ytt1;
Query OK, 0 rows affected (0.03 sec)

root@mysqldb 16:18: [(none)]> grant db_datareader to ytt2;
Query OK, 0 rows affected (0.01 sec)

root@mysqldb 16:18: [(none)]> set default role db_datareader to ytt2;
Query OK, 0 rows affected (0.02 sec)

root@mysqldb 16:18: [(none)]> grant db_datawriter to ytt3;
Query OK, 0 rows affected (0.04 sec)

root@mysqldb 16:18: [(none)]> set default role db_datawriter to ytt3;
Query OK, 0 rows affected (0.04 sec)
```

以上是角色授予的一套完整步骤。那上面有点非常规的地方是激活角色这个步骤。MySQL 角色在创建之初默认是没有激活的，也就是说创建角色，并且给一个用户特定的角色，这个用户其实并不能直接使用这个角色，除非激活了才可以。



TEST:2(一个用户可以拥有多个角色)

--创建用户

```sql
root@mysqldb 16:18: [(none)]> create user ytt4 identified by 'ytt';
Query OK, 0 rows affected (0.01 sec)
```

--角色分配给用户ytt4

```sql
root@mysqldb 16:24: [(none)]> grant db_owner,db_datareader,db_datawriter to ytt4;
Query OK, 0 rows affected (0.00 sec)
```

--激活ytt4所属角色

```sql
root@mysqldb 16:24: [(none)]> set default role all to ytt4;
Query OK, 0 rows affected (0.00 sec)

root@mysqldb 16:24: [(none)]>
```

--ytt4登录

```sql
[root@informatica mysql]# /data/mysql_3306/bin/mysql -uytt4 -pytt -P3306
..
```

--查看当前角色列表

```sql
ytt4@mysqldb 16:25: [(none)]> select current_role();
+--------------------------------------------------------+
| current_role() |
+--------------------------------------------------------+
| `db_datareader`@`%`,`db_datawriter`@`%`,`db_owner`@`%` |
+--------------------------------------------------------+
1 row in set (0.00 sec)
```

--简单创建表插入检索最后删除

```sql
ytt4@mysqldb 16:26: [(none)]> use ytt_new
Database changed
ytt4@mysqldb 16:27: [ytt_new]> create table t11(id int);
Query OK, 0 rows affected (0.15 sec)

ytt4@mysqldb 16:27: [ytt_new]> insert into t11 values (1);
Query OK, 1 row affected (0.02 sec)

ytt4@mysqldb 16:27: [ytt_new]> select * from t11;
+------+
| id |
+------+
| 1 |
+------+
1 row in set (0.00 sec)

ytt4@mysqldb 16:27: [ytt_new]> drop table t11;
Query OK, 0 rows affected (0.02 sec)

ytt4@mysqldb 16:27: [ytt_new]>
```



TEST:3（用户在当前session里角色互换（可以切换当前角色列表、比如db_owner切换到db_datareader））

--用户ytt4切换到db_datareader

```sql
ytt4@mysqldb 16:27: [ytt_new]> set role db_datareader;
Query OK, 0 rows affected (0.00 sec)

ytt4@mysqldb 16:33: [ytt_new]> select current_role();
+---------------------+
| current_role() |
+---------------------+
| `db_datareader`@`%` |
+---------------------+
1 row in set (0.00 sec)
```

--切换后，没有权限创建表

```sql
ytt4@mysqldb 16:33: [ytt_new]> create table t11(id int);
ERROR 1142 (42000): CREATE command denied to user 'ytt4'@'localhost' for table 't11'
```

--切换到db_owner,恢复权限

```sql
ytt4@mysqldb 16:33: [ytt_new]> set role db_owner;
Query OK, 0 rows affected (0.00 sec)

ytt4@mysqldb 16:33: [ytt_new]> create table t11(id int);
Query OK, 0 rows affected (0.05 sec)
```



TEST:4

关于角色的参数

- activate_all_roles_on_login：是否在连接 MySQL 服务时自动激活角色
- mandatory_roles：强制所有用户默认角色

-- 用管理员连接 MySQL,
-- 设置默认激活角色

```sql
root@mysqldb 16:24: [(none)]> set global activate_all_roles_on_login=on;
ERROR 4031 (HY000): The client was disconnected by the server because of inactivity. See wait_timeout and interactive_timeout for configuring this behavior.
No connection. Trying to reconnect...
Connection id: 13
Current database: *** NONE ***

Query OK, 0 rows affected (0.00 sec)
```

--设置强制给所有用户赋予角色 db_datareader

```sql
root@mysqldb 16:38: [(none)]> set global mandatory_roles='db_datareader';
Query OK, 0 rows affected (0.00 sec)
```

-- 创建用户 ytt7

```sql
root@mysqldb 16:38: [(none)]> create user ytt7;
Query OK, 0 rows affected (0.02 sec)
```

-- 用 ytt7 登录数据库

```sql
[root@informatica ~]# /data/mysql_3306/bin/mysql -uytt7 -P3306
..

ytt7@mysqldb 16:39: [(none)]> show grants;
+-------------------------------------------+
| Grants for ytt7@% |
+-------------------------------------------+
| GRANT USAGE ON *.* TO `ytt7`@`%` |
| GRANT SELECT ON `ytt_new`.* TO `ytt7`@`%` |
| GRANT `db_datareader`@`%` TO `ytt7`@`%` |
+-------------------------------------------+
3 rows in set (0.00 sec)
```

疑问：create role 和 create user 都有创建角色权限，两者有啥区别？

--创建两个用户 ytt8、ytt9，一个给 create role，一个给 create user 权限

```sql
root@mysqldb 16:38: [(none)]> create user ytt8,ytt9;
Query OK, 0 rows affected (0.02 sec)

root@mysqldb 16:39: [(none)]> grant create role on *.* to ytt8;
Query OK, 0 rows affected (0.04 sec)

root@mysqldb 16:39: [(none)]> grant create user on *.* to ytt9;
Query OK, 0 rows affected (0.00 sec)
```

-- 用 ytt8 登录

```sql
[root@informatica ~]# /data/mysql_3306/bin/mysql -uytt8 -P3306
..

ytt8@mysqldb 16:42: [(none)]> create role db_test;
Query OK, 0 rows affected (0.02 sec)
```

--可以创建角色，但不能创建用户

```sql
ytt8@mysqldb 16:42: [(none)]> create user ytt10;
ERROR 1227 (42000): Access denied; you need (at least one of) the CREATE USER privilege(s) for this operation
ytt8@mysqldb 16:42: [(none)]>
```

-- 用 ytt9 登录

```sql
[root@informatica ~]# /data/mysql_3306/bin/mysql -uytt9
..
```

--角色和用户都能创建

```sql
ytt9@mysqldb 16:43: [(none)]> create role db_test2;
Query OK, 0 rows affected (0.05 sec)

ytt9@mysqldb 16:43: [(none)]> create user ytt10;
Query OK, 0 rows affected (0.02 sec)
```

结论：create user 包含了 create role，create user 即可以创建用户，也可以创建角色



TEST:5（MySQL 用户也可以当角色来用;）

--创建用户 ytt11,ytt12

```sql
root@mysqldb 16:39: [(none)]> create user ytt11,ytt12;
Query OK, 0 rows affected (0.01 sec)

root@mysqldb 16:46: [(none)]> grant select on ytt_new.* to ytt11;
Query OK, 0 rows affected (0.03 sec)
```

-- 把 ytt11 普通用户的权限授予给 ytt12

```sql
root@mysqldb 16:46: [(none)]> grant ytt11 to ytt12;
Query OK, 0 rows affected (0.20 sec)
```

-- 来查看 ytt12 的权限，可以看到拥有了 ytt11 的权限

```sql
root@mysqldb 16:46: [(none)]> show grants for ytt12;
+-----------------------------------+
| Grants for ytt12@% |
+-----------------------------------+
| GRANT USAGE ON *.* TO `ytt12`@`%` |
| GRANT `ytt11`@`%` TO `ytt12`@`%` |
+-----------------------------------+
2 rows in set (0.00 sec)
```

-- 在细化点，看看 ytt12 拥有哪些具体的权限

```sql
root@mysqldb 16:46: [(none)]> show grants for ytt12 using ytt11;
+--------------------------------------------+
| Grants for ytt12@% |
+--------------------------------------------+
| GRANT USAGE ON *.* TO `ytt12`@`%` |
| GRANT SELECT ON `ytt_new`.* TO `ytt12`@`%` |
| GRANT `ytt11`@`%` TO `ytt12`@`%` |
+--------------------------------------------+
3 rows in set (0.00 sec)
```

TEST:6角色的撤销

角色撤销和之前权限撤销类似。要么 revoke，要么删除角色，那这个角色会从所有拥有它的用户上移除。

-- 用管理员登录，移除 ytt2 的角色

```sql
root@mysqldb 16:46: [(none)]> revoke db_datareader from ytt2;
ERROR 3628 (HY000): The role `db_datareader`@`%` is a mandatory role and can't be revoked or dropped. The restriction can be lifted by excluding the role identifier from the global variable mandatory_roles.
root@mysqldb 16:47: [(none)]> set global activate_all_roles_on_login=OFF;
Query OK, 0 rows affected (0.00 sec)

root@mysqldb 16:48: [(none)]> revoke db_datareader from ytt2;
ERROR 3628 (HY000): The role `db_datareader`@`%` is a mandatory role and can't be revoked or dropped. The restriction can be lifted by excluding the role identifier from the global variable mandatory_roles.
root@mysqldb 16:48: [(none)]> set global mandatory_roles='';
Query OK, 0 rows affected (0.00 sec)

root@mysqldb 16:48: [(none)]> revoke db_datareader from ytt2;
Query OK, 0 rows affected (0.01 sec)
```

-- 删除所有角色

```sql
root@mysqldb 16:49: [(none)]> drop role db_owner,db_datareader,db_datawriter;
Query OK, 0 rows affected (0.03 sec)
```

-- 对应的角色也从 ytt1 上移除掉了

```sql
root@mysqldb 16:49: [(none)]> show grants for ytt1;
+----------------------------------+
| Grants for ytt1@% |
+----------------------------------+
| GRANT USAGE ON *.* TO `ytt1`@`%` |
+----------------------------------+
1 row in set (0.00 sec)
```

over-