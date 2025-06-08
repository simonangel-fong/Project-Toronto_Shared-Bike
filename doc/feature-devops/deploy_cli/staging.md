# Deployment: Application Deployment (Manual Command)

[Back](../../../README.md)

- [Deployment: Application Deployment (Manual Command)](#deployment-application-deployment-manual-command)
  - [Staging](#staging)

---

## Staging

- Upload scripts and data

```sh
# as root
# upload script and config
scp -r ./devops/shell ./project/config root@192.168.128.100:~
# upload compress data
scp -r ./project/dpump root@192.168.128.100:~
```

- Execute deploy shell script

```sh
# login
ssh -J root@192.168.1.80 root@192.168.100.100

# as root
# configure network, hostname
bash ~/shell/00_pre_deploy.sh
# install git, docker; mkdir; copy config, dpump; start cloudflare
bash ~/shell/deploy.sh
```

- Admin task

| Task           | Command                            |
| -------------- | ---------------------------------- |
| Refresh github | `bash ~/shell/refresh_github.sh`   |
| Stop services  | `bash ~/shell/stop_<con_name>.sh`  |
| Start services | `bash ~/shell/start_<con_name>.sh` |

---

Log

```sh
# install the Docker plugin and restart the Docker engine:
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
systemctl restart docker

# Verify that the plugin is installed:
docker plugin ls

# configure Docker to send logs from all containers
vi etc/docker/daemon.json
# {
#     "debug" : true,
#     "log-driver": "loki",
#     "log-opts": {
#         "loki-url": "http://192.168.128.100:3100/loki/api/v1/push"
#     }
# }

# restart the Docker service:
systemctl restart docker

# recreate your containers to start logging to Loki.
docker-compose down && docker-compose up -d --build
```