#!/bin/bash
source /etc/xiandian/openrc.sh
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types  gre
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre tunnel_id_ranges  1:1000
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $INTERFACE_NAME
cat > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME <<EOF
DEVICE=$INTERFACE_NAME
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
EOF
systemctl restart network
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings  physnet1:br-ex
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini agent tunnel_types  gre
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs local_ip $HOST_IP_NODE
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs  enable_tunneling True
crudini --set  /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings external:br-ex
systemctl restart neutron-openvswitch-agent
