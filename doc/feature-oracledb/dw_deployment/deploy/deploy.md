# Toronto Shared Bike Data Analysis: Deployment

[Back](../../../../README.md)

- [Toronto Shared Bike Data Analysis: Deployment](#toronto-shared-bike-data-analysis-deployment)
  - [Migrate Source Data and Configuration Files](#migrate-source-data-and-configuration-files)
    - [Migrate Command](#migrate-command)

---

## Migrate Source Data and Configuration Files

- Configuration File

| Component | Configuration File | Production Path                 | Description                    |
| --------- | ------------------ | ------------------------------- | ------------------------------ |
| Oracle DB | `*.csv`            | `/project/share/data`           | Source Data                    |
| Oracle DB | `orcl.env`         | `/project/share/config/oraenv/` | Environment file for Oracle DB |
| Oracle DB | `orcl_sys_token`   | `/project/share/config/oraenv/` | Token for SYS                  |

---

### Migrate Command

```sh
# data
scp -r . root@192.168.128.10:/project/share/data

# oracle env file
scp ./* aadmin@192.168.128.10:/project/share/config/oraenv/


```

- Create volume dir

```sh
sudo mkdir -pv /project/local/oradata
sudo mkdir -pv /project/local/orabackup
sudo mkdir -pv /project/share/orabackup
sudo mkdir -pv /project/share/data

sudo chown nobody:nobody -R /project/share
```
