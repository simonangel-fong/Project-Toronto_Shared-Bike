# Jenkins

[Back](../../../README.md)

- [Jenkins](#jenkins)
  - [Jenkins](#jenkins-1)
  - [`oracledb` Branch Pipeline](#oracledb-branch-pipeline)

## Jenkins

- Monitor Node

```sh
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
# Add required dependencies for the jenkins package
sudo yum install -y fontconfig java-17-openjdk
sudo yum install -y jenkins

sudo update-alternatives --config java
sudo systemctl daemon-reload

sudo systemctl enable --now jenkins

sudo systemctl status jenkins

sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

- http://192.168.128.100:8080/

---

## `oracledb` Branch Pipeline

- https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git

```js
pipeline {
    agent any

    environment {
        COMPOSE_PATH = "oracledb/compose.oracledb.prod.yaml"
        ORACLE_CONTAINER_NAME = "oracle19cDB"
        PDB_NAME = "TORONTO_SHARED_BIKE"
    }

    triggers {
        pollSCM('H/5 * * * *') // Poll every 5 minutes; replace with webhook if preferred
    }

    options {
        timeout(time: 15, unit: 'MINUTES') // Global timeout
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'feature-oracledb', url: 'https://github.com/simonangel-fong/Project-Toronto_Shared-Bike.git'
            }
        }

        stage('Start Oracle DB Container') {
            steps {
                sh "docker-compose -f ${COMPOSE_PATH} down || true"
                sh "docker-compose -f ${COMPOSE_PATH} up -d"
            }
        }

        stage('Wait for Oracle to be Healthy') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            def health = sh(
                                script: "docker inspect --format='{{.State.Health.Status}}' ${ORACLE_CONTAINER_NAME}",
                                returnStdout: true
                            ).trim()
                            echo "Oracle container health: ${health}"
                            return (health == 'healthy')
                        }
                    }
                }
            }
        }

        stage('Check Oracle PDB') {
            steps {
                script {
                    def sqlOutput = sh(
                        script: """
                            docker exec ${ORACLE_CONTAINER_NAME} bash -c \\
                            "echo \\"SELECT name FROM v\\\$pdbs WHERE name = '${PDB_NAME}';\\" | \\
                            sqlplus -S sys/\\\$(cat /run/secrets/orcl_sys_token)@ORCLCDB as sysdba"
                        """,
                        returnStdout: true
                    ).trim()

                    if (!sqlOutput.contains("${PDB_NAME}")) {
                        error("❌ PDB '${PDB_NAME}' not found in Oracle DB!")
                    } else {
                        echo "✅ PDB '${PDB_NAME}' exists and is ready."
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up Docker containers...'
            sh "docker-compose -f ${COMPOSE_PATH} down"
        }
    }
}
```
