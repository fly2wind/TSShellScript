#!/bin/sh
########################################################################################
#
# Install JDK Script
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=OTP_R15B03-1.tar.gz
SOURCE=https://nodeload.github.com/erlang/otp/tar.gz/OTP_R15B03-1

# Create a build directory
mkdir -p /opt/install/erlang && cd /opt/install/erlang

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y ncurses-devel openssl-devel

# Create a User Group

# Compile and deploy
mv tmp/* source && cd source
./otp_build autoconf
./configure \
--prefix=/opt/environment/erlang/R15B03 \
--enable-threads \
--enable-smp-support \
--enable-kernel-poll \
--enable-hipe \
--without-termcap \
--without-javac \
--with-ssl
make
make install

# Postinstallation setup
export PATH=$PATH:/opt/environment/erlang/R15B03/bin

# Configuration

# Additional
# export PATH USER
sed -i '/export PATH=/a\export PATH=$PATH:\/opt\/environment\/erlang\/R15B03\/bin' /etc/profile

