# LINUX

> waitwaitwait..

------

## 一、常用诊断命令

### 1、top

> **实时综合监控工具**，第一时间判断系统是否“忙 / 卡 / 慢”。

**关注顺序：**

1. load average 是否持续高于 CPU 核心数
2. `%Cpu(s)` 中的 `wa`（IO 等待）
3. Swap 是否被使用
4. 是否存在单进程吃满 CPU / 内存

**经验判断：**

- `load ≈ CPU 核数`：正常
- `load > CPU 核数 × 2` 且持续：系统过载
- `wa > 20%`：磁盘 IO 已成为瓶颈（重点）

| 字段 | 含义       | 关注点                                    |
| ---- | ---------- | ----------------------------------------- |
| us   | 用户态 CPU | 高：应用计算密集（MySQL / Java / Python） |
| sy   | 内核态 CPU | 高：系统调用/驱动异常                     |
| id   | 空闲 CPU   | 长期为 0：系统极忙                        |
| wa   | IO 等待    | DBA 重点：磁盘瓶颈                        |
| st   | 虚拟机抢占 | 虚拟化资源超卖                            |

------

### 2、dmesg

> **内核级日志**，用于排查 OOM、磁盘、网络、硬件问题。

**重点关注关键词：**

```bash
dmesg -T | egrep -i "oom|killed|ext4|xfs|nvme|scsi|reset|error"
```

**常见场景：**

- `Out of memory` / `Killed process` → 内存不足触发 OOM Killer
- `blk_update_request: I/O error` → 磁盘故障风险
- `TCP: Possible SYN flooding` → 连接或攻击问题

| 参数 | 说明                 |
| ---- | -------------------- |
| -T   | 显示真实时间（必加） |
| -l   | 按级别过滤           |
| -c   | 清空缓冲区（慎用）   |

------

### 3、vmstat

> **判断系统是否卡在 CPU / 内存 / IO 的关键工具**。

**推荐用法：**

```bash
vmstat 1
```

**快速结论表：**

| 指标            | 含义       | 结论          |
| --------------- | ---------- | ------------- |
| r >  CPU 核数   | 运行队列长 | CPU 不足      |
| b > 0 且  wa 高 | IO 阻塞    | 磁盘瓶颈      |
| si / so ≠  0    | Swap 读写  | 内存严重不足  |
| cs 极高         | 上下文切换 | 连接/线程过多 |

------

### 4、mpstat

> **查看多核 CPU 使用是否均衡**。

```bash
mpstat -P ALL 1
```

**关注点：**

- 是否只有某 1~2 个 CPU 很忙（单线程瓶颈）
- `%idle` 是否在所有 CPU 上都很低
- 单核 `%iowait` 高 → 中断/磁盘亲和性（Affinity）问题

**场景：**

- MySQL 单 SQL 吃满 1 个 CPU，其余空闲 → SQL 或执行计划问题

------

### 5、pidstat

> **按进程 / 线程维度分析 CPU / 内存 / IO**。

```bash
pidstat 1
pidstat -u 1        # CPU
pidstat -r 1        # 内存
pidstat -d 1        # IO
pidstat -t 1        # 线程级
```

**典型用途：**

- 找出真正消耗 CPU 的进程
- 判断进程是否多线程有效利用多核
- 定位“看起来不忙但系统很慢”的元凶

------

### 6、iostat

> **磁盘 IO 性能分析核心工具**。

```bash
iostat -xz 1
```

**关键指标解释：**

| 指标          | 含义     | 经验判断           |
| ------------- | -------- | ------------------ |
| r/s, w/s      | IOPS     | 是否频繁读写       |
| rkB/s,  wkB/s | 吞吐量   | 是否跑满带宽       |
| avgqu-sz      | 队列长度 | >1 表示排队        |
| await         | IO 延迟  | >20ms 业务感知卡顿 |
| %util         | 繁忙度   | 接近 100% 为瓶颈   |

**经验值（SSD）：**

- await < 5ms：优秀
- await > 20ms：业务已感知卡顿

------

### 7、free

> **快速判断内存是否真的不够**。

```bash
free -m
```

**正确理解：**

- `available` 才是真正可用内存
- `used` 高并不代表内存不足
- **Swap 使用 ≠ 0 且持续增长 → 必须排查**

------

### 8、sar

> **历史性能分析神器**（来自 sysstat）。

```bash
sar -u 1            # CPU
sar -r 1            # 内存
sar -b 1            # IO
sar -n DEV 1        # 网络
sar -n TCP,ETCP 1   # TCP 连接
```

**典型运维场景：**

- 回溯“昨天 3 点为什么慢”
- 分析业务高峰期资源变化趋势

```sql
ls /var/log/sa/

demo sa05
```

**回溯命令：**

1️⃣ CPU（先看是不是 IO 拖慢）

