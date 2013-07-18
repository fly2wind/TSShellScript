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
TARGET=apache-tomcat-7.0.42.tar.gz
SOURCE=http://$HOST/deploy/tomcat/dist/$TARGET

# Create a build directory
mkdir -p /opt/install/tomcat && cd /opt/install/tomcat

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y apr-devel openssl-devel

# Create a User Group
groupadd tomcat
useradd -r -g tomcat tomcat

# Compile and deploy
mkdir -p /opt/server/web && mv tmp/* /opt/server/web/tomcat && cd /opt/server/web/tomcat/bin
tar -zxvf tomcat-native.tar.gz && cd tomcat-native-1.1.27-src/jni/native/
./configure \
--with-apr=/usr/bin/apr-1-config \
--with-java-home=/opt/environment/java/1.7.0 \
--with-ssl=yes \
--prefix=/opt/server/web/tomcat
make
make install

cd /opt/server/web/tomcat
curl -o conf/server.xml http://$HOST/deploy/tomcat/conf/server.xml
curl -o conf/tomcat-users.xml http://$HOST/deploy/tomcat/conf/tomcat-users.xml
curl -o conf/wrapper.conf http://$HOST/deploy/tomcat/conf/wrapper.conf
curl -o lib/wrapper.jar http://$HOST/deploy/tomcat/dist/wrapper.jar
curl -o lib/libwrapper.so http://$HOST/deploy/tomcat/dist/libwrapper.so
curl -o bin/tomcat http://$HOST/deploy/tomcat/dist/tomcat

# Postinstallation setup
cd /opt/server/web/tomcat
chown -R tomcat .
chgrp -R tomcat .
chown -R root .
chown -R tomcat conf webapps work temp logs

# Configuration
curl -o /etc/init.d/tomcat http://$HOST/deploy/tomcat/init/tomcat
chmod a+x /etc/init.d/tomcat

# Additional
chkconfig --add tomcat
chkconfig tomcat on
