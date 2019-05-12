#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh

ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $INTERFACE_NAME
cat > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME <<EOF
DEVICE=$INTERFACE_NAME
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
EOF
systemctl restart network
crudini --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  physnet1
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  flat
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings  physnet1:br-ex
systemctl restart neutron-openvswitch-agent

crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router,lbaas
crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers
.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT device_driver neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDr
iver
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/lbaas_agent.ini haproxy user_group haproxy

neutron-db-manage --service lbaas upgrade head
systemctl restart neutron-server neutron-lbaas-agent
systemctl enabled neutron-server neutron-lbaas-agent


tenantID=`openstack project list | grep service | awk '{print $2}'`
echo -e "\033[31m\nCreate a sample flat network\n\033[0m "
neutron net-create --tenant-id $tenantID sharednet1 --shared --provider:network_type flat --provider:physical_network physnet1
