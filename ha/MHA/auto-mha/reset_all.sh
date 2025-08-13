#!/bin/bash
NODE1=192.168.56.17
NODE2=192.168.56.18
MANAGER=192.168.56.19

rm -f nohup.out
nohup ssh $NODE1 "cd /root;rm -rf soft conf shell automha* /etc/my.cnf;rm -rf /usr/local/mysql/*"
nohup ssh $NODE2 "cd /root;rm -rf soft conf shell automha* /etc/my.cnf;rm -rf /usr/local/mysql/*"
nohup ssh $MANAGER "cd /root;rm -rf soft conf shell automha* /etc/mha_manager /etc/my.cnf"
nohup scp automha*.tar.gz $NODE1:/root
nohup scp automha*.tar.gz $NODE2:/root
nohup scp automha*.tar.gz $MANAGER:/root
nohup ssh $NODE1 -t "tar zxvf /root/automha*.tar.gz;/root/reset_mysql.sh" &
nohup ssh $NODE2 -t "tar zxvf /root/automha*.tar.gz;/root/reset_mysql.sh" &
nohup ssh $MANAGER -t "tar zxvf /root/automha*.tar.gz" &
/usr/bin/rm -rf /usr/local/mysql*
/root/reset_mysql.sh 
/usr/local/mysql/bin/mysqladmin ping
if [ $? -eq 1 ]; then
  echo "wait 10 seconds"
  sleep 10;
else
  /usr/local/mysql/bin/mysql < createdb.sql
fi
./automha.sh -S
