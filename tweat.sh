#!/bin/env bash
################################################################################
# Centos script for server
################################################################################

export PATH=$PATH:/bin:/sbin:/usr/sbin

# Require root to run this script.
if [[ "$(whoami)" != "root" ]]; then
echo "Please run this script as root." >&2
  exit 1
fi

SERVICE=`which service`
CHKCONFIG=`which chkconfig`

#
# 设置升级源
#
echo '设置升级源'
cd /etc/yum.repos.d/
cp -rf /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
sed -i -e 's/mirrorlist/#mirrorlist/' CentOS-Base.repo
sed -i -e 's/#baseurl/baseurl/' CentOS-Base.repo
sed -i -e 's/mirror.centos.org/mirrors.sohu.com/' CentOS-Base.repo

#
# 安装工具软件sysstat, ntp, snmpd, sudo
#
yum install -y sysstat ntp 

#
# 优化硬盘
#
#cp -rf /etc/fstab /etc/fstab.bak
# 关闭系统写入文件最后读取时间
#sed -i 's/ext3 defaults[[:space:]]/ext3 defaults,noatime/' /etc/fstab
# 关闭系统按时间间隔决定下次重启时运行fsck
#grep ext3 /etc/fstab | grep -v boot | awk '{print $1}' | xargs -i tune2fs -i0 {}

#
# 配置时间同步
#
echo "/usr/sbin/ntpdate cn.pool.ntp.org" >> /etc/cron.weekly/ntpdate
chmod +x /etc/cron.weekly/ntpdate

#
#修改时区
#
cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#
# 关闭SELINUX
#
cp -rf /etc/sysconfig/selinux /etc/sysconfig/selinux.bak
sed -i '/SELINUX/s/\(enforcing\|permissive\)/disabled/' /etc/sysconfig/selinux

#
# 禁用IPV6
#
#cp -rf /etc/modprobe.conf /etc/modprobe.conf.bak
#echo "alias net-pf-10 off" >> /etc/modprobe.conf
#echo "alias ipv6 off" >> /etc/modprobe.conf

#
# 关闭不必要的服务
#
SERVICES="auditd ip6tables"
for service in $SERVICES
do
    ${CHKCONFIG} $service off
    ${SERVICE} $service stop
done

#
# 优化内核参数
#
mv /etc/sysctl.conf /etc/sysctl.conf.bak
echo -e "kernel.core_uses_pid = 1\n"\
"kernel.msgmnb = 65536\n"\
"kernel.msgmax = 65536\n"\
"kernel.shmmax = 68719476736\n"\
"kernel.shmall = 4294967296\n"\
"kernel.sysrq = 0\n"\
"net.core.netdev_max_backlog = 262144\n"\
"net.core.rmem_default = 8388608\n"\
"net.core.rmem_max = 16777216\n"\
"net.core.somaxconn = 262144\n"\
"net.core.wmem_default = 8388608\n"\
"net.core.wmem_max = 16777216\n"\
"net.ipv4.conf.default.rp_filter = 1\n"\
"net.ipv4.conf.default.accept_source_route = 0\n"\
"net.ipv4.ip_forward = 0\n"\
"net.ipv4.ip_local_port_range = 5000 65000\n"\
"net.ipv4.tcp_fin_timeout = 1\n"\
"net.ipv4.tcp_keepalive_time = 30\n"\
"net.ipv4.tcp_max_orphans = 3276800\n"\
"net.ipv4.tcp_max_syn_backlog = 262144\n"\
"net.ipv4.tcp_max_tw_buckets = 6000\n"\
"net.ipv4.tcp_mem = 94500000 915000000 927000000\n"\
"net.ipv4.tcp_no_metrics_save=1\n"\
"net.ipv4.tcp_rmem = 4096 87380 16777216\n"\
"net.ipv4.tcp_sack = 1\n"\
"net.ipv4.tcp_syn_retries = 1\n"\
"net.ipv4.tcp_synack_retries = 1\n"\
"net.ipv4.tcp_syncookies = 1\n"\
"net.ipv4.tcp_timestamps = 0\n"\
"net.ipv4.tcp_tw_recycle = 1\n"\
"net.ipv4.tcp_tw_reuse = 1\n"\
"net.ipv4.tcp_window_scaling = 1\n"\
"net.ipv4.tcp_wmem = 4096 16384 16777216\n" > /etc/sysctl.conf
sysctl -p

#
# 增加文件描述符限制
#
cp -rf /etc/security/limits.conf /etc/security/limits.conf.bak
sed -i '/# End of file/i\*\t\t-\tnofile\t\t65535' /etc/security/limits.conf




