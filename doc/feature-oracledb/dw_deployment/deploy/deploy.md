# Deploy

[Back](../../../../README.md)

---

##

- Oracle

```sh
# env file
scp ./* aadmin@192.168.128.10:/project/share/config/oraenv/

# data
scp -r . root@192.168.128.10:/project/share/data
```

- Create volume dir

```sh
sudo mkdir -pv /project/local/oradata
sudo mkdir -pv /project/local/orabackup
sudo mkdir -pv /project/share/orabackup
sudo mkdir -pv /project/share/data

sudo chown nobody:nobody -R /project/share
```
