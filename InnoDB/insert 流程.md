#### 写流程

##### **基础概念：**

- 数据库表空间由段（segment）、区(extent)、页(page)组成
- 默认情况下有一个共享表空间ibdata1,如使用了innodb_file_per_table则每张表独立表空间（指存放数据、索引、插入缓冲bitmap页）
- 段包括了数据段（B+树的叶子结点）、索引段、回滚段
- 区，由连续的页组成，任何情况下每个区都为1M，一个区中有64个连续页（16k）
- 页，数据页（B-tree Node）默认大小为16KB
- 文件系统一页 默认大小为4KB
- 盘片被分为许多扇形的区域，每个区域叫一个扇区，硬盘中每个扇区的大小固定为512字节
- 脏页，当数据从磁盘加载到缓冲池的数据页后，数据页内容被修改后，此数据页称为脏页



##### **insert 流程：**

1. 首先 insert 进入 server 层后，会进行一些必要的检查，检查的过程中并不会涉及到磁盘的写入。
2. 检查没有问题之后，便进入引擎层开始正式的提交。我们知道 InnoDB 会将数据页缓存至内存中的 buffer pool，所以 insert 语句到了这里并不需要立刻将数据写入磁盘文件中，只需要修改 buffer pool 当中对应的数据页就可以了。 buffer pool 中的数据页刷盘并不需要在事务提交前完成，其中交互过程会在下一张图中分解。
3. 但仅仅写入内存的 buffer pool 并不能保证数据的持久化，如果 MySQL 宕机重启了，需要保证 insert 的数据不会丢失。redo log 因此而生，当 innodb_flush_log_at_trx_commit=1 时，每次事务提交都会 触发一次 redo log 刷盘。（redo log 是顺序写入，相比直接修改数据文件，redo 的磁盘写入效率更加 高效）
4. 如果开启了 binlog 日志，我们还需将事务逻辑数据写入 binlog 文件，且为了保证复制安全，建议使 用 sync_binlog=1 ，也就是每次事务提交时，都要将 binlog 日志的变更刷入磁盘。综上（在 InnoDB buffer pool 足够大且上述的两个参数设置为双一时），insert 语句成功提交时，真正发生 磁盘数据写入的，并不是 MySQL 的数据文件，而是 redo log 和 binlog 文件。然而，InnoDB buffer pool 不可能无限大，redo log 也需要定期轮换，很难容下所有的数据，下面我们就来 看看 buffer pool 与磁盘数据文件的交互方式。

<font color='orange'>InnoDB buffer pool 一页脏页大小为 16 KB，如果只写了前 4KB 时发生宕机，那这个脏页就发生了 写失败，会造成数据丢失。为了避免这一问题，InnoDB 使用了 double write 机制（InnoDB 将 double write 的数据存于共享表空间中）。在写入数据文件之前，先将脏页写入 double write 中，当然这里的写入 都是需要刷盘的。有人会问 redo log 不是也能恢复数据页吗？为什么还需要 double write？这是因为 redo log 中记录的是页的偏移量，比如在页偏移量为 800 的地方写入数据 xxx，而如果页本身已经发生损坏， 应用 redo log 也无济于事。</font>

##### double white：

原理：为了解决部分页写(partial write page)问题，当mysql将脏数据刷新到数据文件的时候，先使用内存复制将脏数据复制到内存中的double write buffer，之后通过double write buffer再分2次，每次写入1MB到共享表空间，然后立即调用fsync函数，同步到磁盘上，避免缓冲带来的问题，在这个过程中，doublewrite是顺序写，不会大小写大，在完成doublewrite写入后，在将double write buffer写入各个表空间文件，这时是离散写入。如果发生了极端情况（断电），InnoDB再次启动后，发现了一个页面数据已经损坏，那么此时就可以从double write buffer中进行数据恢复了。

double writer流程：

1. 记录redo log ，redo log buffer --> redo log file  or binlog
2. 更新数据--> dirty page（buffer pool）
3. copy data double write buffer(2M)
4. 1 write: double write(1M) --> double write(1M) for ibdata
5. recovery == 2 write， write ibd disk ibd file

<u>如果是写双写缓冲区本身失败，那么这些数据不会被写入磁盘，InnoDB此时会从磁盘加载原始数据，然后通过InnoDB的事务日志来计算出正确的数据，重新写入到双写缓冲区。</u>

> 当InnoDB恢复时，它将使用原始页面而不是doublewrite缓冲区中的损坏副本。但是，如果双写缓冲区成功并且对页面实际位置的写入失败，则InnoDB将在恢复期间使用双写缓冲区中的副本。

如果doublewrite buffer写成功的话，但是写磁盘失败，InnoDB就不用通过事务日志来计算了，或者直接用buffer的数据再写一遍。

> InnoDB知道页面何时损坏，因为每个页面的末尾都有一个校验和。校验和是最后要写入的内容，因此，如果页面的内容与校验和不匹配，则页面已损坏。因此，恢复后，InnoDB只会读取doublewrite缓冲区中的每个页面并验证校验和。如果页面的校验和不正确，它将从其原始位置读取页面。

在恢复的时候，InnoDB直接比较页面的校验和，如果不对的话，就从硬盘加载原始数据，再由事务日志开始推演正确的数据。所以InnoDB的恢复通常需要花费时间。



<font color='cornflowerblue'>InnoDB 的数据是根据聚集索引排列的，通常业务在插入数据时是按照主键递增的，所以插入聚集索 引一般是顺序磁盘写入。但是不可能每张表都只有聚集索引，当存在非聚集索引时，对于非聚集索引的变 更就可能不是顺序的，会拖慢整体的插入性能。为了解决这一问题，InnoDB 使用了 insert buffer 机制，将 对于非聚集索引的变更先放入 insert buffer ，尽量合并一些数据页后再写入实际的非聚集索引中去。</font>



1. 当 buffer pool 中的数据页达到一定量的脏页或 InnoDB 的 IO 压力较小 时，都会触发脏页的刷盘操 作。
2. 当开启 double write 时，InnoDB 刷脏页时首先会复制一份刷入 double write，在这个过程中，由于 double write 的页是连续的，对磁盘的写入也是顺序操作，性能消耗不大。
3. 无论是否经过 double write，脏页最终还是需要刷入表空间的数据文件。刷入完成后才能释放 buffer pool 当中的空间。
4. insert buffer 也是 buffer pool 中的一部分，当 buffer pool 空间不足需要交换出部分脏页时，有可能将 insert buffer 的数据页换出，刷入共享表空间中的 insert buffer 数据文件中。
5. 当 innodb_stats_persistent=ON 时，SQL 语句所涉及到的 InnoDB 统计信息也会被刷盘到 innodb_table_stats 和 innodb_index_stats 这两张系统表中，这样就不用每次再实时计算了。
6. 有一些情况下可以不经过 double write 直接刷盘 a. 关闭 double write b. 不需要 double write 保障，如 drop table 等操作 汇总两张图，一条 insert 语句的所有涉及到的数据在磁盘上会依次写入 redo log，binlog，(double write， insert buffer) 共享表空间，最后在自己的用户表空间落定为安。