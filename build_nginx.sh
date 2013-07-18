#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
HOST=192.168.1.158
TARGET=nginx-1.4.2.tar.gz
SOURCE=http://$HOST/deploy/nginx/dist/$TARGET

# Create a build directory
mkdir -p /opt/install/nginx && cd /opt/install/nginx

# Prepare for compilation source
curl -o $TARGET $SOURCE
curl -o ngx_devel_kit.tar.gz http://$HOST/deploy/nginx/dist\ngx_devel_kit.tar.gz 
curl -o lua-nginx-module.tar.gz http://$HOST/deploy/nginx/dist\lua-nginx-module.tar.gz

mkdir -p tmp && tar -zxvf $TARGET -C tmp
tar -zxvf ngx_devel_kit.tar.gz
tar -zxvf lua-nginx-module.tar.gz

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y pcre-devel zlib-devel openssl-devel

# Create a User Group
groupadd nginx
useradd -r -g nginx nginx

# Compile and deploy
mv tmp/* source && cd source

export LUAJIT_LIB=/opt/environment/lua/lj2/lib
export LUAJIT_INC=/opt/environment/lua/lj2/include/luajit-2.0

./configure \
--prefix=/opt/server/web/nginx \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--http-client-body-temp-path=/opt/server/web/nginx/var/tmp/nginx/client-body \
--http-proxy-temp-path=/opt/server/web/nginx/var/tmp/nginx/proxy \
--http-fastcgi-temp-path=/opt/server/web/nginx/var/tmp/nginx/fastcgi \
--http-uwsgi-temp-path=/opt/server/web/nginx/var/tmp/nginx/uwsgi \
--http-scgi-temp-path=/opt/server/web/nginx/var/tmp/nginx/scgi \
--add-module=../ngx_devel_kit-0.2.18 \
--add-module=../lua-nginx-module-0.8.4 \
--with-ld-opt="-Wl,-rpath,$LUAJIT_LIB"
make
make install

cd /opt/server/web/nginx

mkdir -p var/tmp/nginx var/lock var/run

curl -o conf/nginx.conf http://$HOST/deploy/nginx/conf/nginx.conf

# Postinstallation setup
cd /opt/server/web/nginx
chown -R nginx .
chgrp -R nginx .
chown -R root .
chown -R nginx html var

# Configuration
curl -o /etc/init.d/nginx http://$HOST/deploy/nginx/init/nginx
chmod a+x /etc/init.d/nginx

# Additional
chkconfig --add nginx
chkconfig nginx on


