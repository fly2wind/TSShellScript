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


