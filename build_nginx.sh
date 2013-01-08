#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=nginx-1.2.6.tar.gz
SOURCE=http://nginx.org/download/nginx-1.2.6.tar.gz

# Create a build directory
mkdir -p /opt/install/nginx && cd /opt/install/nginx

# Prepare for compilation source
curl -o $TARGET $SOURCE
curl -o ngx_devel_kit.tar.gz https://nodeload.github.com/simpl/ngx_devel_kit/tar.gz/v0.2.17
curl -o lua-nginx-module.tar.gz https://nodeload.github.com/chaoslawful/lua-nginx-module/tar.gz/v0.7.12

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
--add-module=../ngx_devel_kit-0.2.17 \
--add-module=../lua-nginx-module-0.7.12 \
--with-ld-opt="-Wl,-rpath,$LUAJIT_LIB"
make
make install

cd /opt/server/web/nginx
mkdir -p var/tmp/nginx var/lock var/run

curl -o conf/nginx.conf https://raw.github.com/fly2wind/TSShellScript/master/nginx/conf/nginx.conf

# Postinstallation setup
cd /opt/server/web/nginx
chown -R nginx .
chgrp -R nginx .
chown -R root .
chown -R nginx html var

# Configuration
curl -o /etc/init.d/nginx https://raw.github.com/fly2wind/TSShellScript/master/nginx/init/nginx
chmod a+x /etc/init.d/nginx

# Additional
chkconfig --add nginx
chkconfig nginx on


