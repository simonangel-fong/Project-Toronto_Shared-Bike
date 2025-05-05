# Backup & Recovery

[Back](../../../../README.md)

---

## Backup

---

## Recovery

```sh
scp ./* aadmin@192.168.128.10:/project/local/orabackup
```


```sh
rman TARGET /
CATALOG START WITH '/project/orabackup' NOPROMPT;
SET DBID <your_dbid>;
STARTUP NOMOUNT;
RESTORE SPFILE FROM '/project/orabackup/<spfile_backup_piece>';
```