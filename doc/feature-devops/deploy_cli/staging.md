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
