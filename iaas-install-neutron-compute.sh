#!/bin/bash
source /etc/xiandian/openrc.sh

yum install openstack-neutron-linuxbridge ebtables ipset openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch -y
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $HOST_NAME
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USER
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password  $RABBIT_PASS

crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin  ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins  router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips  True

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri  http://$HOST_NAME:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url  http://$HOST_NAME:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers  $HOST_NAME:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type  password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name  $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name $DOMAIN_NAME
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name  service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username  neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password  $NEUTRON_PASS

crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path  /var/lib/neutron/tmp

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers  flat,vlan,gre,vxlan,local
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers  openvswitch,l2population
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers  port_security

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset  True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group true
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver iptables_hybrid

crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population True
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini agent prevent_arp_spoofing True
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs integration_bridge br-int
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup  firewall_driver iptables_hybrid

crudini --set  /etc/nova/nova.conf neutron  url  http://$HOST_NAME:9696
