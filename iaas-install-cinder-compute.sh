#!/bin/bash
source /etc/xiandian/openrc.sh
yum install lvm2 targetcli python-keystone openstack-cinder  -y
systemctl enable lvm2-lvmetad.service
systemctl restart lvm2-lvmetad.service

pvcreate -f /dev/$BLOCK_DISK
vgcreate cinder-volumes /dev/$BLOCK_DISK

# sed -i  "/$BLOCK_DISK/d"  /etc/lvm/lvm.conf
# sed -i  '/^devices/a\        filter = [ "a/sdb/", "r/.*/"]' /etc/lvm/lvm.conf
# sed -i  "s/sdb/$BLOCK_DISK/g" /etc/lvm/lvm.conf

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$CINDER_DBPASS@$HOST_NAME/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password  $RABBIT_PASS

crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends  lvm
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://$HOST_NAME:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type  password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name  service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username  cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password  $CINDER_PASS

crudini --set /etc/cinder/cinder.conf DEFAULT my_ip $HOST_IP_NODE
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm iscsi_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm iscsi_helper lioadm

crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers  http://$HOST_NAME:9292
