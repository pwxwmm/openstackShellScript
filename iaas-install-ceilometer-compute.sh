#!/bin/bash
source /etc/xiandian/openrc.sh
yum install openstack-ceilometer-compute python-ceilometerclient python-pecan -y

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend rabbit
crudini --set /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/ceilometer/ceilometer.conf oslo_messaging_rabbit rabbit_password  $RABBIT_PASS

crudini --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy keystone
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_url  http://$HOST_NAME:35357
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_type  password
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken project_name  service
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken username  ceilometer
crudini --set /etc/ceilometer/ceilometer.conf keystone_authtoken password  $CEILOMETER_PASS

crudini --set /etc/ceilometer/ceilometer.conf service_credentials auth_type  password
crudini --set /etc/ceilometer/ceilometer.conf service_credentials auth_url  http://$HOST_NAME:5000/v3
crudini --set /etc/ceilometer/ceilometer.conf service_credentials project_domain_name  $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials user_domain_name  $DOMAIN_NAME
crudini --set /etc/ceilometer/ceilometer.conf service_credentials project_name  service
crudini --set /etc/ceilometer/ceilometer.conf service_credentials username  ceilometer
crudini --set /etc/ceilometer/ceilometer.conf service_credentials password  $CEILOMETER_PASS
crudini --set /etc/ceilometer/ceilometer.conf service_credentials interface  internalURL
crudini --set /etc/ceilometer/ceilometer.conf service_credentials region_name  RegionOne

crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit  True
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period  hour
crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change  vm_and_task_state
crudini --set /etc/nova/nova.conf DEFAULT notification_driver  messagingv2

systemctl enable openstack-ceilometer-compute.service
systemctl restart openstack-ceilometer-compute.service
systemctl restart openstack-nova-compute.service
