![Netizen Logo](https://www.netizen.net/assets/img/netizen_banner_cybersecure_small.png)

Visit our Website: https://www.netizen.net

# Remote OpenVAS Docker Image
### Latest Version: 23.0.0

This docker container is designed for use with our GVM docker image located here: [GVM-Docker](https://github.com/NetizenCorp/GVM-Docker). The remote scanner doesn't contain any web front. It has been designed as a remote scanner that is controlled by a Master GVM Docker Container. The image uses the latest version of OpenVAS and GVM. Netizen continues to make improvements to the software for the stability and functionality of the suite. This container supports AMD 64-bit and ARM 64-bit Linux-based operating systems and Docker Desktop for Windows using WSL 2

## Table of Contents
- [Requirements](https://github.com/NetizenCorp/OpenVAS-Docker/blob/dev/Readme.md#requirements)
- [Linux Installation Instructions](https://github.com/NetizenCorp/OpenVAS-Docker/blob/dev/Readme.md#docker-system-installation-linux-amdarm-64-bit-only)
- [Windows Installation Instruction](https://github.com/NetizenCorp/OpenVAS-Docker/blob/dev/Readme.md#docker-system-installation-windows-wsl2-amd-64-bit-only)
- [Docker Tags](https://github.com/NetizenCorp/OpenVAS-Docker/blob/dev/Readme.md#docker-tags)
- [Estimated Hardware Requirements](https://github.com/NetizenCorp/OpenVAS-Docker/blob/dev/Readme.md#estimated-hardware-requirements)
- [About](https://github.com/NetizenCorp/OpenVAS-Docker/blob/dev/Readme.md#about)

## Requirements
* The GVM Docker Container (Master System) has the SSHD option set to true.
* The proper communication port for SSH (default port 2222) is open for access.
* The IP address of the GVM Controller.

If one of the first two requirements above is missing, you will need to follow the installation instructions in the [GVM-Docker](https://github.com/NetizenCorp/GVM-Docker) to enable remote scanner management. To get your IP address on the Master Scanner, type "ip addr" in the command line or terminal.

## Installation Instructions

### Docker System Installation (Linux AMD/ARM 64-bit Only)
1. Install the required packages, docker, and docker-compose on your Linux system.
```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common docker.io docker-compose
```
2. Create a directory and download the docker-compose.yml file from GitHub. ${USER} is the username of the user(s).
```bash
mkdir /home/$USER/docker/gvm-docker
cd /home/$USER/docker/gvm-docker
wget https://raw.githubusercontent.com/NetizenCorp/OpenVAS-Docker/main/docker-compose.yml
```
3. Modify the docker-compose.yml file using your preferred editor (nano or vim)
```bash
nano docker-compose.yml
```
4. Edit the yml file with your preferences.
```bash
services:
    gvm:
        image: netizensoc/openvas-scanner:[latest|dev] # PICK A VERSION AND REMOVE BRACKETS BEFORE COMPOSING. Latest is the stable image. Dev is the development image.
        volumes:
          - scanner:/data               # DO NOT MODIFY
        environment:
          - MASTER_ADDRESS=[Enter IP]   # IP or Hostname of the GVM Master container. REMOVE BRACKETS BEFORE COMPOSING.
          - MASTER_PORT=2222            # SSH server port from the GVM container. Make sure the port matches the GVM master port that was configured.
        restart: unless-stopped # Remove if you're using it for penetration testing or one-time scans. Only use if using for production/continuous scanning
		logging:
          driver: "json-file"
          options:
            max-size: "1k"
            max-file: "3"
volumes:
    scanner:
```
5. Next, it's time to stand up the docker image using docker-compose.
```bash
sudo docker-compose up -d # The -d option is for a detached docker image
```
6. Watch the scanner logs for the \"Scanner id\" and Public key
Note: this assumes you\'ve named your container \"scanner\"
```bash
sudo docker container ls # Lists the current containers running on the system. Look under the Names column for the container name. Ex: gvm-docker_gvm_1
sudo docker logs -f [OpenVAS container name]
```
Example output:
```bash
-------------------------------------------------------
Scanner id: df5tt4csny
Public key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbE8p5zxOoPFPDiE9BCxcRd1jCVaRfOO92BO5hIfdqi df5cy5csnp
Master host key (Check that it matches the public key from the master): [192.168.1.150]:2222 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A55AIMHHl4neiOBuBfCPQtJp/WQuyb6xVIrgmVp3U/A7qmev
-------------------------------------------------------
```
7. On the host with the GVM server container, run the following command:
```bash
docker exec -it [GVM Container Name] /add-scanner.sh
```
This will prompt you for your scanner name, \"Scanner id\", and Public Key

Scanner Name: *This can be anything you want* 

Scanner ID: *generated id from remote openvas scanner Scanner* 

public key: *private key from scanner*

You will receive a confirmation that the scanner has been added

8. Login to the GVM server web interface and navigate to *Configuration -> Scanners* to see the scanner you just added.

9. You can click the shield icon next to the scanner to verify the scanner connectivity. If it says Scanner Unavailable, restart the OpenVAS remote docker container with the following command:
```bash
sudo docker container restart [OpenVAS container name]
```

### Docker System Installation (Windows WSL2 AMD 64-bit Only)
1. Install Docker Desktop for Windows and the required packages for docker, docker-compose, and WSL 2 on your Windows system. You can download the application at https://www.docker.com/products/docker-desktop/

2. Follow the usual installation instructions to install Docker Desktop. Depending on which version of Windows you are using, Docker Desktop may prompt you to turn on WSL 2 during installation. Read the information displayed on the screen and turn on the WSL 2 feature to continue.

3. After installing Docker Desktop and before activating WSL2, you must create a .wslconfig file under your C:\Users\<Username>\ directory or modify the existing file with the text below. Please configure the file based on your system specs or VM requirements.
```bash
# Settings apply across all Linux distros running on WSL 2
[wsl2]

# Limits VM memory to use no more than 4 GB, this can be set as whole numbers using GB or MB
memory=4GB 

# Sets the VM to use two virtual processors
processors=2

# Network Setting
networkingMode=mirrored

# Specify a custom Linux kernel to use with your installed distros. The default kernel used can be found at https://github.com/microsoft/WSL2-Linux-Kernel
# kernel=C:\\temp\\myCustomKernel

# Sets additional kernel parameters, in this case enabling older Linux base images such as Centos 6
# kernelCommandLine = vsyscall=emulate

# Sets amount of swap storage space to 8GB, default is 25% of available RAM
swap=8GB

# Sets swapfile path location, default is %USERPROFILE%\AppData\Local\Temp\swap.vhdx
swapfile=C:\\temp\\wsl-swap.vhdx

# Disable page reporting so WSL retains all allocated memory claimed from Windows and releases none back when free
pageReporting=false

# Turn on default connection to bind WSL 2 localhost to Windows localhost. Setting is ignored when networkingMode=mirrored
localhostforwarding=true

# Disables nested virtualization
nestedVirtualization=false

# Turns on output console showing contents of dmesg when opening a WSL 2 distro for debugging
debugConsole=true

# Enable experimental features
[experimental]
sparseVhd=true
```
4. Start Docker Desktop from the Windows Start menu.

5. Navigate to Settings.

6. From the General tab, select Use WSL 2 based engine..

7. If you have installed Docker Desktop on a system that supports WSL 2, this option is turned on by default.

8. Select Apply & Restart.

9. Create a directory under your Documents folder and name it whatever you like. 

10. Navigate to https://github.com/NetizenCorp/OpenVAS-Docker/blob/main/docker-compose.yml and download the docker-compose.yml raw file from GitHub. After downloading it, copy it into the directory you created in the Documents folder.

11. Next, you will modify the docker-compose.yml file using your preferred editor (NotePad, NotePad++, etc).

Edit and save the yml file with your preferences. NOTE: Netizen is not responsible for any breach if the user fails to change the default username and passwords. Make sure to store your passwords in a secure password manager.
```bash
services:
    gvm:
        image: netizensoc/openvas-scanner:[latest|dev] # PICK A VERSION AND REMOVE BRACKETS BEFORE COMPOSING. Latest is the stable image. Dev is the development image.
        volumes:
          - scanner:/data               # DO NOT MODIFY
        environment:
          - MASTER_ADDRESS=[Enter IP]   # IP or Hostname of the GVM Master container. REMOVE BRACKETS BEFORE COMPOSING.
          - MASTER_PORT=2222            # SSH server port from the GVM container. Make sure the port matches the GVM master port that was configured.
        restart: unless-stopped # Remove if you're using it for penetration testing or one-time scans. Only use if using for production/continuous scanning
		logging:
          driver: "json-file"
          options:
            max-size: "1k"
            max-file: "3"
volumes:
    scanner:
```
12. It's time to stand up the docker image using docker-compose. Open your command prompt, navigate to the directory with the docker-compose.yml file, and type the following to create/execute the image.
```bash
docker compose up -d # The -d option is for a detached docker image
```
13. Watch the scanner logs for the \"Scanner id\" and Public key
Note: this assumes you\'ve named your container \"scanner\"
```bash
docker container ls # Lists the current containers running on the system. Look under the Names column for the container name. Ex: gvm-docker_gvm_1
docker logs -f [OpenVAS container name]
```
Example output:
```bash
-------------------------------------------------------
Scanner id: df5tt4csny
Public key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbE8p5zxOoPFPDiE9BCxcRd1jCVaRfOO92BO5hIfdqi df5cy5csnp
Master host key (Check that it matches the public key from the master): [192.168.1.150]:2222 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A55AIMHHl4neiOBuBfCPQtJp/WQuyb6xVIrgmVp3U/A7qmev
-------------------------------------------------------
```
14. On the host with the GVM server container, run the following command:
```bash
docker exec -it [GVM container name] /add-scanner.sh
```
This will prompt you for your scanner name, \"Scanner id\", and Public Key

Scanner Name: *This can be anything you want* 

Scanner ID: *generated id from remote openvas scanner Scanner* 

public key: *private key from scanner*

You will receive a confirmation that the scanner has been added

15. Login to the GVM server web interface and navigate to *Configuration -> Scanners* to see the scanner you just added.

16. You can click the shield icon next to the scanner to verify the scanner connectivity. If it says Scanner Unavailable, restart the OpenVAS remote docker container with the following command:
```bash
docker container restart [OpenVAS container name]
```

## Docker Tags

| Tag       | Description              |
| --------- | ------------------------ |
| latest    | Latest stable version    |
| dev       | Latest development build |

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
