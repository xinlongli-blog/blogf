```sql
Innodb 状态的部分解释:
Innodb_buffer_pool_pages_data
Innodb buffer pool缓存池中包含数据的页的数目，包括脏页。单位是page。

Innodb_buffer_pool_pages_dirty
innodb buffer pool缓存池中脏页的数目。单位是page。

Innodb_buffer_pool_pages_flushed
innodb buffer pool缓存池中刷新页请求的数目。单位是page。

Innodb_buffer_pool_pages_free
innodb buffer pool剩余的页数目。单位是page。

Innodb_buffer_pool_pages_misc
innodb buffer pool缓存池中当前已经被用作管理用途或hash index而不能用作为普通数据页的数目。单位是page。

Innodb_buffer_pool_pages_total
innodb buffer pool的页总数目。单位是page。

Innodb_buffer_pool_read_ahead
后端预读线程读取到innodb buffer pool的页的数目。单位是page。

Innodb_buffer_pool_read_ahead_evicted
预读的页数，但是没有被读取就从缓冲池中被替换的页的数量，一般用来判断预读的效率。

Innodb_buffer_pool_read_requests
innodb进行逻辑读的数量。单位是次。

Innodb_buffer_pool_reads
进行逻辑读取时无法从缓冲池中获取而执行单页读取的次数。单位是次。

Innodb_buffer_pool_wait_free
写入 InnoDB 缓冲池通常在后台进行，但有必要在没有干净页的时候读取或创建页，有必要先等待页被刷新。Innodb的IO线程从数据文件中读取了数据要写入buffer pool的时候，需要等待空闲页的次数。单位是次。

Innodb_buffer_pool_write_requests
写入 InnoDB 缓冲池的次数。单位是次。

Innodb_data_fsyncs
innodb进行fsync()操作的次数。单位是次。

Innodb_data_pending_fsyncs
innodb当前挂起 fsync() 操作的数量。单位是次。

Innodb_data_pending_reads
innodb当前挂起的读操作数。单位是次。

Innodb_data_pending_writes
inndo当前挂起的写操作数。单位是次。

Innodb_data_read
innodb读取的总数据量。单位是字节。

Innodb_data_reads
innodb数据读取总数。单位是次。

Innodb_data_writes
innodb数据写入总数。单位是次。

Innodb_data_written
innodb写入的总数据量。单位是字节。

Innodb_dblwr_pages_written
innodb已经完成的doublewrite的总页数。单位是page。

Innodb_dblwr_writes
innodb已经完成的doublewrite的总数。单位是次。

Innodb_log_waits
因日志缓存太小而必须等待其被写入所造成的等待数。单位是次。

Innodb_log_write_requests
innodb日志写入请求数。单位是次。

Innodb_log_writes
innodb log buffer写入log file的总次数。单位是次。

Innodb_os_log_fsyncs
innodb log buffer进行fsync()的总次数。单位是次。

Innodb_os_log_pending_fsyncs
当前挂起的 fsync 日志文件数。单位是次。

Innodb_os_log_pending_writes
当前挂起的写log file的数目。单位是次。

Innodb_os_log_written
写入日志文件的字节数。单位是字节。

Innodb_page_size
编译的 InnoDB 页大小 (默认 16KB)。

Innodb_pages_created
innodb总共的页数量。单位是page。

Innodb_pages_read
innodb总共读取的页数量。单位是page。

Innodb_pages_written
innodb总共写入的页数量。单位是page。

Innodb_row_lock_current_waits
innodb当前正在等待行锁的数量。单位是个。

Innodb_row_lock_time
innodb获取行锁的总消耗时间。单位是毫秒。

Innodb_row_lock_time_avg
innodb获取行锁等待的平均时间。单位是毫秒。

Innodb_row_lock_time_max
innodb获取行锁的最大等待时间。单位是毫秒。

Innodb_row_lock_waits
innodb等待获取行锁的次数。单位是次。

Innodb_rows_deleted
从innodb表中删除的行数。单位是行。

Innodb_rows_inserted
插入到innodb表中的行数。单位是行。

Innodb_rows_updated
innodb表中更新的行数。单位是行

#查看脏页数量
mysqladmin ext| grep dirty
```

