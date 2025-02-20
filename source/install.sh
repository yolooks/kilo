#!/bin/bash

public_url="http://keystone-public-hk.itigerinner.com"
admin_url="http://keystone-admin-hk.itigerinner.com"
rabbit_addrs="10.9.70.28:5672,10.9.70.29:5672,10.9.70.30:5672"
rabbit_pass="rml0CN6UqojQIhwn"
local_ip="10.9.8.27"
controll_vip="10.9.8.251"
nova_base_dir="/data0"
network_size=254
default_vlan_id=16
interface="bond1"
cpu_max_num=47

# install target path
target="/data0"

cd ${target}/source && rpm -q centos-release-openstack-kilo-1-2.el7.noarch || rpm -ivh centos-release-openstack-kilo-1-2.el7.noarch.rpm
cd /etc/yum.repos.d/ && rm -f * && cp ${target}/source/*.repo .
yum clean all && yum makecache fast

yum install -y vim wget curl net-tools telnet
yum install -y qemu-kvm libvirt qemu-kvm-tools libcgroup-tools virt-manager virt-install libguestfs-tools bash-completion.noarch

systemctl stop firewalld.service && systemctl disable firewalld.service
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0 || true
systemctl stop iptables.service || true

yum install -y openstack-nova-compute sysfsutils
yum install -y libvirt-daemon-config-nwfilter
yum install -y openstack-nova-network openstack-nova-api

if [ -f /etc/nova/nova.conf ]; then
    rm -f /etc/nova/nova.conf
fi
/bin/cp -f ${target}/source/nova.conf /etc/nova/nova.conf

sed -i "s@%KEYSTONE_PUBLIC_URL%@${public_url}@g" /etc/nova/nova.conf
sed -i "s@%KEYSTONE_ADMIN_URL%@${admin_url}@g" /etc/nova/nova.conf

sed -i "s/%RABBIT_ADDRS%/${rabbit_addrs}/g" /etc/nova/nova.conf
sed -i "s/%RABBIT_PASS%/${rabbit_pass}/g" /etc/nova/nova.conf

sed -i "s/%LOCAL_IP%/${local_ip}/g" /etc/nova/nova.conf
sed -i "s/%CONTROLL_VIP%/${controll_vip}/g" /etc/nova/nova.conf

mkdir -p ${nova_base_dir}/nova/{buckets,instances,keys,networks,tmp}

chown -R nova:nova ${nova_base_dir}

sed -i "s@%NOVA_BASE_DIR%@${nova_base_dir}@g" /etc/nova/nova.conf
sed -i "s/%CPU_MAX_NUM%/${cpu_max_num}/g" /etc/nova/nova.conf

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p

sed -i "s/%NETWORK_SIZE%/${network_size}/g" /etc/nova/nova.conf
sed -i "s/%DEFAULT_VLAN_ID%/${default_vlan_id}/g" /etc/nova/nova.conf
sed -i "s/%INTERFACE%/${interface}/g" /etc/nova/nova.conf

chown root:nova /etc/nova/nova.conf

cp -f ${target}/source/queues/*.py /usr/lib/python2.7/site-packages/nova/virt/libvirt/
cp -f ${target}/source/vip/*.py /usr/lib/python2.7/site-packages/nova/network/

usermod -s /bin/bash nova
cd ${target}/source/resize && tar zxf ssh.tar.gz -C /var/lib/nova/ && chown -R nova:nova /var/lib/nova/.ssh/

