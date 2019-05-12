#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh

mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS neutron ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_DBPASS' ;"

openstack user create --domain $DOMAIN_NAME --password $NEUTRON_PASS neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://$HOST_NAME:9696
openstack endpoint create --region RegionOne network internal http://$HOST_NAME:9696
openstack endpoint create --region RegionOne network admin http://$HOST_NAME:9696

yum install -y openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables  openstack-neutron-openvswitch  openstack-neutron-l
baas python-neutron-lbaas haproxy  openstack-neutron-fwaas
crudini --set /etc/neutron/neutron.conf database connection  mysql://neutron:$NEUTRON_DBPASS@$HOST_NAME/neutron
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password  $RABBIT_PASS

crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin  ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins  router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips  True

crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://$HOST_NAME:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $NEUTRON_PASS

crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes  True
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes  True
crudini --set /etc/neutron/neutron.conf  nova auth_url  http://$HOST_NAME:35357
crudini --set /etc/neutron/neutron.conf  nova auth_type  password
