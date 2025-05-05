# Proxmox Installation

[Back](../../../README.md)

- [Proxmox Installation](#proxmox-installation)
  - [Monitor Node](#monitor-node)
  - [Application Node](#application-node)

---

## Monitor Node

| Path                               | Description                           |
| ---------------------------------- | ------------------------------------- |
| `/project/share/`                  | Dir to share files                    |
| `/project/share/config/oraenv/`    | Environment Files for Oracle Database |
| `/project/share/config/aipenv/`    | Environment Files for API             |
| `/project/share/orcldb/orabackup/` | Oracle DB remote backup files         |

---

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.10/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname monitor-host
sudo cat <<EOF >> /etc/hosts
192.168.128.10      monitor-host
127.0.0.1           monitor-host
EOF

# monitor node file
# local dir
sudo mkdir -pv /project/local/orcldb/orabackup/
sudo mkdir -pv /project/local/orcldb/oradata/

sudo chmod 755 -R /project
```

---

## Application Node

| App Path                           | NFS Path                           | Description                           |
| ---------------------------------- | ---------------------------------- | ------------------------------------- |
| `/project/share/`                  | `/project/share/`                  | Dir to share files                    |
| `/project/share/config/oraenv/`    | `/project/share/config/oraenv/`    | Environment Files for Oracle Database |
| `/project/share/config/aipenv/`    | `/project/share/config/aipenv/`    | Environment Files for API             |
| `/project/share/orcldb/orabackup/` | `/project/share/orcldb/orabackup/` | Oracle DB backup files                |
| `/project/share/data/`             | `/project/share/data/`             | Source Data                           |

| App Path                           | Description                  |
| ---------------------------------- | ---------------------------- |
| `/project/local/`                  | Dir of local files           |
| `/project/local/orcldb/oradata/`   | Oracle DB local data files   |
| `/project/local/orcldb/orabackup/` | Oracle DB local backup files |

```sh
# setup network
sudo nmcli c down ens160
sudo nmcli c modify ens160 ipv4.method manual
sudo nmcli c modify ens160 ipv4.address 192.168.128.100/24
sudo nmcli c modify ens160 ipv4.gateway 192.168.128.2
sudo nmcli c modify ens160 ipv4.dns 8.8.8.8
sudo nmcli c up ens160

# configure hostname
sudo hostnamectl set-hostname application-node
sudo cat <<EOF >> /etc/hosts
192.168.128.10      application-node
127.0.0.1           application-node
EOF
```

- Install Docker

```sh
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

sudo docker run hello-world

sudo usermod -aG docker jenkins

sudo chown root:docker /var/run/docker.sock

sudo chmod 666 /var/run/docker.sock
```

git clone -b feature-oracledb https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git .