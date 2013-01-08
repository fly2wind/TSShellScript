#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=memcached-1.4.15.tar.gz
SOURCE=http://memcached.googlecode.com/files/memcached-1.4.15.tar.gz

# Create a build directory
mkdir -p /opt/install/memcached && cd /opt/install/memcached

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y libevent-devel

# Create a User Group
groupadd memcache
useradd -r -g memcache memcache

# Compile and deploy
mv tmp/* source && cd source
./configure \
--prefix=/opt/server/cache/memcached
make
make install

cd /opt/server/cache/memcached
mkdir -p conf var/run var/lock logs
curl -o conf/memcached.conf https://raw.github.com/fly2wind/TSShellScript/master/memcached/conf/memcached.conf

# Postinstallation setup
cd /opt/server/cache/memcached
chown -R memcache .
chgrp -R memcache .
chown -R root .
chown -R memcache var logs

# Configuration
curl -o /etc/init.d/memcached https://raw.github.com/fly2wind/TSShellScript/master/memcached/init/memcached
chmod a+x /etc/init.d/memcached

# Additional
chkconfig --add memcached
chkconfig memcached on


