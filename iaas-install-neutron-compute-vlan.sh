#!/bin/bash
source /etc/xiandian/openrc.sh
crudini --set  /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks  physnet1
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vlan
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges physnet1:$minvlan:$maxvlan
crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini securitygroup firewall_driver iptables_hybrid

crudini --set  /etc/neutron/l3_agent.ini DEFAULT  external_network_bridge  br-ex
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings  physnet1:br-ex

ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $INTERFACE_NAME
cat > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME <<EOF
DEVICE=$INTERFACE_NAME
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
EOF

systemctl restart network
systemctl restart neutron-openvswitch-agent
