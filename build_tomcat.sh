#!/bin/sh
########################################################################################
#
# Install Ejabberd Server
# 
# Shawn Ma
#
########################################################################################
# Define
TARGET=apache-tomcat-7.0.34.tar.gz
SOURCE=http://mirror.bjtu.edu.cn/apache/tomcat/tomcat-7/v7.0.34/bin/$TARGET

# Create a build directory
mkdir -p /opt/install/tomcat && cd /opt/install/tomcat

# Prepare for compilation source
curl -o $TARGET $SOURCE
mkdir -p tmp && tar -zxvf $TARGET -C tmp
curl -O https://raw.github.com/fly2wind/TSShellScript/master/tomcat/server.xml
curl -O https://raw.github.com/fly2wind/TSShellScript/master/tomcat/tomcat-users.xml
curl -o wrapper-linux-x86-64-3.5.17.tar.gz wrapper.tanukisoftware.com/download/3.5.17/wrapper-linux-x86-64-3.5.17.tar.gz
mkdir -p wrapper && tar -zxvf wrapper-linux-x86-64-3.5.17.tar.gz -C wrapper

# Install build dependencies
yum install -y apr-devel openssl-devel

# Create a User Group
groupadd tomcat
useradd -r -g tomcat tomcat

# Compile and deploy
mkdir -p /opt/server/web && mv tmp/* /opt/server/web/tomcat && cd /opt/server/web/tomcat/bin
tar -zxvf tomcat-native.tar.gz && cd tomcat-native-1.1.24-src/jni/native/
./configure \
--with-apr=/usr/bin/apr-1-config \
--with-java-home=/opt/environment/java/1.7.0 \
--with-ssl=yes \
--prefix=/opt/server/web/tomcat
make
make install
/bin/cp -rf /opt/install/tomcat/server.xml /opt/server/web/tomcat/conf/
/bin/cp -rf /opt/install/tomcat/tomcat-users.xml /opt/server/web/tomcat/conf/
/bin/cp -rf /opt/install/tomcat/wrapper/wrapper-linux-x86-64-3.5.17/bin/wrapper /opt/server/web/tomcat/bin/tomcat
/bin/cp -rf /opt/install/tomcat/wrapper/wrapper-linux-x86-64-3.5.17/lib/wrapper.jar /opt/server/web/tomcat/lib/
/bin/cp -rf /opt/install/tomcat/wrapper/wrapper-linux-x86-64-3.5.17/lib/libwrapper.so /opt/server/web/tomcat/lib/
/bin/cp -rf /opt/install/tomcat/wrapper/wrapper-linux-x86-64-3.5.17/src/conf/wrapper.conf.in /opt/server/web/tomcat/conf/wrapper.conf
/bin/cp -rf /opt/install/tomcat/wrapper/wrapper-linux-x86-64-3.5.17/src/bin/sh.script.in /etc/init.d/tomcat

# Postinstallation setup
cd /opt/server/web/tomcat
chown -R tomcat .
chgrp -R tomcat .
chown -R root .
chown -R tomcat conf webapps work temp logs

# Configuration
sed -i -e "s/@app.name@/tomcat/" /etc/init.d/tomcat
sed -i -e "s/@app.long.name@/Tomcat Application Server/" /etc/init.d/tomcat
sed -i -e "s/^WRAPPER_CMD=.*/WRAPPER_CMD=\"\/opt\/server\/web\/tomcat\/bin\/tomcat\"/" /etc/init.d/tomcat
sed -i -e "s/^WRAPPER_CONF=.*/WRAPPER_CONF=\"\/opt\/server\/web\/tomcat\/conf\/wrapper.conf\"/" /etc/init.d/tomcat
sed -i -e "s/^PIDDIR=.*/PIDDIR=\"\/opt\/server\/web\/tomcat\/work\"/" /etc/init.d/tomcat
sed -i -e "s/^#RUN_AS_USER=.*/RUN_AS_USER=tomcat/" /etc/init.d/tomcat
sed -i -e "s/^LOCKDIR=.*/LOCKDIR=\"\$PIDDIR\/var\/lock\/subsys\"/" /etc/init.d/tomcat

sed -i -e "s/^#set.JAVA_HOME=.*/set.JAVA_HOME=\/opt\/environment\/java\/1.7.0/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^set.JAVA_HOME=.*/a\set.TOMCAT_HOME=\/opt\/server\/web\/tomcat" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^#wrapper.java.command=.*/wrapper.java.command=%JAVA_HOME%\/bin\/java/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^wrapper.java.mainclass=.*/wrapper.java.mainclass=org.tanukisoftware.wrapper.WrapperStartStopApp/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^wrapper.java.classpath.1=.*/wrapper.java.classpath.1=%TOMCAT_HOME%\/lib\/wrapper.jar/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.classpath.1=.*/a\wrapper.java.classpath.2=%JAVA_HOME%\/lib\/tools.jar" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.classpath.2=.*/a\wrapper.java.classpath.3=%TOMCAT_HOME%\/bin\/bootstrap.jar" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.classpath.3=.*/a\wrapper.java.classpath.4=%TOMCAT_HOME%\/bin\/commons-daemon.jar" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.classpath.4=.*/a\wrapper.java.classpath.5=%TOMCAT_HOME%\/bin\/tomcat-juli.jar" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^wrapper.java.library.path.1=.*/wrapper.java.library.path.1=%TOMCAT_HOME%\/lib/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^wrapper.java.additional.1=.*/wrapper.java.additional.1=-server/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.1=.*/a\wrapper.java.additional.2=-Dcatalina.base=%TOMCAT_HOME%" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.2=.*/a\wrapper.java.additional.3=-Dcatalina.home=%TOMCAT_HOME%" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.3=.*/a\wrapper.java.additional.4=-Xss1024K" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.4=.*/a\wrapper.java.additional.5=-Xms1024m" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.5=.*/a\wrapper.java.additional.6=-Xmx1024m" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.6=.*/a\wrapper.java.additional.7=-XX:PermSize=128m" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.java.additional.7=.*/a\wrapper.java.additional.8=-XX:MaxPermSize=256m" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^wrapper.app.parameter.1=.*/wrapper.app.parameter.1=org.apache.catalina.startup.Bootstrap/" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.app.parameter.1=.*/a\wrapper.app.parameter.2=1" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.app.parameter.2=.*/a\wrapper.app.parameter.3=start" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.app.parameter.3=.*/a\wrapper.app.parameter.4=org.apache.catalina.startup.Bootstrap" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.app.parameter.4=.*/a\wrapper.app.parameter.5=true" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.app.parameter.5=.*/a\wrapper.app.parameter.6=1" /opt/server/web/tomcat/conf/wrapper.conf
sed -i "/^wrapper.app.parameter.6=.*/a\wrapper.app.parameter.7=stop" /opt/server/web/tomcat/conf/wrapper.conf
sed -i -e "s/^wrapper.logfile=.*/wrapper.logfile=%TOMCAT_HOME%\/logs\/wrapper.log/" /opt/server/web/tomcat/conf/wrapper.conf

# Additional
chkconfig --add tomcat
chkconfig tomcat on
