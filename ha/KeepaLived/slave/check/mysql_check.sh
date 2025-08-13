#!/bin/bash
NAME=mysql
count=$(netstat -ano | grep ":::3306" | grep "LISTEN" | wc -l)
if [ ${count} -eq 0 ];then 
  exit 9
fi
exit 0
