Orchestrator -raft MySQL（percona）

基础配置percona blog写了大概 链接：https://www.percona.com/blog/orchestrator-for-managing-mysql-high-availability-using-raft/

db1 master
db2 replica1
db3 replica2



#### **数据库层：**

MySQL实例可通过 mysqlsh 快速搭起主从实例。
简介：

```
mysql-js> dba.deploySandboxInstance(3307, {sandboxDir: '/custom/path'})
或全局设置（后续所有沙盒均生效）：
mysql-js> shell.options.sandboxDir = '/custom/path'
附加配置
mysql-js> dba.deploySandboxInstance(3307, {
  mysqldOptions: ["max_connections=500", "slow_query_log=1"]
})1

mysql-js> dba.startSandboxInstance(3307)  // 启动
mysql-js> dba.stopSandboxInstance(3307)   // 停止

删除实例（需先停止）
mysql-js> dba.deleteSandboxInstance(3307)
```



按需做一主两从；大概配置如下（mysqlsh会默认配置，某些参数需手动更改）

```sql
server_id = 16131
default_time_zone = "+8:00"
admin_address = '127.0.0.1'
admin_port = 33062

binlog_format = ROW
sync_binlog = 1 
gtid_mode = ON
enforce_gtid_consistency = TRUE
binlog_expire_logs_seconds = 604800
#log_bin = /var/lib/mysql
report_host = 17.16.10.131
#replication settings
relay_log_recovery = 1
slave_parallel_type = LOGICAL_CLOCK
slave_parallel_workers = 4
#slave_parallel_workers = 64
binlog_transaction_dependency_tracking = WRITESET
slave_preserve_commit_order = 1
slave_checkpoint_period = 2
replication_optimize_for_static_plugin_config = ON
replication_sender_observe_commit_only = ON
```



数据库主从：

```sql
mysql> show replicas;
+-----------+--------------+------+-----------+--------------------------------------+
| Server_Id | Host         | Port | Source_Id | Replica_UUID                         |
+-----------+--------------+------+-----------+--------------------------------------+
|     16132 | 17.16.10.132 | 3306 |     16131 | 84803525-24bb-11f0-83ac-000c29daa844 |
|     16133 | 17.16.10.133 | 3306 |     16131 | 796f08b3-24bb-11f0-8097-000c2967f5d1 |
+-----------+--------------+------+-----------+--------------------------------------+
2 rows in set (0.00 sec)
```



*percona Orchestrator 源环境可以参考percona blog链接*



#### **Orch层：**

安装如percona blog. 元数据也是如percona 用sqllite.

更改后的配置：（mysql元数据参数已删除）

