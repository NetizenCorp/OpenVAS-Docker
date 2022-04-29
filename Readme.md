![Netizen Logo](https://www.netizen.net/assets/img/netizen_banner_cybersecure_small.png)

Visit out Website: https://www.netizen.net

# Remote OpenVAS Docker Image
### Latest Version: 21.4.4

This image is designed for use with our GVM image located here: [GVM-Docker](https://github.com/NetizenCorp/GVM-Docker). This image is backwards compatiable with 21.4.0-3. Information on setting up can be retrieved by emailing info@netizen.net.

## Installation
First, install docker and docker-compose on your linux system. After installation, apply permissions to a user(s) that will use docker.
```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker ${USER}
```
Next, create a directory and download the docker-compose.yml file from github
```bash
mkdir /home/$USER/docker/gvm-docker
cd /home/$USER/docker/gvm-docker
wget https://raw.githubusercontent.com/NetizenCorp/GVM-Docker/main/docker-compose.yml
```
Next, you will modify the docker-compose.yml file using your preferred editor (nano or vim)
```bash
nano docker-compose.yml
```
Edit the yml file with your preferences.
```bash
version: "3.1"
services:
    gvm:
        image: netizensoc/openvas-scanner:[latest|dev] # Latest is the stable image. Dev is the development un-stable image
        volumes:
          - scanner:/data               # DO NOT MODIFY
        environment:
          - MASTER_ADDRESS=[Enter IP]   # IP or Hostname of the GVM container. Remove brackets
          - MASTER_PORT=2222            # SSH server port from the GVM container
        restart: unless-stopped # Remove if your using for penetration testing or one-time scans. Only use if using for production/continuous scanning
volumes:
    scanner:
```
Finally, its time to stand up the docker using docker-compose.
```bash
docker-compose up -d # The -d option is for a detached docker image
```
Watch the scanner logs for the \"Scanner id\" and Public key
Note: this assumes you\'ve named your container \"scanner\"
```bash
docker logs -f [generated scanner name]
```
Example output:
```bash
-------------------------------------------------------
Scanner id: df5tt4csny
Public key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbE8p5zxOoPFPDiE9BCxcRd1jCVaRfOO92BO5hIfdqi df5cy5csnp
Master host key (Check that it matches the public key from the master): [192.168.1.150]:2222 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A55AIMHHl4neiOBuBfCPQtJp/WQuyb6xVIrgmVp3U/A7qmev
-------------------------------------------------------
```
On the host with the GVM server container, run the following command:
```bash
docker exec -it gvm /add-scanner.sh
```
This will prompt you for your scanner name, \"Scanner id\", and Public Key

Scanner Name: *This can be anything you want* 

Scanner ID: *generated id from remote openvas scanner Scanner* 

public key: *private key from scanner*

You will receive a confirmation that the scanner has been added
Login to the GVM server web interface and navtigate to *Configuration -> Scanners* to see the scanner you just added.
You can click the sheild icon next to the scanner to verify the scanner connectivity.

## Docker Tags

| Tag       | Description              |
| --------- | ------------------------ |
| latest    | Latest stable version    |
| dev       | Latest development build |

## Estimated Hardware Requirements

| Hosts              | CPU Cores     | Memory    | Disk Space |
| :----------------- | :------------ | :-------- | :--------- |
| 512 active IPs     | 4@2GHz cores  | 8 GB RAM  | 30 GB      |
| 2,500 active IPs   | 6@2GHz cores  | 12 GB RAM | 60 GB      |
| 10,000 active IPs  | 8@3GHz cores  | 16 GB RAM | 250 GB     |
| 25,000 active IPs  | 16@3GHz cores | 32 GB RAM | 1 TB       |
| 100,000 active IPs | 32@3GHz cores | 64 GB RAM | 2 TB       |
