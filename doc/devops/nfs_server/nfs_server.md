# NFS Server

### Server

- Monitor node

```sh
sudo dnf install nfs-utils -y
sudo systemctl enable --now nfs-server rpcbind

sudo systemctl status nfs-server

```

- Create and Configure the Export Directory

```sh
sudo mkdir -p /srv/nfs_share
sudo chown nobody:nobody -R /srv/nfs_share
sudo chmod 755 /srv/nfs_share

echo "/srv/nfs_share 192.168.1.0/24(rw,sync,no_root_squash)" | sudo tee -a /etc/exports

# Export the Share
sudo exportfs -rav

```

- Adjust the Firewall

```sh
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload

sudo exportfs -v
```
