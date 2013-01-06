#!/bin/sh
########################################################################################
#
# Install JDK Script
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=Python-2.7.3.tar.bz2
SOURCE=http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2

# Create a build directory
mkdir -p /opt/install/python && cd /opt/install/python

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -xvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y ncurses-devel openssl-devel readline-devel

# Create a User Group

# Compile and deploy
mv tmp/* source && cd source
./configure \
--prefix=/opt/environment/python/2.7.3
make
make install

cd ..
curl -O http://python-distribute.org/distribute_setup.py
curl -O https://raw.github.com/pypa/pip/master/contrib/get-pip.py
/opt/environment/python/2.7.3/bin/python2.7 distribute_setup.py
/opt/environment/python/2.7.3/bin/python2.7 get-pip.py

# Postinstallation setup
export PATH=$PATH:/opt/environment/python/2.7.3/bin

# Configuration

# Additional
sed -i '/export PATH=/a\export PATH=$PATH:\/opt\/environment\/python\/2.7.3\/bin' /etc/profile


