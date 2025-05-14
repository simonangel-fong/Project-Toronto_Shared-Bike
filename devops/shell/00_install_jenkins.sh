#!/bin/bash

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
# Add required dependencies for the jenkins package
sudo yum install -y fontconfig java-17-openjdk
sudo yum install -y jenkins

# sudo update-alternatives --config java
sudo systemctl daemon-reload

sudo systemctl enable --now jenkins

# sudo systemctl status jenkins

sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload