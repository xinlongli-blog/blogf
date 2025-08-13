#!/bin/bash
service mysql stop
kill -9  `pidof mysqld`
rm -rf /usr/local/mysql*
rm -rf /etc/my.cnf
cd /root
./setup_mysql.sh 5.7

