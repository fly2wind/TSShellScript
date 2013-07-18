#!/bin/sh
########################################################################################
#
# Install Lua Script
# 
# Shawn Ma
#
########################################################################################
# Define
HOST=192.168.1.158
TARGET=LuaJIT-2.0.2.tar.gz
SOURCE=http://$HOST/deploy/lua/dist/$TARGET

# Create a build directory
mkdir -p /opt/install/lua && cd /opt/install/lua

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake

# Create a User Group

# Compile and deploy
mv tmp/* source && cd source
make PREFIX=/opt/environment/lua/lj2
make install PREFIX=/opt/environment/lua/lj2

# Postinstallation setup
export PATH=$PATH:/opt/environment/lua/lj2/bin

# Configuration

# Additional




