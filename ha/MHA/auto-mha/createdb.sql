drop database if exists db1;
drop database if exists db2;
create database db1;
create database db2;
create table db1.t1(id int);
insert into db1.t1 values(100);
commit;

create table db2.t2(id int);
insert into db2.t2 values(200);
commit;
