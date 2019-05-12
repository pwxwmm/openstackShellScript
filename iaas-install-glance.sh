#!/bin/bash
source /etc/xiandian/openrc.sh
source  /etc/keystone/admin-openrc.sh
mysql -uroot -p$DB_PASS -e "create database IF NOT EXISTS glance ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS' ;"
mysql -uroot -p$DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DBPASS' ;"
yum install -y openstack-glance
openstack user create --domain $DOMAIN_NAME --password $GLANCE_PASS glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://$HOST_NAME:9292
openstack endpoint create --region RegionOne image internal http://$HOST_NAME:9292
openstack endpoint create --region RegionOne image admin http://$HOST_NAME:9292

crudini --set /etc/glance/glance-api.conf database connection  mysql+pymysql://glance:$GLANCE_DBPASS@$HOST_NAME/glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$HOST_NAME:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://$HOST_NAME:35357
crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken password $GLANCE_PASS
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf paste_deploy config_file  /usr/share/glance/glance-api-dist-paste.ini
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store $DOMAIN_NAME'_store' file
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

crudini --set /etc/glance/glance-registry.conf database connection  mysql+pymysql://glance:$GLANCE_DBPASS@$HOST_NAME/glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://$HOST_NAME:5000
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://$HOST_NAME:35357
crudini --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers $HOST_NAME:11211
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name $DOMAIN_NAME
crudini --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken password $GLANCE_PASS
crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-registry.conf paste_deploy config_file  /usr/share/glance/glance-registry-dist-paste.ini
