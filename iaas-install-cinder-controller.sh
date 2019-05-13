#!/bin/bash
yum install -y openstack-cinder
sed -i -e 's/\"consistencygroup:create\" : \"group:nobody\"/"consistencygroup:create" : ""/g' \
-e 's/\"consistencygroup:delete\": \"group:nobody\"/\"consistencygroup:delete\": \"\"/g' \
-e 's/\"consistencygroup:update\": \"group:nobody\"/\"consistencygroup:update\": \"\"/g' \
-e  's/\"consistencygroup:get\": \"group:nobody\"/\"consistencygroup:get\": \"\"/g' \
-e  's/\"consistencygroup:get_all\": \"group:nobody\"/\"consistencygroup:get_all\": \"\"/g' \
-e  's/\"consistencygroup:create_cgsnapshot" \: \"group:nobody\"/\"consistencygroup:create_cgsnapshot" \: \"\"/g' \
-e  's/\"consistencygroup:delete_cgsnapshot\": \"group:nobody\"/\"consistencygroup:delete_cgsnapshot\": \"\"/g'  \
-e 's/\"consistencygroup:get_cgsnapshot\": \"group:nobody\"/\"consistencygroup:get_cgsnapshot\": \"\"/g' \
-e 's/\"consistencygroup:get_all_cgsnapshots\": \"group:nobody\"/\"consistencygroup:get_all_cgsnapshots\": \"\"/g' /etc/cinder/policy.j
son
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS cinder ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS' ;"
openstack user create --domain $DOMAIN_NAME --password $CINDER_PASS cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack endpoint create --region RegionOne volume public http://$HOST_NAME:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://$HOST_NAME:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://$HOST_NAME:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 public http://$HOST_NAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://$HOST_NAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://$HOST_NAME:8776/v2/%\(tenant_id\)s

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$CINDER_DBPASS@$HOST_NAME/cinder
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password  $RABBIT_PASS

crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url  http://$HOST_NAME:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
