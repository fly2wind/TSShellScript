#!/bin/sh
########################################################################################
#
# Install MySQL Script
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=mysql-5.5.29.tar.gz
SOURCE=http://cdn.mysql.com/Downloads/MySQL-5.5/$TARGET

# Create a build directory
mkdir -p /opt/install/mysql && cd /opt/install/mysql

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y bison ncurses-devel

# Create a User Group
groupadd mysql
useradd -r -g mysql mysql

# Compile and deploy
mv tmp/* source && cd source
cmake \
-DCMAKE_INSTALL_PREFIX=/opt/server/database/mysql_slave \
-DSYSCONFDIR=/opt/server/database/mysql_slave \
-DMYSQL_UNIX_ADDR=/opt/server/database/mysql_slave/tmp/mysql.sock \
-DMYSQL_TCP_PORT=3307 \
-DMYSQL_DATADIR=/opt/server/database/mysql_slave/data \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS:STRING=all \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_DEBUG=OFF \
-DMYSQL_USER=mysql
make
make install

# Postinstallation setup
cd /opt/server/database/mysql_slave
chown -R mysql .
chgrp -R mysql .
scripts/mysql_install_db --user=mysql
chown -R root .
chown -R mysql data

# Configuration
cp support-files/my-medium.cnf my.cnf
sed -i "/\[mysqld\]$/a\datadir         = \/opt\/server\/database\/mysql_slave\/data/" my.cnf
sed -i "s/^server-id.*/server-id       = 2/g" my.cnf
cp support-files/mysql.server /etc/init.d/mysql_slave && chmod a+x /etc/init.d/mysql_slave
##chkconfig --add mysql
##chkconfig --level 345 mysql on 
##update-rc.d -a mysql
##update-rc.d mysql defaults

# Additional
/etc/init.d/mysql_slave start
bin/mysqladmin -u root password "TV.xian"
bin/mysql -u root -pTV.xian -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'TV.xian' WITH GRANT OPTION; FLUSH PRIVILEGES;"
bin/mysql -u root -pTV.xian -e "change master to master_host='192.168.102.128',master_port=3306,master_user='backup',master_password='backup', master_log_file='mysql-bin.000005',master_log_pos=326;" 
bin/mysql -u root -pTV.xian -e "start slave;"

/etc/init.d/mysql_slave stop
