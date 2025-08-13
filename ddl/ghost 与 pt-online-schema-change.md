ghost 与 pt-online-schema-change

简单对比两者之间DDL流程以及不同点。

先说结论，个人而言ghost相比pt-online-schema-change比较灵活，ghost待数据转换完成后可以等待窗口期进行数据转换，本身ghost默认就不是直接转换，这是一点，其二是没有pt-online-schema-change本质带来的痛点，就是锁机制、还有性能的影响。详细阐述如下；

ghost：

​	原理：该工具是github自主研发的一款在线DDL，不同于其他工具基于触发器来实现增量数据的转换，而是走的日志流有点类似于ogg同步工具。优点是如果是HA架构 会默认在从库上运行、相对于主库压力要小一点。当然也有诸多模式具体可以查看github文档。

流程如下：

1. 先查验binlog以及position点位；
2. migrating new table _gho；
3. 校验参数、也许参数校验在第一步之前也就是预开始环节进行校验；预校验或许是第一步参数的准确性、其二也就是这一步是参数的意义。
4. 生成两个文件 节流文件以及迁移交换文件 或者是延迟迁移文件、终止文件三者文件对应sock；
5. 开始数据copy migrating；
6. 等待转换完成、State: postponing cut-over;
7. 删除创建的标志文件，标志文件为 --postpone-cut-over-flag-file、或者进行交互命令 echo "unpostpone" |nc -U ***.sock
8. 日志输出、转换完成。

> ​	这里讲下关于ghost 'Waiting for table metadata lock'的问题，ghost锁机制相比于 pt-online-schema-change更加灵活。利用ghost做DDL迁移时，无论此时涉及的表是否有事务运行中 都能一如既往的进行数据转换、当数据转换完成时，事务若还在继续执行中，此刻进行unpostpone时ghost输出日志会爆出一条 MySQL相关 1205的错误，即锁超时，只需等待事务执行完毕后进行转换即可，也可以直接终结事务进行转换收尾工作。ghost执行前也好、执行中也好 期间大事务的存在影响不是很大。

<font color='red'>丢数据场景：</font>

*ghost有丢数据场景，原因是跟二阶段提交有关系；*

*二阶段提交 一阶段记录redo log 标记prepare阶段、二阶段是写binlog、redo log 还没标记 为commit状态时 启动ghost 会丢数据。(select最大最小边界值)*

*因为ghost会监听binlog、捕获表变更、应用至目标表。然而在某些情况下、如果在binlog中的事务已经别标注为提交、但是在ghost启动前该事务的binlog还未读取和应用、那么再执行完ghost后、这些事务会被以往、导致丢数据。*

*加共享锁可解决此问题。*



pt-online-schema-change：

​	简述：该工具是著名开源公司percona研发出的一套关于MySQL维护工具（percona-toolkit）中其中的一环。其他工具很多也很实用，本章只谈pt-online-schema-change。

​	原理：pt-online-schema-change会在涉及变更表基础上新增一个表且打个标记、在新表做DDL操作，然后会创建三个触发器分别对应DML操作，全量数据copy完成后，期间全量数据任何变更运作到触发器进行完善增量数据，最后原始表rename，新的幽灵表renema原始表，做收尾工作，删除表以及触发器，最后完成。

流程如下：

1. create new table；
2. alter new table；
3. alter end；
4. create triggers ... ；
5. copy数据、pt-online-schema-change涉及运行的insert -- <u>insert low_priority ignore into</u>.. 跟ghos不通 pt-online-schema-change多了参数LOW_PRIORITY、参数会导致执行顺序为低级、也就是说会等待其他非LOW_PRIORITY的读写操作完成后才执行，是为了减少锁竞争。个人角度而言可能是走触发器的原因所采用此参数。
6. copy完成后 会analyze 做优化表操作。
7. sawpping new table && swapped original
8. drop 、old table triggers；
9. successfully altered

> pt-online-schema-change有个问题、如果再执行前有一个大事务 pt-online-schema-change在create trigger时 会卡死、即 metadata lock、直到事务完成或者超时释放连接，才会执行以下操作。所以说 整体灵活性卡的很死、生产建议用ghost。