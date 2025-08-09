#!/bin/bash
set -e

# Ensure script is ran by root
if [ "$EUID" -ne 0 ]; then
        echo "please run as root"
        exit
fi


# Variables from Terraform
user="${user}"
password="${password}"

echo "===== Backing up sysctl config ====="
cp /etc/sysctl.conf /root/sysctl.conf_backup

echo "===== Setting kernel limits ====="
cat <<EOF | tee /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
EOF
sysctl -p
ulimit -n 65536
ulimit -u 4096

echo "===== Installing Java 21 ====="
apt update -y
apt install -y openjdk-21-jdk zip curl wget unzip gnupg

echo "===== Installing PostgreSQL 16 ====="
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  > /etc/apt/sources.list.d/pgdg.list
apt update -y
apt install -y postgresql-16 postgresql-contrib

systemctl enable postgresql
systemctl start postgresql
sleep 5
echo "postgres:admin123" | chpasswd

echo "===== Creating PostgreSQL user and DB for SonarQube ====="
sudo -u postgres psql -c "DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$user') THEN
      CREATE ROLE $user LOGIN PASSWORD '$password';
   END IF;
END
\$\$;"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER $user;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO $user;"

echo "===== Downloading and Installing SonarQube ====="
mkdir -p /opt/sonarqube
cd /opt
curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.8.0.112029.zip
unzip -o sonarqube-25.8.0.112029.zip
mv sonarqube-25.8.0.112029/* /opt/sonarqube/


echo "===== Configuring SonarQube user ====="
groupadd sonar || true
useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar || true
chown -R sonar:sonar /opt/sonarqube

echo "===== Setting SonarQube environment variables persistently ====="
cat <<EOF > /etc/profile.d/sonarqube.sh
export SONARQUBE_HOME=/opt/sonarqube
export PATH=\$PATH:\$SONARQUBE_HOME/bin/linux-x86-64
EOF
chmod +x /etc/profile.d/sonarqube.sh

echo "===== Updating sonar.properties ====="
cat <<EOF > /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=$user
sonar.jdbc.password=$password
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOF
chown sonar:sonar /opt/sonarqube/conf/sonar.properties

echo "===== Creating systemd service for SonarQube ====="
cat <<EOF > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target postgresql.service

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
Environment=SONARQUBE_HOME=/opt/sonarqube

[Install]
WantedBy=multi-user.target
EOF

echo "===== Starting SonarQube service ====="
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

echo "===== Opening firewall port 9000 (if UFW enabled) ====="
ufw allow 9000/tcp || true

echo "===== SonarQube installation complete ====="
echo "Access SonarQube at: http://$(curl -s ifconfig.me):9000"
