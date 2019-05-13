#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh

mongo $HOST_NAME/ceilometer --eval "db.addUser({user: 'ceilometer', pwd: '$CEILOMETER_DBPASS', roles: [ 'readWrite', 'dbAdmin' ]})"
while [ $? -ne 0 ]
do
sleep 10
mongo $HOST_NAME/ceilometer --eval "db.addUser({user: 'ceilometer', pwd: '$CEILOMETER_DBPASS', roles: [ 'readWrite', 'dbAdmin' ]})"
done

openstack user create --domain $DOMAIN_NAME --password $CEILOMETER_PASS ceilometer
openstack role add --project service --user ceilometer admin
openstack service create --name ceilometer --description "Telemetry" metering
openstack endpoint create --region RegionOne metering public http://$HOST_NAME:8777
openstack endpoint create --region RegionOne metering internal http://$HOST_NAME:8777
openstack endpoint create --region RegionOne metering admin http://$HOST_NAME:8777

openstack role create ResellerAdmin
openstack role add --project service --user ceilometer ResellerAdmin

yum install -y openstack-ceilometer-api openstack-ceilometer-collector openstack-ceilometer-notification openstack-ceilometer-central p
ython-ceilometerclient python-ceilometermiddleware

crudini --set /etc/ceilometer/ceilometer.conf database connection  mongodb://ceilometer:$CEILOMETER_DBPASS@$HOST_NAME:27017/ceilometer
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
