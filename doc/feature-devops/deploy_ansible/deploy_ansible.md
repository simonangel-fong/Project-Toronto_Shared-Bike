# Deployment: Application Deployment using Ansible

[Back](../../../README.md)

- [Deployment: Application Deployment using Ansible](#deployment-application-deployment-using-ansible)
  - [Central Configuration Repo](#central-configuration-repo)
  - [Application Deployment on App Node](#application-deployment-on-app-node)
    - [Install git and Clone codes](#install-git-and-clone-codes)

---

## Central Configuration Repo

- Skip. Same as CLI

---

## Application Deployment on App Node

### Install git and Clone codes

```sh
cat > ~/project/ansible/install_docker.yml <<EOF
---
- name: Install Docker on App Node
  hosts: application_node
  # need privilege
  become: yes
  tasks:
    - name: upgrade all packages
      dnf:
        name: "*"
        state: latest

    - name: remove the packages
      dnf:
        # package list
        name:
          - docker
          - docker-client
          - docker-client-latest
          - docker-common
          - docker-latest
          - docker-latest-logrotate
          - docker-logrotate
          - docker-engine
          - podman
          - runc
        state: absent

    - name: Install dnf plugins core
      dnf:
        name: dnf-plugins-core
        state: present

    - name: Add Docker repository
      get_url:
        url: https://download.docker.com/linux/rhel/docker-ce.repo
        dest: /etc/yum.repos.d/docker.repo

    - name: Install the latest version of Docker
      ansible.builtin.dnf:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: latest

    - name: Enable Docker service for dnf-automatic
      ansible.builtin.systemd_service:
        name: docker
        state: started
        enabled: true

    - name: Set permissions on Docker socket
      ansible.builtin.file:
        path: /var/run/docker.sock
        owner: root
        group: docker
        mode: '0666'

    - name: Run a hello-world container
      ansible.builtin.command: docker run hello-world
      register: docker_test_output

    - name: Print Docker hello-world output
      ansible.builtin.debug:
        var: docker_test_output.stdout
EOF
```

- Command

```sh
ansible-playbook -i inventory.ini install_docker.yml --ask-become
```

---
