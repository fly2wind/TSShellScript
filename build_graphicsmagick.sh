#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=GraphicsMagick-LATEST.tar.gz
SOURCE=ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.gz

# Create a build directory
mkdir -p /opt/install/graphicsmagick && cd /opt/install/graphicsmagick

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y libpng-devel libjpeg-devel libtiff-devel jasper-devel freetype-devel

# Create a User Group

# Compile and deploy
mv tmp/* source && cd source
./configure \
--prefix=/opt/tools/graphicsmagick \
--enable-shared \
--enable-static \
--with-quantum-depth=16 \
--with-ttf \
--with-jpeg \
--with-jp2 \
--with-png \
--with-zlib

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


