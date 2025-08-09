#!/bin/bash
set -e

echo "===== Starting Nexus Repository Manager installation ====="

# Update and install dependencies
echo "Updating packages..."
sudo apt update -y

echo "Installing required packages..."
sudo apt install -y openjdk-8-jre-headless wget tar net-tools lsb-release

# Set variables
NEXUS_VERSION="3.69.0-02"
INSTALL_DIR="/opt"
NEXUS_DIR="${INSTALL_DIR}/nexus"
NEXUS_DATA_DIR="/opt/sonatype-work/nexus3"

cd $INSTALL_DIR

# Download and extract Nexus
echo "Downloading Nexus ${NEXUS_VERSION}..."
wget "https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"

echo "Extracting Nexus..."
tar -zxvf "nexus-${NEXUS_VERSION}-unix.tar.gz"
mv "nexus-${NEXUS_VERSION}" nexus
rm "nexus-${NEXUS_VERSION}-unix.tar.gz"

# Create dedicated nexus user (if it doesn't exist)
if ! id -u nexus >/dev/null 2>&1; then
    echo "Creating nexus user..."
    sudo useradd -M -d $NEXUS_DIR -s /bin/bash nexus
fi

# Create necessary data directories
echo "Setting up Nexus data directories..."
sudo mkdir -p "$NEXUS_DATA_DIR"/{log,tmp}
sudo chown -R nexus:nexus "$NEXUS_DIR" "$NEXUS_DATA_DIR"

# Configure nexus to run as 'nexus' user
echo 'run_as_user="nexus"' | sudo tee "$NEXUS_DIR/bin/nexus.rc"

# Create systemd service
echo "Creating systemd service for Nexus..."
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=$NEXUS_DIR/bin/nexus start
ExecStop=$NEXUS_DIR/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "Enabling and starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Wait for Nexus to start up
echo "Waiting for Nexus to fully start (approx 1 min)..."
sleep 60

# Verify Nexus is running
if netstat -tlpn | grep ":8081" > /dev/null; then
    echo "Nexus is running and accessible on port 8081"
    echo "Visit: http://<your-public-ip>:8081"
    echo "Initial admin password:"
    sudo cat $NEXUS_DATA_DIR/admin.password
else
    echo "Nexus service did not start as expected. Check logs at $NEXUS_DIR/log/nexus.log"
fi
