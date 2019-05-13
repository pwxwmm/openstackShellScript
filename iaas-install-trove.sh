#!/bin/bash
source /etc/xiandian/openrc.sh
source /etc/keystone/admin-openrc.sh
default_network_id=

#------------------------------------------------------------------------------------------------
printf "\033[35mPlease wait...\n\033[0m"

if [[ `openstack endpoint list | grep -w 'volume' ` == '' ]];then
        printf "\033[35mPlease install the cinder service first! \n\033[0m"
        exit 1
fi

if [[ `openstack endpoint list | grep -w 'object-store' ` == '' ]];then
        printf "\033[35mPlease install the swift service first! \n\033[0m"
        exit 1
fi

if [[ `neutron net-list` == '' ]];then
        printf "\033[35mPlease create network first!\n\033[0m"
        exit 1
fi

if [[ $default_network_id == '' ]]; then
        network_mode=`cat /etc/neutron/plugin.ini |grep ^tenant_network_types |awk -F= '{print $2}'`
        if [[ $network_mode == 'flat' ]];then
                default_network_id=`neutron net-list |  sed -e '1,3d'  -e '$d' |awk '{print $2}'`
        elif [[ $network_mode == 'gre' ]];then
                # neutron net-list |  sed -e '1,3d'  -e '$d' |awk '{print $2}'
                for net_name in `neutron net-list |  sed -e '1,3d'  -e '$d' |awk '{print $2}'`;
                do
                        mode=`neutron net-show $net_name |grep "router:external"`
                        if [[ `echo $mode |grep -w "False"` !=  "" ]];then
                                default_network_id=$net_name
                                break
                        fi
                done
        # elif [[ $network_mode == 'vlan' ]] ;then
