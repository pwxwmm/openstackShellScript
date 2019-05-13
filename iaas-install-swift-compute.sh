#!/bin/bash
source /etc/xiandian/openrc.sh
yum install xfsprogs rsync openstack-swift-account openstack-swift-container openstack-swift-object -y
mkfs.xfs -i size=1024 -f /dev/$OBJECT_DISK
sed -i '/nodiratime/d' /etc/fstab
echo "/dev/$OBJECT_DISK /swift/node xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab
mkdir -p /swift/node
mount /dev/$OBJECT_DISK /swift/node
scp $HOST_NAME:/etc/swift/*.ring.gz /etc/swift/

cat <<EOF > /etc/rsyncd.conf
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
uid = swift
gid = swift
address = 127.0.0.1
[account]
path            = /swift/node
read only       = false
write only      = no
list            = yes
incoming chmod  = 0644
outgoing chmod  = 0644
max connections = 25
lock file =     /var/lock/account.lock
[container]
path            = /swift/node
read only       = false
write only      = no
list            = yes
incoming chmod  = 0644
outgoing chmod  = 0644
max connections = 25
lock file =     /var/lock/container.lock
[object]
path            = /swift/node
read only       = false
write only      = no
