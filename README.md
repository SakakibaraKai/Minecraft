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
