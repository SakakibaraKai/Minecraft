# README: Instructions on How to Start a Minecraft Server  

## Requirements
1. Fork the directory.
2. Have an AWS key. If not created, please create and upload your key on AWS.
3. Add 4 secrets. These details will be held in the GitHub repository's settings under:
   - Name: **AWS_ACCESS_KEY_ID** - Copy and paste the **AWS_ACCESS_KEY_ID** here.
   - Name: **AWS_SECRET_ACCESS_KEY** - Copy and paste the **AWS_SECRET_ACCESS_KEY** here.
   - Name: **AWS_SESSION_TOKEN** - Copy and paste the **AWS_SESSION_TOKEN** here.
   - Name: **SSH_KEY_PEM** - Paste PEM key contents here.
4. In the `terraform` directory, edit the `main.tf` file. Update the variable named `key_name` to match your created key name.
5. In the main.tf File on line 10 there should be a vpc_id locacate and find a existing vpc and copy the vpc_id as the set value.

## Steps to Connect and Start EC2 with Minecraft
1. After every main push, it will create an EC2 instance using GitHub Actions. You can find the IPv4 address to connect to in the Actions tab under the Terraform section.
2. The port number will be `25565`. It runs on Minecraft version `1.20.1`.

## Connecting to Your Minecraft Server
To connect to your Minecraft server:
1. Open Minecraft Java Edition.
2. Click on **Multiplayer**.
3. Click **Add Server**.
4. Enter any name for the server.
5. Enter the IPv4 address provided in the GitHub Actions.
6. Save and connect to your server!

## Customization
You can change the version the server is started and created on by changing the variable `MINECRAFTSERVERURL` under `script/start_mc.sh`. Newer versions may require some dependencies that are not downloaded in the pipeline.

## Security Considerations
Do not share your PEM key with anyone.

## Code explanitions
1. terraform/Main.tf - contains the main terraform file that is read. It creates a aws_security_group named minecraft with the port at ```25565``` and opens a aws ec2 instance with the name of minecraft with the existing key name in this case ```labweek6key``` please replace.
```provider "aws" {
  region = "us-west-2"
}


resource "aws_security_group" "minecraft" {
  #count       = length(data.aws_security_group.existing) == 0 ? 1 : 0
  name        = "Minecraft_Security_Group1"
  description = "Security group for minecraft server"
  vpc_id      = "vpc-0015738bfc8abd367"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami           = "ami-05a6dba9ac2da60cb"
  instance_type = "t4g.small"
  key_name      = "labweek6key"
  security_groups = [aws_security_group.minecraft.name]
  associate_public_ip_address = true

  tags = {
    Name = "minecraft_server"
  }
  #vpc_id      = "vpc-0d7050b9b79c37ac1"
  #vpc_security_group_ids = length(data.aws_security_group.existing) == 0 ? [aws_security_group.minecraft[0].id] : [data.aws_security_group.existing.id]


}```

2. terraform/output.tf - will be used to output the aws_instance public ipv4
```output "instance_ip" {
  value = aws_instance.minecraft.public_ip
}```

3. ansible/playbook.yml - This ansible playbook load 2 scripts talked about later one being the instaltion of minecraft and the second is the reboot script that run server start commands upon the ec2 instanct startup/reboot
```- name: Setup and start Minecraft server
  hosts: minecraft
  become: true

  tasks:
    - name: Copy start_minecraft.sh script to server
      ansible.builtin.copy:
        src: ../script/start_mc.sh
        dest: /home/ec2-user/start_mc.sh
        mode: '0755'

    - name: Copy reboot.sh script to server
      ansible.builtin.copy:
        src: ../script/create_reboot.sh
        dest: /home/ec2-user/create_reboot.sh
        mode: '0755'
        
    - name: Run start_minecraft.sh script
      ansible.builtin.shell: /home/ec2-user/start_mc.sh
      args:
        executable: /bin/bash

    - name: Run create_reboot script
      ansible.builtin.shell: /home/ec2-user/create_reboot.sh
      args:
        executable: /bin/bash```

4. script/start_mc.sh - this script was developed and used by the previous developer to install minecraft to ec2 along will installing the nessesary java to aws for minecraft to run. To change the version you may change the ```MINECRAFTSERVERURL``` url to match a version of minecraft you wish to use.
```#!/bin/bash

# *** INSERT SERVER DOWNLOAD URL BELOW ***
# Do not add any spaces between your link and the "=", otherwise it won't work. EG: MINECRAFTSERVERURL=https://urlexample


MINECRAFTSERVERURL=https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar


# Download Java
sudo yum install -y java-17-amazon-corretto-headless
# Install MC Java server in a directory we create
adduser minecraft
mkdir /opt/minecraft/
mkdir /opt/minecraft/server/
cd /opt/minecraft/server

# Download server jar file from Minecraft official website
wget $MINECRAFTSERVERURL

# Generate Minecraft server files and create script
chown -R minecraft:minecraft /opt/minecraft/
java -Xmx1300M -Xms1300M -jar server.jar nogui
sleep 40
sed -i 's/false/true/p' eula.txt
touch start
printf '#!/bin/bash\njava -Xmx1300M -Xms1300M -jar server.jar nogui\n' >> start
chmod +x start
sleep 1
touch stop
printf '#!/bin/bash\nkill -9 $(ps -ef | pgrep -f "java")' >> stop
chmod +x stop
sleep 1

# Create SystemD Script to run Minecraft server jar on reboot
cd /etc/systemd/system/
touch minecraft.service
printf '[Unit]\nDescription=Minecraft Server on start up\nWants=network-online.target\n[Service]\nUser=minecraft\nWorkingDirectory=/opt/minecraft/server\nExecStart=/opt/minecraft/server/start\nStandardInput=null\n[Install]\nWantedBy=multi-user.target' >> minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service

# End script```

5. script/create_reboot.sh - this script installs and creates a crontab on the ec2 instace to trigger auto restart upon ec2 launch or reboot.
```#!/bin/bash
sudo yum install -y cronie
cat <<EOF > /opt/minecraft/server/startup.sh
#!/bin/bash
sudo /opt/minecraft/server/start
EOF
chmod +x /opt/minecraft/server/startup.sh
(crontab -l 2>/dev/null; echo "@reboot /opt/minecraft/server/startup.sh") | crontab -```
