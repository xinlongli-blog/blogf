#### 云MySQL 数据恢复至自建MySQL

##### 实现工具：

- qpress

```sql
##其一
## 下载可执行文件的tar包
wget "https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/file-manage-files/zh-CN/20230406/flxd/qpress-11-linux-x64.tar"
## 解压下载的tar包，取出可执行文件
tar -xvf qpress-11-linux-x64.tar
## 设置qpress文件的执行权限
sudo chmod 775 qpress
## 拷贝qpress到/usr/bin中
sudo cp qpress /usr/bin

##其二(推荐)
## 添加Percona存储库：
# dnf install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
## 安装qpress rpm包：
# dnf install qpress
```

- Percona XtraBackup

```sql
wget https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.28/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.28-1.el7.x86_64.rpm
sudo yum localinstall -y percona-xtrabackup-24-2.4.28-1.el7.x86_64.rpm
##注意版本之间兼容即可、依赖自行处理、推荐官网二进制部署
```

##### 实现方式：

1. 在管理控制台中，对数据库进行全量物理备份。
2. 将物理备份文件下载到本地，qb后缀通过`qpress`工具进行解压、流复制后缀xtraback解压即可。
3. 使用`Percona XtraBackup`工具，将解压后的备份文件恢复到自建数据库的数据目录中。
4. 重启数据库后，进行数据校验。

##### 解压备份文件：

```sql
[root@postgre bakmysql]# /opt/percona-xtrabackup-2.4.21-Linux-x86_64.glibc2.12/bin/xbstream -x -v < ./e2d2b5ed-a0a6-4805-b9a7-4715785e9a54_backup_20220911031704.xbstream -C ./back/
ibdata1.qp
ApolloPortalDB/AppNamespace.ibd.qp
ApolloPortalDB/Permission.ibd.qp
..
```

###### **xbstream 文件包**

```shell
## 步骤一：解包
cat test_qp.xb | xbstream -x -v -C /var/mysql_bkdata/
## 步骤二：解压
### MySQL 5.5/5.6/5.7
/opt/percona-xtrabackup-2.4.21-Linux-x86_64.glibc2.12/bin/innobackupex --decompress --remove-original ./back/ ##本次校验命令
221008 10:06:13 [01] removing ./backup-my.cnf.qp
221008 10:06:13 [01] decompressing ./xtrabackup_info.qp
221008 10:06:13 [01] removing ./xtrabackup_info.qp
221008 10:06:13 completed OK!
..
### MySQL 8.0
xtrabackup --decompress --remove-original --target-dir=./back
```

##### 恢复数据：

1. ###### 恢复准备:

   ```shell
   #在恢复之前需要prepared该备份，因为流式备份不会做prepare。
   [root@postgre back]# /opt/percona-xtrabackup-2.4.21-Linux-x86_64.glibc2.12/bin/innobackupex --defaults-file=./backup-my.cnf --apply-log ../back/
   ```

   参数解释：

   | **参数**        | **含义**                                                     |
   | --------------- | ------------------------------------------------------------ |
   | --defaults-file | 通过传入配置文件设置MySQL默认选项。RDS MySQL备份文件中，提供名为`backup-my.cnf`的配置文件，该文件位于**备份解压目录**，即`../back`。 |
   | --apply-log     | XtraBackup工具的准备命令。该命令后配置存放备份文件的目录，即**备份解压目录**`../back`。 |

2. ###### 修改自建数据库配置文件`my.cnf`:

   a.编辑数据库配置文件。
   b.修改datadir参数为../back (绝对路径)

   c.在my.cnf 添加如下内容：

   ```shell
   innodb_undo_tablespaces=2
   innodb_undo_directory=../back
   ```

   **重要**

   参数**<font color='red'>innodb_undo_tablespaces</font>**的取值需要与`../backup-my.cnf`中的取值相同，您可以使用`cat ../backup-my.cnf | grep innodb_undo_tablespaces`查询。

3. ###### 恢复数据

   ```shell
   [root@postgre back]# /opt/percona-xtrabackup-2.4.21-Linux-x86_64.glibc2.12/bin/innobackupex --defaults-file=/data/mysql/etc/my.cnf --copy-back ../back/
   xtrabackup: recognized server arguments: --datadir=/data/bakmysql/nback --tmpdir=/data/mysql/tmp --log_bin=/data/mysql/binlog/mysql-bin --server-id=1 --open_files_limit=65535 --innodb_autoextend_incr-innodb_buffer_pool_size=1G --innodb_data_file_path=ibdata1:50M:autoextend --innodb_file_per_table=1 --innodb_force_recovery=0 --innodb_flush_log_at_trx_commit=1 --innodb_flush_method=O_DIRECT --innoffer_size=8M --innodb_log_file_size=512M --innodb_log_files_in_group=4 --innodb_open_files=10000 --innodb_read_io_threads=4 --innodb_write_io_threads=4 --innodb_io_capacity=1000 --innodb_undo_tablespinnodb_undo_directory=./
   xtrabackup: recognized client arguments:
   221008 10:14:41 innobackupex: Starting the copy-back operation
   
   IMPORTANT: Please check that the copy-back run completes successfully.
              At the end of a successful copy-back run innobackupex
              prints "completed OK!".
   
   /opt/percona-xtrabackup-2.4.21-Linux-x86_64.glibc2.12/bin/innobackupex version 2.4.21 based on MySQL server 5.7.32 Linux (x86_64) (revision id: 5988af5)
   221008 10:14:41 [01] Copying ib_logfile0 to /data/bakmysql/nback/ib_logfile0
   221008 10:14:45 [01]        ...done
   221008 10:14:47 [01] Copying ib_logfile1 to /data/bakmysql/nback/ib_logfile1
   ...
   221008 10:14:57 [01] Copying ./xtrabackup_master_key_id to /data/bakmysql/nback/xtrabackup_master_key_id
   221008 10:14:57 [01]        ...done
   221008 10:14:57 [01] Copying ./ibtmp1 to /data/bakmysql/nback/ibtmp1
   221008 10:14:57 [01]        ...done
   221008 10:14:57 completed OK!
   ```

   参数解释：

   | **参数**        | **含义**                                                     |
   | --------------- | ------------------------------------------------------------ |
   | --defaults-file | 自建数据库的`my.cnf`文件，根据此配置文件中设置的**数据目录**（datadir），获取恢复数据的目标路径。 |
   | --copy-back     | XtraBackup工具的恢复命令。该命令后配置存放备份文件的目录，即**备份解压目录**`../back`，XtraBackup工具将此目录数据恢复到自建数据库的**数据目录**中。 |

##### 启动实例：

mysqld_safe 启动时多观察errorlog 以便及时发现问题进行处理。

进行数据校验。

##### 相关问题：

error 1105 Unknown error  执行如下SQL语句转换数据库存储引擎 USE mysql;ALTER TABLE proc engine=myisam;ALTER TABLE event engine=myisam;ALTER TABLE func engine=myisam;

ERROR 1067 (42000): Invalid default value for 'modified'  执行`SET SQL_MODE='ALLOW_INVALID_DATES';`语句

InnodDB: Assertion failure in thread 140xxx in file page0zip.icne xxx  扩容

[ERROR] Failed to open the relay log xxx、[ERROR] Slave: Failed to initialize the master info xxx、[ERROR] Failed to create or recover replication info repositories  高可用，不影响数据库启动，无需关注

mycnf参数是重点、需多注意。

...