```sql
sar -u -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
```

👉 重点只看：

- `%iowait`
- `%idle`

------

2️⃣ 内存（有没有顶到 Swap）

```sql
sar -r -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
```

👉 只看：

- `kbmemavailable`

------

3️⃣ Swap（性能杀手）

```sql
sar -W -f /var/log/sa/sa05
```

👉 只要看到非 0 就是问题

------

4️⃣ 磁盘 IO（必查）

```sql
sar -b -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
```

👉 看：

- `tps`
- 是否与 `%iowait` 同步升高

------

5️⃣ 网络（可选）

```sql
sar -n DEV -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
```

**总结：**

`%iowait` 高 → **IO 瓶颈**

`kbmemavailable` 低 → **内存压力**

Swap ≠ 0 → **内存不足**

IO / CPU / 内存都正常 → **查应用 / SQL**

```sql
# CPU
sar -u -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
# 内存
sar -r -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
# Swap
sar -W -f /var/log/sa/sa05
# IO
sar -b -f /var/log/sa/sa05 -s 00:00:00 -e 03:00:00
```



------

### 9、smem

> **比 free / top 更准确的内存统计工具**（按 PSS）。

```bash
yum install smem
smem -tk
```

**适用场景：**

- 多进程共享内存（如 MySQL、Java）
- 精确评估单进程真实内存占用

| 指标 | 说明                           |
| ---- | ------------------------------ |
| USS  | 进程私有内存                   |
| PSS  | 按比例分摊的真实占用（最推荐） |

### 10、案例排查

> 排查 tmp 占用文件

```sql
[root@localhost ~]# du -ah /tmp/ | sort -rh | head -n 20
7.5G    /tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log
7.5G    /tmp/.org.chromium.Chromium.uk6IbE/Default
7.5G    /tmp/.org.chromium.Chromium.uk6IbE
7.5G    /tmp/
```

`-a`: 显示所有文件而不只是目录。

**定位源头**

```sql
[root@localhost ~]# lsof /tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log
COMMAND   PID USER   FD   TYPE DEVICE   SIZE/OFF   NODE NAME
chrome  32501 root    4w   REG  253,0 7876306584 509856 /tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log

[root@localhost ~]# stat /tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log
  文件："/tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log"
  大小：7876326744      块：15643928   IO 块：4096   普通文件
设备：fd00h/64768d      Inode：509856      硬链接：1
权限：(0644/-rw-r--r--)  Uid：(    0/    root)   Gid：(    0/    root)
环境：unconfined_u:object_r:user_tmp_t:s0
最近访问：2026-01-09 11:18:57.765314396 +0800
最近更改：2026-01-09 11:20:19.493728862 +0800
最近改动：2026-01-09 11:20:19.493728862 +0800
创建时间：-
```

**找到进程 PID：**

```sql
lsof也可以
---
[root@localhost ~]# fuser /tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log
/tmp/.org.chromium.Chromium.uk6IbE/Default/chrome_debug.log: 32501
```

**查看该 PID 的启动时间：**

```sql
[root@localhost ~]# ps -p 32501 -o lstart,etime,cmd
                 STARTED     ELAPSED CMD
Sat Sep 14 09:00:04 2024 482-02:20:57 /opt/google/chrome/chrome --allow-pre-commit-input --disable-background-networking --disable-client-side-phishing-detection --disable-default-apps --di
```

**STARTED (lstart):** 进程启动的确切日期和时间。

**ELAPSED (etime):** 进程已经运行的总时长（格式为 `DD-HH:MM:SS`）。

**CMD:** 启动该浏览器的完整命令行参数



------

## 二、诊断全景速查表（Cheat Sheet）

```text
1. top            → 看负载、CPU、内存、Swap
2. dmesg | tail   → 是否 OOM / IO / 网络错误
3. vmstat 1       → CPU / 内存 / IO 是否阻塞
4. mpstat -P ALL 1→ 多核是否均衡
5. pidstat 1      → 定位问题进程
6. iostat -xz 1   → 磁盘是否瓶颈
7. free -m        → 内存是否真实不足
8. sar            → 回溯历史问题
```

| 场景         | 命令            | 关键指标        |
| ------------ | --------------- | --------------- |
| 系统概览     | top             | load, wa        |
| 内核错误     | dmesg           | oom, error      |
| CPU/IO  判断 | vmstat 1        | r, b, wa        |
| 多核均衡     | mpstat -P ALL 1 | 单核 %idle      |
| 进程 IO      | pidstat -d 1    | kB_rd/s         |
| 磁盘瓶颈     | iostat -xz 1    | await, %util    |
| 内存评估     | free -h         | available, swap |
| 网络流量     | sar -n DEV 1    | rxkB/s          |
| 精准内存     | smem            | PSS             |

------

