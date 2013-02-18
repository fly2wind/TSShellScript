#!/bin/sh
########################################################################################
#
# Install MySQL Script
# 
# Shawn Ma
# 2013-01-06
#
########################################################################################
# Define
TARGET=mysql-5.5.30.tar.gz
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
-DCMAKE_INSTALL_PREFIX=/opt/server/database/mysql \
-DSYSCONFDIR=/opt/server/database/mysql \
-DMYSQL_UNIX_ADDR=/opt/server/database/mysql/tmp/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DMYSQL_DATADIR=/opt/server/database/mysql/data \
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

cd /opt/server/database/mysql
curl -o my.cnf https://raw.github.com/fly2wind/TSShellScript/master/mysql/conf/my.cnf


# Postinstallation setup
cd /opt/server/database/mysql
chown -R mysql .
chgrp -R mysql .
scripts/mysql_install_db --user=mysql
chown -R root .
chown -R mysql data

# Configuration
curl -o /etc/init.d/mysql https://raw.github.com/fly2wind/TSShellScript/master/mysql/init/mysql
chmod a+x /etc/init.d/mysql

/etc/init.d/mysql start
bin/mysqladmin -u root password "TV.xian"
bin/mysql -u root -pTV.xian -e "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'TV.xian' WITH GRANT OPTION; FLUSH PRIVILEGES;"
bin/mysql -u root -pTV.xian -e "GRANT REPLICATION SLAVE ON *.* TO 'backup'@'%' IDENTIFIED BY 'backup'; FLUSH PRIVILEGES;"; 
/etc/init.d/mysql stop

# Additional
chkconfig --add mysql
chkconfig mysql on
