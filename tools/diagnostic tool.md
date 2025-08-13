diagnostic tool

• top - display Linux tasks

![image-20250321152234505](C:\Users\itwb_lixl\AppData\Roaming\Typora\typora-user-images\image-20250321152234505.png)

• dmesg - print or control the kernel ring buffer [dmesg | tail 是否存在oom-killer 或 tcp drop等错误信息]



• vmstat 1 检查r、free、si、so、us, sy, id, wa, st列
• mpstat -P ALL 1 检查CPU使用率是否均衡
• pidstat 1 检查进程的cpu使用率、多核利用情况
• iostat -xz 1 检查r/s, w/s, rkB/s, wkB/s, await, avgqu-sz, %util (yum install sysstat)
• free -m 检查内存使用情况
• sar -n DEV 1 检查网络吞吐量
• sar -n TCP,ETCP 1 检查tcp连接情况active/s, passive/s, retrans/s 