#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh
yum install openstack-swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware memcached -y

openstack user create --domain $DOMAIN_NAME --password $SWIFT_PASS swift
openstack role add --project service --user swift admin
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne object-store public http://$HOST_NAME:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store internal http://$HOST_NAME:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store admin http://$HOST_NAME:8080/v1

cat <<EOF > /etc/swift/proxy-server.conf
[DEFAULT]
bind_port = 8080
swift_dir = /etc/swift
user = swift
[pipeline:main]
pipeline = catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quota
s account-quotas slo dlo versioned_writes proxy-logging proxy-server
[app:proxy-server]
use = egg:swift#proxy
account_autocreate = True
[filter:tempauth]
use = egg:swift#tempauth
user_admin_admin = admin .admin .reseller_admin
user_test_tester = testing .admin
user_test2_tester2 = testing2 .admin
user_test_tester3 = testing3
user_test5_tester5 = testing5 service
[filter:authtoken]
paste.filter_factory = keystonemiddleware.auth_token:filter_factory
auth_uri = http://$HOST_NAME:5000
auth_url = http://$HOST_NAME:35357
memcached_servers = $HOST_NAME:11211
auth_type = password
project_domain_name = $DOMAIN_NAME
user_domain_name = $DOMAIN_NAME
