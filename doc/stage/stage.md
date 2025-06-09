# Deployment: Application Deployment (Manual Command)

[Back](../../README.md)

- [Deployment: Application Deployment (Manual Command)](#deployment-application-deployment-manual-command)
  - [Staging](#staging)
  - [Grafana](#grafana)

---

## Staging

- Upload scripts and data

```sh
# as root
# upload script and config
ssh-keygen -R 192.168.100.100
scp -r ./devops/shell ./project/config root@192.168.100.100:~
# upload compress data
scp -r ./project/dpump root@192.168.100.100:~
```

- Execute deploy shell script

```sh
# login
ssh root@192.168.100.100

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
cat > /etc/docker/daemon.json <<EOF
{
    "debug" : true,
    "log-driver": "loki",
    "log-opts": {
        "loki-url": "http://192.168.100.100:3100/loki/api/v1/push"
    }
}
EOF

# restart the Docker service:
systemctl restart docker

# recreate your containers to start logging to Loki.
docker compose down && docker compose up -d --build
```

---

## Grafana

1860: Node Exporter Full
21361: Docker - cAdvisor Compute Resources