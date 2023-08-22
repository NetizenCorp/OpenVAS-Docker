![Netizen Logo](https://www.netizen.net/assets/img/netizen_banner_cybersecure_small.png)

Visit our Website: https://www.netizen.net

# Remote OpenVAS Docker Image
### Latest Version: 22.7.3

This docker container is designed for use with our GVM docker image located here: [GVM-Docker](https://github.com/NetizenCorp/GVM-Docker). The remote scanner doesn't contain any web front. It has been designed as a remote scanner that is controlled by a Master GVM Docker Container. The image uses the latest version of OpenVAS and GVM. This container supports AMD 64-bit and ARM 64-bit Linux-based operating systems.

## Requirements
* The GVM Docker Container (Master System) has the SSHD option set to true.
* The proper communication port for SSH (default port 2222) is open for access.
* The IP address of the GVM Controller.

If one of the first two requirements above is missing, you will need to follow the installation instructions in the [GVM-Docker](https://github.com/NetizenCorp/GVM-Docker) to enable remote scanner management. To get your IP address on the Master Scanner, type "ip addr" in the command line or terminal.

## Installation for AMD 64-Bit Based Operating Systems
First, install docker and docker-compose on your Linux system. After installation, apply permissions to a user(s) that will use docker. ${USER} is the username of the user(s)
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common docker.io docker-compose
```
Next, create a directory and download the docker-compose.yml file from GitHub
```bash
mkdir /home/$USER/docker/gvm-docker
cd /home/$USER/docker/gvm-docker
wget https://raw.githubusercontent.com/NetizenCorp/OpenVAS-Docker/main/docker-compose.yml
```
Next, you will modify the docker-compose.yml file using your preferred editor (nano or vim)
```bash
nano docker-compose.yml
```
Edit the yml file with your preferences.
```bash
version: "3.8"
services:
    gvm:
        image: netizensoc/openvas-scanner:[latest|dev|stable] # PICK A VERSION AND REMOVE BRACKETS BEFORE COMPOSING. Latest is the stable image. Dev is the development image.
        volumes:
          - scanner:/data               # DO NOT MODIFY
        environment:
          - MASTER_ADDRESS=[Enter IP]   # IP or Hostname of the GVM Master container. REMOVE BRACKETS BEFORE COMPOSING.
          - MASTER_PORT=2222            # SSH server port from the GVM container. Make sure the port matches the GVM master port that was configured.
        restart: unless-stopped # Remove if you're using it for penetration testing or one-time scans. Only use if using for production/continuous scanning
volumes:
    scanner:
```
Next, it's time to stand up the docker using docker-compose.
```bash
sudo docker-compose up -d # The -d option is for a detached docker image
```
Watch the scanner logs for the \"Scanner id\" and Public key
Note: this assumes you\'ve named your container \"scanner\"
```bash
sudo docker container ls # Lists the current containers running on the system. Look under the Names column for the container name. Ex: gvm-docker_gvm_1
sudo docker logs -f [generated scanner name]
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
Login to the GVM server web interface and navigate to *Configuration -> Scanners* to see the scanner you just added.
You can click the shield icon next to the scanner to verify the scanner connectivity. If it says Scanner Unavailable, restart the OpenVAS remote docker container with the following command:
```bash
sudo docker container restart [generated container name]
```

## Installation for ARM 64-Bit Based Operating Systems
First, install docker and docker-compose on your Linux system. After installation, apply permissions to a user(s) that will use docker. ${USER} is the username of the user(s).
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common docker.io docker-compose
```
Next, create a directory, clone the GitHub Repository, and Build the Docker Image. Note: The building process will take time to complete.
```bash
mkdir -p /home/$USER/docker/
cd /home/$USER/docker/
git clone --branch main https://github.com/NetizenCorp/OpenVAS-Docker.git
cd OpenVAS-Docker/
sudo docker build . -t openvas
```
Next, you will modify the docker-compose.yml file using your preferred editor (nano or vim)
```bash
nano docker-compose.yml
```
Edit the yml file with your preferences.
```bash
version: "3.8"
services:
    gvm:
        image: openvas:latest
        volumes:
          - scanner:/data               # DO NOT MODIFY
        environment:
          - MASTER_ADDRESS=[Enter IP]   # IP or Hostname of the GVM Master container. REMOVE BRACKETS BEFORE COMPOSING.
          - MASTER_PORT=2222            # SSH server port from the GVM container. Make sure the port matches the GVM master port that was configured.
        restart: unless-stopped # Remove if your using for penetration testing or one-time scans. Only use if using for production/continuous scanning
volumes:
    scanner:
```
Next, its time to stand up the docker using docker-compose.
```bash
sudo docker-compose up -d # The -d option is for a detached docker image
```
Watch the scanner logs for the \"Scanner id\" and Public key
Note: this assumes you\'ve named your container \"scanner\"
```bash
sudo docker container ls # Lists the current containers running on the system. Look under the Names column for the container name. Ex: gvm-docker_gvm_1
sudo docker logs -f [generated scanner name]
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
sudo docker exec -it gvm /add-scanner.sh
```
This will prompt you for your scanner name, \"Scanner id\", and Public Key

Scanner Name: *This can be anything you want* 

Scanner ID: *generated id from remote openvas scanner Scanner* 

public key: *private key from scanner*

You will receive a confirmation that the scanner has been added
Login to the GVM server web interface and navigate to *Configuration -> Scanners* to see the scanner you just added.
You can click the shield icon next to the scanner to verify the scanner connectivity. If it says Scanner Unavailable, restart the OpenVAS remote docker container with the following command:
```bash
sudo docker container restart [generated container name]
```

## Docker Tags

| Tag       | Description              |
| --------- | ------------------------ |
| latest    | Latest stable version    |
| dev       | Latest development build |
| stable    | Old Stable Version       |

## Estimated Hardware Requirements

| Hosts              | CPU Cores     | Memory    | Disk Space |
| :----------------- | :------------ | :-------- | :--------- |
| 512 active IPs     | 4@2GHz cores  | 8 GB RAM  | 100 GB      |
| 2,500 active IPs   | 6@2GHz cores  | 12 GB RAM | 100 GB      |
| 10,000 active IPs  | 8@3GHz cores  | 16 GB RAM | 100 GB     |
| 25,000 active IPs  | 16@3GHz cores | 32 GB RAM | 100 GB       |
| 100,000 active IPs | 32@3GHz cores | 64 GB RAM | 100 GB       |

## About
Any Issues or Suggestions for the Project can be communicated via the [issues](https://github.com/NetizenCorp/OpenVAS-Docker/issues). Thanks.
