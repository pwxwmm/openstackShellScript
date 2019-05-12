#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh

mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS nova ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS nova_api ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS' ;"

openstack user create --domain $DOMAIN_NAME --password $NOVA_PASS nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://$HOST_NAME:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://$HOST_NAME:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://$HOST_NAME:8774/v2.1/%\(tenant_id\)s

yum install -y openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler

crudini --set /etc/nova/nova.conf database connection mysql+pymysql://nova:$NOVA_DBPASS@$HOST_NAME/nova
crudini --set /etc/nova/nova.conf api_database connection mysql+pymysql://nova:$NOVA_DBPASS@$HOST_NAME/nova_api

crudini --set /etc/nova/nova.conf DEFAULT enabled_apis  osapi_compute,metadata
crudini --set /etc/nova/nova.conf DEFAULT rpc_backend  rabbit
crudini --set /etc/nova/nova.conf DEFAULT auth_strategy   keystone
crudini --set /etc/nova/nova.conf DEFAULT my_ip $HOST_IP
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf DEFAULT metadata_listen 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT metadata_listen_port 8775

crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit  rabbit_password  $RABBIT_PASS

crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$HOST_NAME:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://$HOST_NAME:35357
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name $DOMAIN_NAME
