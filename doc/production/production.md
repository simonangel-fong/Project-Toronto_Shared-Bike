# Deployment: Proxmox Installation

[Back](../../README.md)

- [Deployment: Proxmox Installation](#deployment-proxmox-installation)
  - [Network Configuration](#network-configuration)
    - [Map Wifi to Proxmox nic](#map-wifi-to-proxmox-nic)
    - [Map Jenkins](#map-jenkins)
    - [Map Grafana](#map-grafana)
  - [LVM Pre](#lvm-pre)
  - [Deploy](#deploy)
  - [Configure Cloud Sharing Resources](#configure-cloud-sharing-resources)

---

## Network Configuration

### Map Wifi to Proxmox nic

```sh
# List Filter Table
iptables -L -v -n
# NAT Table (includes MASQUERADE, DNAT, SNAT):
iptables -t nat -L -v -n

iptables-save

# Flush All Chains
iptables -F         # Flush filter table
iptables -t nat -F  # Flush NAT table
iptables -t mangle -F
iptables -t raw -F

# Delete All User-defined Chains:
iptables -X
iptables -t nat -X

# Zero All Counters
iptables -Z

netfilter-persistent save
```

- Map gateway to the wifi

```sh
# Map outgoing traffic from 192.168.10.0/24 to the Proxmox host’s Wi-Fi interface (wlp7s0).
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o wlp7s0 -j MASQUERADE
# Allows traffic from virtual bridge (vmbr0) out to the Wi-Fi (wlp7s0).
iptables -A FORWARD -i vmbr0 -o wlp7s0 -j ACCEPT
# Allows return traffic from the internet (wlp7s0) to reach virtual bridge (vmbr0)
iptables -A FORWARD -i wlp7s0 -o vmbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT

netfilter-persistent save
```

---

### Map Jenkins

- Map Jenkins GUI

```sh
# Forward incoming traffic on WIFI aadress 192.168.1.80:8080 to pfSense WAN addresss 192.168.10.100:8080
iptables -t nat -A PREROUTING -d 192.168.1.80 -p tcp --dport 8080 -j DNAT --to-destination 192.168.10.254:8080

# Allow forwarding from the source network to the target machine
iptables -A FORWARD -p tcp -d 192.168.10.254 --dport 8080 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

netfilter-persistent save
```

---

### Map Grafana

- Map Grafana GUI

```sh
# Forward incoming traffic on WIFI aadress 192.168.1.80:3000 to pfSense WAN addresss 192.168.10.100:3000
iptables -t nat -A PREROUTING -d 192.168.1.80 -p tcp --dport 3000 -j DNAT --to-destination 192.168.10.254:3000

# Allow forwarding from the source network to the target machine
iptables -A FORWARD -p tcp -d 192.168.10.254 --dport 3000 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Forward incoming traffic on WIFI aadress 192.168.1.80:9090 to pfSense WAN addresss 192.168.10.100:9090
iptables -t nat -A PREROUTING -d 192.168.1.80 -p tcp --dport 9090 -j DNAT --to-destination 192.168.10.254:9090

# Allow forwarding from the source network to the target machine
iptables -A FORWARD -p tcp -d 192.168.10.254 --dport 9090 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

netfilter-persistent save
```

---

## LVM Pre

```sh
ssh -J root@192.168.1.80 aadmin@192.168.100.100

lsblk

fdisk -l
fdisk /dev/sdb
# n: new partition
# p: primary
# 1: partition number
# Press Enter to accept default first/last sector
# w: write and exit

# # mount swap
# mkswap /dev/sdb1
# echo "UUID=uuid_number swap    swap    pri=1   0   0" >> /etc/fstab

# Create a Physical Volume on the New Disk
sudo pvcreate /dev/sdb1
# Extend the Existing Volume Group
sudo vgextend vg /dev/sdb1
# Extend the Logical Volume to Use All Free Space
sudo lvextend -l +100%FREE /dev/vg/root
# Resize the ext4 File System
sudo resize2fs /dev/vg/root

df -Th

```

## Deploy

- Upload scripts and data

```sh
# as root
# upload script and config via proxmox
ssh-keygen -R 192.168.100.100
scp -r -o ProxyJump=root@192.168.1.80 ./devops/shell ./project/config root@192.168.100.100:~
# upload compress data
scp -r -o ProxyJump=root@192.168.1.80 ./project/dpump root@192.168.100.100:~
```

- Execute deploy shell script

```sh
# login
ssh -J root@192.168.1.80 root@192.168.100.100

# as root
# initialize system
bash ~/shell/init_system.sh
# pull github
bash ~/shell/get_github.sh

bash ~/shell/get_data.sh
```

- Admin task

| Task           | Command                            |
| -------------- | ---------------------------------- |
| Refresh github | `bash ~/shell/get_github.sh`       |
| Stop services  | `bash ~/shell/stop_<con_name>.sh`  |
| Start services | `bash ~/shell/start_<con_name>.sh` |

---

## Configure Cloud Sharing Resources

```sh
# upload source data
aws s3 sync ./project/source s3://trip.arguswatcher.net/source
# confirm
aws s3 ls s3://trip-source.arguswatcher.net/source
```
