#/bin/bash
source /etc/xiandian/openrc.sh
cat <<- EOF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Please confirm whether or not to clear all data in the system      !!
!!                    Please careful operation                        !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
printf "\033[35mPlease Confirm : yes or no !\n\033[0m"
read ans
while [[ "x"$ans != "xyes" && "x"$ans != "xno" ]]
do
    echo "yes or no"
        read ans
done
if [ "$ans" = no ]; then
exit 1
fi


printf "\033[35mPlease wait ...\n\033[0m"
openstack-service stop   >/dev/null 2>&1
source  /etc/keystone/admin-openrc.sh  >/dev/null 2>&1
for i in `nova list | sed -e '1,3d' -e '$d' |awk '{print $2}'`;do nova delete $i;done >/dev/null 2>&1
for i in `virsh  list  |grep running  |awk '{print $2}'`;do virsh destroy  $i;done >/dev/null 2>&1
for i in `virsh  list --all  | grep -w '-' |awk '{print $2}' `;do virsh undefine $i;done >/dev/null 2>&1
systemctl stop mariadb-server rabbitmq-server openvswitch   >/dev/null 2>&1

if [[ `vgs |grep cinder-volumes` != '' ]];then
        for i in `lvs |grep volume |awk '{print $1}'`; do
        lvremove -f /dev/cinder-volumes/$i
        done
        vgremove -f cinder-volumes
        pvremove -f /dev/$BLOCK_DISK
fi
