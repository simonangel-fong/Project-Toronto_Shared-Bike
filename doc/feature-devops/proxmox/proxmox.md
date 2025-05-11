# Deployment: Proxmox Installation

[Back](../../../README.md)

- [Deployment: Proxmox Installation](#deployment-proxmox-installation)
  - [Test deploy](#test-deploy)

---




---

## Test deploy

```sh
git clone -b feature-oracledb https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git .

docker compose -f compose.oracledb.prod.yaml up --build -d

docker exec -it oracle19cDB bash

```
