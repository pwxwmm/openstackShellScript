#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS aodh ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'localhost' IDENTIFIED BY '$AODH_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'%' IDENTIFIED BY '$AODH_DBPASS' ;"

openstack user create --domain $DOMAIN_NAME --password $AODH_PASS aodh
openstack role add --project service --user aodh admin
openstack service create --name aodh --description "Telemetry" alarming
openstack endpoint create --region RegionOne alarming public http://$HOST_NAME:8042
openstack endpoint create --region RegionOne alarming internal http://$HOST_NAME:8042
openstack endpoint create --region RegionOne alarming admin http://$HOST_NAME:8042

yum install -y openstack-aodh-api openstack-aodh-evaluator openstack-aodh-notifier openstack-aodh-listener openstack-aodh-expirer pytho
n-ceilometerclient

crudini --set /etc/aodh/aodh.conf database connection mysql+pymysql://aodh:$AODH_DBPASS@$HOST_NAME/aodh
crudini --set /etc/aodh/aodh.conf DEFAULT rpc_backend rabbit
crudini --set /etc/aodh/aodh.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/aodh/aodh.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/aodh/aodh.conf oslo_messaging_rabbit rabbit_password  $RABBIT_PASS

crudini --set /etc/aodh/aodh.conf DEFAULT auth_strategy keystone
crudini --set /etc/aodh/aodh.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/aodh/aodh.conf keystone_authtoken auth_url  http://$HOST_NAME:35357
crudini --set /etc/aodh/aodh.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/aodh/aodh.conf keystone_authtoken auth_type  password
crudini --set /etc/aodh/aodh.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf keystone_authtoken project_name  service
crudini --set /etc/aodh/aodh.conf keystone_authtoken username  aodh
crudini --set /etc/aodh/aodh.conf keystone_authtoken password  $AODH_PASS

crudini --set /etc/aodh/aodh.conf service_credentials auth_type  password
crudini --set /etc/aodh/aodh.conf service_credentials auth_url  http://$HOST_NAME:5000/v3
crudini --set /etc/aodh/aodh.conf service_credentials project_domain_name  $DOMAIN_NAME
crudini --set /etc/aodh/aodh.conf service_credentials user_domain_name  $DOMAIN_NAME