```sql
{
  "Debug": true,
  "EnableSyslog": false,
  "ListenAddress": ":3000",
  "MySQLTopologyUser": "orchestrator",  --监控以及failover账户
  "MySQLTopologyPassword": "Orc@1234",
  "BackendDB": "sqlite",
  "SQLite3DataFile": "/var/lib/orchestrator/orchestrator.db", --元数据
  "ResourcesPath": "/usr/local/orchestrator/resources",  --忽略

  "MySQLTopologyCredentialsConfigFile": "",
  "MySQLTopologySSLPrivateKeyFile": "",
  "MySQLTopologySSLCertFile": "",
  "MySQLTopologySSLCAFile": "",
  "MySQLTopologySSLSkipVerify": true,
  "MySQLTopologyUseMutualTLS": false,
  "MySQLOrchestratorCredentialsConfigFile": "",
  "MySQLOrchestratorSSLPrivateKeyFile": "",
  "MySQLOrchestratorSSLCertFile": "",
  "MySQLOrchestratorSSLCAFile": "",
  "MySQLOrchestratorSSLSkipVerify": true,
  "MySQLOrchestratorUseMutualTLS": false,
  "MySQLConnectTimeoutSeconds": 1,
  "DefaultInstancePort": 3306,
  "DiscoverByShowSlaveHosts": true,
  "InstancePollSeconds": 5,
  "DiscoveryIgnoreReplicaHostnameFilters": [
    "a_host_i_want_to_ignore[.]example[.]com",
    ".*[.]ignore_all_hosts_from_this_domain[.]example[.]com",
    "a_host_with_extra_port_i_want_to_ignore[.]example[.]com:3307"
  ],
  "UnseenInstanceForgetHours": 240,
  "SnapshotTopologiesIntervalHours": 0,
  "InstanceBulkOperationsWaitTimeoutSeconds": 10,
  "HostnameResolveMethod": "default",
  "MySQLHostnameResolveMethod": "@@hostname",
  "SkipBinlogServerUnresolveCheck": true,
  "ExpiryHostnameResolvesMinutes": 60,
  "RejectHostnameResolvePattern": "",
  "ReasonableReplicationLagSeconds": 10,
  "ProblemIgnoreHostnameFilters": [],
  "VerifyReplicationFilters": false,
  "ReasonableMaintenanceReplicationLagSeconds": 20,
  "CandidateInstanceExpireMinutes": 60,
  "AuditLogFile": "",
  "AuditToSyslog": false,
  "RemoveTextFromHostnameDisplay": ".mydomain.com:3306",
  "ReadOnly": false,
  "AuthenticationMethod": "basic", --web
  "HTTPAuthUser": "admin",  --web用户
  "HTTPAuthPassword": "admin", --web密码
  "AuthUserHeader": "",
  
  ## 启用raft
  "RaftEnabled": true,
  "RaftAdvertise": "17.16.10.131", --本节点ip
  "RaftBind":"17.16.10.131",
  "RaftDataDir": "/var/lib/orchestrator",
  "DefaultRaftPort":10008,
  "RaftNodes":[   --节点
  "17.16.10.131",
  "17.16.10.132",
  "17.16.10.133"
  ],
  "PowerAuthUsers": [
    "*"
  ],
  "ClusterNameToAlias": {
    "127.0.0.1": "test suite"
  },
  "ReplicationLagQuery": "",
  "DetectClusterAliasQuery": "SELECT ifnull(max(cluster_name), '''') as cluster_alias from meta.cluster where anchor=1;", --获取MySQL 节点集群详细信息
  "DetectClusterDomainQuery": "",
  "DetectInstanceAliasQuery": "",
  "DetectPromotionRuleQuery": "",
  "DataCenterPattern": "[.]([^.]+)[.][^.]+[.]mydomain[.]com",
  "PhysicalEnvironmentPattern": "[.]([^.]+[.][^.]+)[.]mydomain[.]com",
  "PromotionIgnoreHostnameFilters": [],
  "DetectSemiSyncEnforcedQuery": "",
  "ServeAgentsHttp": false,
  "AgentsServerPort": ":3001",
  "AgentsUseSSL": false,
  "AgentsUseMutualTLS": false,
  "AgentSSLSkipVerify": false,
  "AgentSSLPrivateKeyFile": "",
  "AgentSSLCertFile": "",
  "AgentSSLCAFile": "",
  "AgentSSLValidOUs": [],
  "UseSSL": false,
  "UseMutualTLS": false,
  "SSLSkipVerify": false,
  "SSLPrivateKeyFile": "",
  "SSLCertFile": "",
  "SSLCAFile": "",
  "SSLValidOUs": [],
  "URLPrefix": "",
  "StatusEndpoint": "/api/status",
  "StatusSimpleHealth": true,
  "StatusOUVerify": false,
  "AgentPollMinutes": 60,
  "UnseenAgentForgetHours": 6,
  "StaleSeedFailMinutes": 60,
  "SeedAcceptableBytesDiff": 8192,
  "PseudoGTIDPattern": "",
  "PseudoGTIDPatternIsFixedSubstring": false,
  "PseudoGTIDMonotonicHint": "asc:",
  "DetectPseudoGTIDQuery": "",
  "BinlogEventsChunkSize": 10000,
  "SkipBinlogEventsContaining": [],
  "ReduceReplicationAnalysisCount": true,
  "FailureDetectionPeriodBlockMinutes": 60,
  "FailMasterPromotionOnLagMinutes": 0,
  "RecoveryPeriodBlockSeconds": 60,
  "RecoveryIgnoreHostnameFilters": [],
  "RecoverMasterClusterFilters": [   --调整集群名 或者 * 一般 * 即可
    "*"
  ],
  "RecoverIntermediateMasterClusterFilters": [ --以上同理
    "*"
  ],
  "OnFailureDetectionProcesses": [
    "echo 'Detected {failureType} on {failureCluster}. Affected replicas: {countSlaves}' >> /tmp/recovery.log"
  ],
  "PreGracefulTakeoverProcesses": [
    "echo 'Planned takeover about to take place on {failureCluster}. Master will switch to read_only' >> /tmp/recovery.log"
  ],
  "PreFailoverProcesses": [
    "echo 'Will recover from {failureType} on {failureCluster}' >> /tmp/recovery.log"
  ],
  "PostFailoverProcesses": [
    "echo '(for all types) Recovered from {failureType} on {failureCluster}. Failed: {failedHost}:{failedPort}; Successor: {successorHost}:{successorPort}' >> /tmp/recovery.log"
  ],
  "PostUnsuccessfulFailoverProcesses": [],
  "PostMasterFailoverProcesses": [
    "echo 'Recovered from {failureType} on {failureCluster}. Failed: {failedHost}:{failedPort}; Promoted: {successorHost}:{successorPort}' >> /tmp/recovery.log"
  ],
  "PostIntermediateMasterFailoverProcesses": [
    "echo 'Recovered from {failureType} on {failureCluster}. Failed: {failedHost}:{failedPort}; Successor: {successorHost}:{successorPort}' >> /tmp/recovery.log"
  ],
  "PostGracefulTakeoverProcesses": [
    "echo 'Planned takeover complete' >> /tmp/recovery.log"
  ],
  "CoMasterRecoveryMustPromoteOtherCoMaster": true,
  "DetachLostSlavesAfterMasterFailover": true,
  "ApplyMySQLPromotionAfterMasterFailover": true,
  "PreventCrossDataCenterMasterFailover": false,
  "PreventCrossRegionMasterFailover": false,
  "MasterFailoverDetachReplicaMasterHost": false,
  "MasterFailoverLostInstancesDowntimeMinutes": 0,
  "PostponeReplicaRecoveryOnLagMinutes": 0,
  "OSCIgnoreHostnameFilters": [],
  "GraphiteAddr": "",
  "GraphitePath": "",
  "GraphiteConvertHostnameDotsToUnderscores": true,
  "ConsulAddress": "",
  "ConsulAclToken": "",
  "ConsulKVStoreProvider": "consul"
}
```



