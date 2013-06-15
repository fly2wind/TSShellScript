#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=ejabberd-2.1.12.tgz
SOURCE=http://www.process-one.net/downloads/ejabberd/2.1.12/ejabberd-2.1.12.tgz

# Create a build directory
mkdir -p /opt/install/ejabberd && cd /opt/install/ejabberd

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y expat-devel

# Create a User Group
groupadd ejabberd
useradd -r -g ejabberd ejabberd

# Compile and deploy
mv tmp/* source && cd source/src

export PATH=$PATH:/opt/environment/erlang/R16B/bin

./configure \
--prefix=/opt/server/broker/ejabberd \
--enable-user=ejabberd \
--enable-full-xml \
--enable-nif
make
make install

curl -o mod_interact.tar.gz https://nodeload.github.com/fly2wind/mod_interact/tar.gz/master
tar -zxvf mod_interact.tar.gz && cd mod_interact-master
./build.sh && cp ebin/*.beam /opt/server/broker/ejabberd/lib/ejabberd/ebin/

cd /opt/server/broker/ejabberd && mkdir -p var/run var/script
curl -o etc/ejabberd/ejabberd.cfg https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/conf/ejabberd.cfg
curl -o etc/ejabberd/ejabberdctl.cfg https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/conf/ejabberdctl.cfg
curl -o etc/ejabberd/inetrc https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/conf/inetrc
curl -o var/script/authentication.py https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/script/authentication.py

# Postinstallation setup
cd /opt/server/broker/ejabberd
chown -R ejabberd .
chgrp -R ejabberd .
chown -R root .
chown -R ejabberd var

# Configuration
sed -i "/^ERL=.*/a\PMD=\/opt\/environment\/erlang\/R16B\/bin\/epmd" sbin/ejabberdctl
sed -i -e "s/epmd -names | grep -q name || epmd -kill/\$PMD -names | grep -q name || \$PMD -kill/" sbin/ejabberdctl
curl -o /etc/init.d/ejabberd https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/init/ejabberd
chmod a+x /etc/init.d/ejabberd

# Additional
chkconfig --add ejabberd
chkconfig ejabberd on


