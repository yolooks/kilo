# OpenStack Kilo

## Ansible Installation

```
ansible-playbook kilo.yaml -i ip, -e @vars.yaml
```

## NOTES

说明: 只能一个节点一个节点安装, 不支持批量机器安装。
- vars.yaml里需要配置local_ip
- 可能每个宿主机的核数、或者网卡配置不一样

## Example vars.yaml

```
nova: "all"                                                     # 默认配置, 不用修改
source_path: "/home/lhsa/kilo"                                  # 当前ansible kilo.yaml所在目录
public_url: "http://keystone-public-hk.itigerinner.com"         # keystone public auth url 
admin_url: "http://keystone-admin-hk.itigerinner.com"           # keystone admin auth url
rabbit_addrs: "10.9.70.28:5672,10.9.70.29:5672,10.9.70.30:5672" # rabbitmq cluster addr
rabbit_pass: "rml0CN6UqojQIhwn"                                 # rabbitmq openstack account's password
local_ip: "10.9.8.27"                                           # 当前部署计算节点的ip
controll_vip: "10.9.8.251"                                      # 控制节点的虚IP
nova_base_dir: "/data0"                                         # 当前部署计算节点存放虚拟机的目录
network_size: 254                                               # 当前vlan cidr ip数量
default_vlan_id: 16                                             # 默认vlan id
interface: "bond1"                                              # 当前部署的计算节点的网卡
cpu_max_num: 47                                                 # lscpu查看的最大值 如: 0-47 取47
```

## Install

```
ansible-playbook kilo.yaml -i 10.9.8.27, -e @vars.yaml
```