```sql
## http://17.16.10.131:3000/api/status
{
  "Code": "OK",
  "Message": "Application node is healthy",
  "Details": {
    "Healthy": true,
    "Hostname": "db1",
    "Token": "3195acd4f9e68429d6855fd7b162e9cdd59080acbe43573118ae010fe8448653",
    "IsActiveNode": true,
    "ActiveNode": {
      "Hostname": "17.16.10.131:10008",
      "Token": "",
      "AppVersion": "",
      "FirstSeenActive": "",
      "LastSeenActive": "",
      "ExtraInfo": "",
      "Command": "",
      "DBBackend": "",
      "LastReported": "0001-01-01T00:00:00Z"
    },
    "Error": null,
    "AvailableNodes": [
      {
        "Hostname": "db1",
        "Token": "3195acd4f9e68429d6855fd7b162e9cdd59080acbe43573118ae010fe8448653",
        "AppVersion": "3.2.6-14",
        "FirstSeenActive": "2025-05-12T08:26:00Z",
        "LastSeenActive": "2025-05-12T09:02:42Z",
        "ExtraInfo": "",
        "Command": "",
        "DBBackend": "/var/lib/orchestrator/orchestrator.db",
        "LastReported": "0001-01-01T00:00:00Z"
      }
    ],
    "RaftLeader": "17.16.10.131:10008",
    "IsRaftLeader": true,
    "RaftLeaderURI": "http://17.16.10.131:3000",
    "RaftAdvertise": "17.16.10.131",
    "RaftHealthyMembers": [
      "17.16.10.133",
      "17.16.10.131",
      "17.16.10.132"
    ]
  }
}
```



三台MySQL、Orchestrator 以及相应服务端口放开 则进行raft-leader ip:3000进行初始节点发现

![image-20250429155820996](C:\Users\itwb_lixl\AppData\Roaming\Typora\typora-user-images\image-20250429155820996.png)



集群信息：

![image-20250513091935767](C:\Users\itwb_lixl\AppData\Roaming\Typora\typora-user-images\image-20250513091935767.png)





errant gtid found处理：https://www.percona.com/blog/fixing-errant-gtid-with-orchestrator