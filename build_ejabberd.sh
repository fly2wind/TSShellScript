#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=v2.1.11.tar.gz
SOURCE=https://nodeload.github.com/processone/ejabberd/tar.gz/v2.1.11

# Create a build directory
mkdir -p /opt/install/ejabberd && cd /opt/install/ejabberd

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp

# Install build dependencies
yum install -y expat-devel

# Create a User Group
groupadd ejabberd
useradd -r -g ejabberd ejabberd

# Compile and deploy
mv tmp/* source && cd source\src
./configure \
--prefix=/opt/server/xmpp/ejabberd \
--enable-user=ejabberd \
--enable-full-xml \
--enable-nif
make
make install

# Postinstallation setup
cd /opt/server/xmpp/ejabberd
chown -R ejabberd .
chgrp -R ejabberd .
chown -R root .
chown -R ejabberd var

# Configuration
cp /opt/install/ejabberd/source/src/ejabberd.init /etc/init.d/ejabberd && chmod a+x /etc/init.d/ejabberd
sed -i "s/^#EJABBERD_PID_PATH=.*/EJABBERD_PID_PATH=\/opt\/server\/xmpp\/ejabberd\/var\/run\/ejabberd\/ejabberd.pid/g" etc/ejabberd/ejabberdctl.cfg
sed -i "/^ERL=.*/a\PMD=\/opt\/environment\/erlang\/R15B03\/bin\/epmd" sbin/ejabberdctl
sed -i -e "s/epmd -names | grep -q name || epmd -kill/\$PMD -names | grep -q name || \$PMD -kill/" sbin/ejabberdctl
sed -i -e "s/su -/su/" /etc/init.d/ejabberd

# Additional
chkconfig --add ejabberd
chkconfig ejabberd on


