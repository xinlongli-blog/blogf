plugin_clone

简述：

​	克隆插件是新版本特性、MySQL 8.0.17 及更高版本支持克隆插件，捐赠者和接收者必须是相同的MySQL服务器系列，8.0.37 之后支持不同版本进行克隆、表空间在数据目录之外、具体参考官方文档。



克隆远程数据：

​	默认情况下，远程克隆操作会删除接收者上用户创建的数据（模式、表、表空间）和二进制日志，将新数据克隆到接收者数据目录，然后重新启动 MySQL 服务器。

1. 在捐赠者实例创建用户，需具有`BACKUP_ADMIN`

   ```sql
   CREATE USER clone_user@'172.18.100.59' IDENTIFIED by 'P@ssw0rd001';
   GRANT BACKUP_ADMIN ON *.* TO 'clone_user'@'172.18.100.59';
   ```

2. 安装克隆插件：

   ```sql
   INSTALL PLUGIN clone SONAME 'mysql_clone.so';
   or
   .../my.cnf
   [mysqld]
   plugin-load-add=mysql_clone.so
   ```

3. 在接收方实例创建用户，需具有`CLONE_ADMIN`

   > CLONE_ADMIN权限 = BACKUP_ADMIN权限 + SHUTDOWN权限。SHUTDOWN仅限允许用户shutdown和restart mysqld。授权不同是因为，接受者需要restart mysqld。

   ```sql
   CREATE USER clone_user@'172.18.100.74' IDENTIFIED by 'P@ssw0rd001';
   GRANT CLONE_ADMIN ON *.* TO 'clone_user'@'172.18.100.59';
   ```

4. 配置克隆插件、如上。

5. 将捐赠者实例地址添加至`clone_valid_donor_list`变量设置中：

   ```sql
   set global clone_valid_donor_list='172.18.100.59:3308'
   ```

6. 在接收方登录执行`clone_instance`语句：

   ```sql
   CLONE INSTANCE FROM clone_user@'172.18.100.59':3308 IDENTIFIED BY 'P@ssw0rd001';
   ```



克隆本地数据：

​	步骤如下：

- DROP DATA
- FILE COPY
- PAGE COPY
- REDO COPY
- FILE SYNC

​	过程相同，需指定DATA DIRECTORY 例：

```sql
mysql> CLONE INSTANCE FROM 'user'@'example.donor.host.com':3306
       IDENTIFIED BY 'password'
       DATA DIRECTORY = '/path/to/clone_dir';
```

​	可指定克隆后的目录启动实例 例：

```sql
/data/mysql_basedir/bin/mysqld --datadir=/data/mysql/fander/clone_dir --port=3333 --socket=/tmp/mysql3333.sock --user=mysql --lower-case-table-names=1 --mysqlx=OFF
```

