#!/bin/bash

apt update
apt install mariadb-server -y

mycnf=$"
[client-server]

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

[mysqld]
skip-networking=0
skip-bind-address
"

echo "$mycnf" > "/etc/mysql/my.cnf"

service mysql start


mysql -u root -e\
  "CREATE USER 'kelompokd21'@'%' IDENTIFIED BY '';"

mysql -u root -e\
  "CREATE USER 'kelompokd21'@'localhost' IDENTIFIED BY '';"

mysql -u root -e\
  "CREATE DATABASE jarkomd21;"

mysql -u root -e\
  "GRANT ALL PRIVILEGES ON *.* TO 'kelompokd21'@'%';"

mysql -u root -e\
  "GRANT ALL PRIVILEGES ON *.* TO 'kelompokd21'@'localhost';"

mysql -u root -e\
  "FLUSH PRIVILEGES;"