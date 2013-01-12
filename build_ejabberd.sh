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
yum install -y gcc gcc-c++ make cmake autoconf automake
yum install -y expat-devel

# Create a User Group
groupadd ejabberd
useradd -r -g ejabberd ejabberd

# Compile and deploy
mv tmp/* source && cd source/src
./configure \
--prefix=/opt/server/broker/ejabberd \
--enable-user=ejabberd \
--enable-full-xml \
--enable-nif
make
make install

cd /opt/server/broker/ejabberd
curl -o etc/ejabberd/ejabberd.cfg https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/conf/ejabberd.cfg
curl -o etc/ejabberd/ejabberdctl.cfg https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/conf/ejabberdctl.cfg
curl -o etc/ejabberd/inetrc https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/conf/inetrc

# Postinstallation setup
cd /opt/server/broker/ejabberd
chown -R ejabberd .
chgrp -R ejabberd .
chown -R root .
chown -R ejabberd var

# Configuration
sed -i "/^ERL=.*/a\PMD=\/opt\/environment\/erlang\/R15B03\/bin\/epmd" sbin/ejabberdctl
sed -i -e "s/epmd -names | grep -q name || epmd -kill/\$PMD -names | grep -q name || \$PMD -kill/" sbin/ejabberdctl
curl -o /etc/init.d/ejabberd https://raw.github.com/fly2wind/TSShellScript/master/ejabberd/init/ejabberd
chmod a+x /etc/init.d/ejabberd

# Additional
chkconfig --add ejabberd
chkconfig ejabberd on


