#!/bin/bash
sudo yum install -y cronie
cat <<EOF > /opt/minecraft/server/startup.sh
#!/bin/bash
sudo /opt/minecraft/server/start
EOF
chmod +x /opt/minecraft/server/startup.sh
(crontab -l 2>/dev/null; echo "@reboot /opt/minecraft/server/startup.sh") | crontab -
