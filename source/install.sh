#!/bin/bash

# install target path
target="/opt"

# install kilo repo
cd ${target}/source && rpm -ivh centos-release-openstack-kilo-1-2.el7.noarch.rpm
cd /etc/yum.repos.d/ && rm -f * && cp ${target}/source/*.repo .
yum clean all && yum makecache fast

# install kvm and tool
yum install -y vim wget curl net-tools telnet
yum install -y qemu-kvm libvirt virt-manager virt-install libguestfs-tools

# selinux
systemctl stop firewalld.service && systemctl disable firewalld.service
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl stop iptables.service

# install openstack kilo
yum install -y openstack-nova-compute sysfsutils
yum install -y libvirt-daemon-config-nwfilter
yum install -y openstack-nova-network openstack-nova-api

# nova instances
mkdir -p ${nova_base_dir}/nova/{buckets,instances,keys,networks,tmp}
chown -R nova:nova ${nova_base_dir}/nova

# config kernel
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p

# cover source code
cp -f ${target}/source/queues/*.py /usr/lib/python2.7/site-packages/nova/virt/libvirt/
cp -f ${target}/source/vip/*.py /usr/lib/python2.7/site-packages/nova/network/

# set nova user can login
usermod -s /bin/bash nova
cd ${target}/source/resize && tar zxf ssh.tar.gz -C /var/lib/nova/ && chown -R nova:nova /var/lib/nova/.ssh/

