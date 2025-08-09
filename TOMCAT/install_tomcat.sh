#!/bin/bash
set -e

# Variables from Terraform templatefile()
# ${gui_user} = Tomcat GUI admin username
# ${gui_password} = Tomcat GUI admin password
# ${script_user} = Tomcat deployer username
# ${script_password} = Tomcat deployer password

echo "===== Updating system ====="
apt-get update -y
apt-get upgrade -y

echo "===== Installing Java 21 and Tomcat 9 ====="
apt-get install -y openjdk-21-jdk tomcat9 tomcat9-admin wget curl

echo "===== Configuring Tomcat users ====="
tee /etc/tomcat9/tomcat-users.xml > /dev/null <<EOF
<tomcat-users>
    <!-- GUI user for Manager & Host Manager -->
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="${gui_user}" password="${gui_password}" roles="manager-gui,admin-gui"/>

    <!-- Script user for automated deployments -->
    <role rolename="manager-script"/>
    <user username="${script_user}" password="${script_password}" roles="manager-script"/>
</tomcat-users>
EOF

echo "===== Removing RemoteAddrValve restrictions ====="
sed -i '/RemoteAddrValve/d' /etc/tomcat9/Catalina/localhost/manager.xml || true
sed -i '/RemoteAddrValve/d' /etc/tomcat9/Catalina/localhost/host-manager.xml || true

echo "===== Setting JAVA_HOME for Tomcat 9 Service ====="
tee /etc/systemd/system/tomcat9.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"
EOF

echo "===== Reloading and Restarting Tomcat ====="
systemctl daemon-reload
systemctl restart tomcat9
systemctl enable tomcat9

echo "===== Allowing Port 8080 in UFW (if enabled) ====="
if command -v ufw &>/dev/null; then
    ufw allow 8080/tcp
fi

echo "===== Tomcat 9 Installation Complete ====="
echo "Access Tomcat Manager GUI at: http://$(curl -s ifconfig.me):8080/manager/html"
echo "GUI User: ${gui_user}"
echo "Script User: ${script_user}"
