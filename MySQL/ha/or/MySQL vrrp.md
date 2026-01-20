2021/11/23

- 简介：实现MySQL一主一备 保障7*24可用；（简单易用 不涉及负载但可延伸）
- 方案：MySQL主备+keepalived(VIP)实现高可用故障转移；
- 事项：Mailx故障转移邮件告知，Zabbix 监控Keepalived.service服务(重要)。 更改为监控MySQL端口；
- 流程：master 绑定VIP，master MySQL crash。master VIP 切换 slave; 实现高可用；
- 原理：master vrrp路由发包给 backup(slave)，backup收不到包master crash. 备用作为master. Keepalived检测将有故障的机器踢掉,使用其他服务器。切换级别秒级(无事务)；
- 复制：MTS+GTID(Slave对Master进行备份还原开启主从模式)；
- 版本：

|   MySQL    |    5.7.27     |
| :--------: | :-----------: |
|   MASTER   | 192.168.99.53 |
|   SLAVE    | 192.168.99.54 |
|    VIP     | 192.168.99.55 |
| Keepalived |     2.1.5     |



keepalived部署：

```sql
依赖：yum install curl gcc openssl-devel libnl3-devel net-snmp-devel libnfnetlink-devel –y initscripts -y && wget http://www.keepalived.org/software/keepalived-2.1.5.tar.gz --no-check-certificate
解压：tar xf keepalived-2.1.5.tar.gz && cd keepalived-2.1.5
编译：./configure --prefix=/usr/local/keepalived && make && make install
```

创建启动文件：

```sql
mkdir /etc/keepalived/
cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/
```

源码目录进行复制：

```sql
cp keepalived-2.1.5/keepalived/etc/sysconfig /etc/sysconfig/
cp keepalived-2.1.5/keepalived/keepalived.service /etc/systemd/system/
cp keepalived-2.1.5/keepalived/etc/init.d/keepalived /etc/init.d/
cp -r keepalived/etc/keepalived/ /usr/sbin/
systemctl daemon-reload
```



**核心配置文件（master）/etc/keepalived/keepalived.conf**

```sql
! Configuration File for keepalived

global_defs {
    router_id GDS-PRO-qianyue-db1														//服务器标识
}

vrrp_script mysqlcheck {
    script "/usr/bin/sh /data/keepalived/check/mysql_check.sh"							//检测mysql脚本
    interval 5
}

vrrp_instance QIANYUE_VIP {
    state BACKUP																		//keepalived属性
    interface ens160																	//HA监测网络接口
    virtual_router_id 55																//虚拟路由标识(0-255,用来区分多个instance的VRRP组播)同一个vrrp实例使用唯一的标识.
    priority 100																		//用来选举master的 优先级
    advert_int 1																		//发VRRP包的时间间隔(健康查检时间间隔)
    nopreempt																			//不抢占，即允许一个priority比较低的节点作为master，即使有priority更高的节点启动
    authentication {
        auth_type PASS																	//认证区域，认证类型有PASS和HA（IPSEC），推荐使用PASS（密码只识别前8位）
        auth_pass 1111
    }
    virtual_ipaddress {																	//vip地址
        192.168.99.55
    }
    track_script {																		//调用脚本
        mysqlcheck
    }
    notify_master "/usr/bin/sh /data/keepalived/master_status_switch.sh master"			//master_status_switch.sh 记录crash mysql状态；slave区别在于 在crash时、会stop repl、抓Master_Log_File
    notify_backup "/usr/bin/sh /data/keepalived/master_status_switch.sh backup"			\Read_Master_Log_Pos、Relay_Master_Log_File、Exec_Master_Log_Pos参数值、就是对应的sql io thread的值且记录日志；
    notify_fault "/usr/bin/sh /data/keepalived/master_status_switch.sh fault"			\两个目的 极端情况下要用参数去补数据、生产都双一；大概率不可能、其二是最终目的还原高可用时补数据。
    notify_stop "/usr/bin/sh /data/keepalived/master_status_switch.sh stop"
}
```

slave端keeapalived配置近乎一样、详细配置会上传附件[KeepaLived.zip](http://confluence.square.life:8090/download/attachments/29231045/KeepaLived.zip?version=1&modificationDate=1685079429875&api=v2)；

部署完成启动服务 查看虚拟IP 是否存在

```sql
[root@GDS-PRO-qianyue-db1 ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:b5:ac brd ff:ff:ff:ff:ff:ff
    inet 192.168.99.53/24 brd 192.168.99.255 scope global noprefixroute ens160
       valid_lft forever preferred_lft forever
    inet 192.168.99.55/32 scope global ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::d0da:d5f5:f14c:e9eb/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```



- 日志相关：默认路径 /var/log/messages

- 指定文件：

- [x]   修改配置文件/etc/sysconfig/keepalived
- [x]   KEEPALIVED_OPTIONS="-D -d -S 0"
- [ ]   -D导出备份配置数据
- [ ]   -d详细日志
- [ ]   -S设置本地syslog设备，编号为0-7 这里为0
- [ ]   修改/etc/rsyslog.conf在尾部添加
- [ ]   local0 /var/log/keepalived.log
- [ ]   修改54行左右
- [ ]   *.info;mail.none;authpriv.none;cron.none;local0.none /var/log/messages
- [ ]   重启 rsyslog.service 服务
- [ ]   重启 keepalived.service 服务



防火墙相关：

```sql
firewall-cmd --direct --permanent --add-rule ipv4 filter INPUT 0 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
firewall-cmd --direct --permanent --add-rule ipv4 filter OUTPUT 0 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
firewall-cmd --reload
```

