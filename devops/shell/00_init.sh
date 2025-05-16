#!/bin/bansh

# run as root

echo
echo "========================================================"
echo "Upgrading packages"
echo "========================================================"
echo

sudo dnf upgrade -y

echo
echo "========================================================"
echo "Installing packages: git"
echo "========================================================"
echo

sudo dnf install -y git

echo
echo "========================================================"
echo "Installing Jenkins packages"
echo "========================================================"
echo

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

echo
echo "========================================================"
echo "Installing Docker packages"
echo "========================================================"
echo

sudo dnf remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    podman \
    runc

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

# as common user
# enable current user to run docker
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo chmod 666 /var/run/docker.sock

# as common user
# confirm as current user
echo "Current user as: $USER"
su - $USER -c "docker run hello-world"

echo
echo "========================================================"
echo "Creating dir for project"
echo "========================================================"
echo

sudo mkdir -pv /project
sudo chown jenkins:jenkins -Rv /project

echo
echo "========================================================"
echo "Jenkins credential"
echo "========================================================"
echo

sudo cat /var/lib/jenkins/secrets/initialAdminPassword