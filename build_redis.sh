#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=redis-2.6.7.tar.gz
SOURCE=http://redis.googlecode.com/files/redis-2.6.7.tar.gz

# Create a build directory
mkdir -p /opt/install/redis && cd /opt/install/redis

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake

# Create a User Group
groupadd redis
useradd -r -g redis redis

# Compile and deploy
mv tmp/* source && cd source
make PREFIX=/opt/server/cache/redis
make install PREFIX=/opt/server/cache/redis

cd /opt/server/cache/redis
mkdir -p conf var/run var/lock var/snapshot logs
curl -o conf/redis.conf https://raw.github.com/fly2wind/TSShellScript/master/redis/conf/redis.conf

# Postinstallation setup
cd /opt/server/cache/redis
chown -R redis .
chgrp -R redis .
chown -R root .
chown -R redis var logs

# Configuration
curl -o /etc/init.d/redis https://raw.github.com/fly2wind/TSShellScript/master/redis/init/redis
chmod a+x /etc/init.d/redis

# Additional
chkconfig --add redis
chkconfig redis on


