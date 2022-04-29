#!/usr/bin/env bash
set -Eeuo pipefail

MASTER_PORT=${MASTER_PORT:-22}

if [ -z $MASTER_ADDRESS ]; then
	echo "ERROR: The environment variable \"MASTER_ADDRESS\" is not set"
	exit 1
fi

if [ ! -d /var/lib/gvm/.ssh ]; then
    mkdir -p /var/lib/gvm/.ssh
fi

if [ -f /data/scannerid ]; then
	echo "Moving Scanner ID to new location..."
	mv /data/scannerid /var/lib/gvm/.scannerid
fi

if [ ! -f /var/lib/gvm/.scannerid ]; then
	echo "Generating scanner id..."
	
	echo $(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1) > /var/lib/gvm/.scannerid
fi

if  [ -f /data/ssh/known_hosts ]; then
	echo "Moving Known Hosts to new location..."
	
	mv /data/ssh/known_hosts /var/lib/gvm/.ssh/known_hosts
fi

if  [ ! -f /var/lib/gvm/.ssh/known_hosts ]; then
	echo "Getting Master SSH key..."
	ssh-keyscan -t ed25519 -p $MASTER_PORT $MASTER_ADDRESS > /var/lib/gvm/.ssh/known_hosts.temp
	mv /var/lib/gvm/.ssh/known_hosts.temp /var/lib/gvm/.ssh/known_hosts
fi

if  [ -f /data/ssh/key ]; then
	echo "Moving SSH Key..."
	mv data/ssh/key /var/lib/gvm/.ssh/key
	mv data/ssh/key.pub /var/lib/gvm/.ssh/key.pub
fi

if  [ ! -f /var/lib/gvm/.ssh/key ]; then
	echo "Setup SSH key..."
	ssh-keygen -t ed25519 -f /var/lib/gvm/.ssh/key -N "" -C "$(cat /var/lib/gvm/.scannerid)"
fi

if [ ! -f "/firstrun" ]; then
	echo "Running first start configuration..."

	echo "Creating Openvas NVT sync user..."
	useradd --home-dir /var/lib/openvas openvas-sync
	chown openvas-sync:openvas-sync -R /var/lib/openvas
	
	echo "Creating NVT folder..."
	mkdir -p /var/lib/openvas/plugins/
	chown openvas-sync:openvas-sync -R /var/lib/openvas/plugins
	
	touch /firstrun
fi

if [ ! -d "/run/redis" ]; then
	mkdir /run/redis
fi
if  [ -S /run/redis/redis.sock ]; then
        rm /run/redis/redis.sock
fi
redis-server --unixsocket /run/redis/redis.sock --unixsocketperm 700 --timeout 0 --databases 65536 --maxclients 4096 --daemonize yes --port 6379 --bind 0.0.0.0

echo "Wait for redis socket to be created..."
while  [ ! -S /run/redis/redis.sock ]; do
        sleep 1
done

echo "Testing redis status..."
X="$(redis-cli -s /run/redis/redis.sock ping)"
while  [ "${X}" != "PONG" ]; do
        echo "Redis not yet ready..."
        sleep 1
        X="$(redis-cli -s /run/redis/redis.sock ping)"
done
echo "Redis ready."

echo "Updating NVTs..."
su -c "rsync --compress-level=9 --links --times --omit-dir-times --recursive --partial --quiet rsync://feed.community.greenbone.net:/nvt-feed /var/lib/openvas/plugins" openvas-sync
echo "+++++++++++++++++++++++++++++++++++"
echo "+ Enabling Automating NVT updates +"
echo "+++++++++++++++++++++++++++++++++++"
/update-nvts.sh & disown
sleep 5

if [ -f /var/run/ospd.pid ]; then
  rm /var/run/ospd.pid
fi

if [ -S /data/ospd.sock ]; then
  rm /data/ospd.sock
fi

if [ -f /run/ospd/ospd.pid ]; then
  rm /run/ospd/ospd.pid
fi

if [ -S /tmp/ospd.sock ]; then
  rm /tmp/ospd.sock
fi

if [ -S /run/ospd/ospd.sock ]; then
  rm /run/ospd/ospd-openvas.sock
fi

if [ ! -d /run/ospd ]; then
  mkdir /run/ospd
fi

echo "Starting Open Scanner Protocol daemon for OpenVAS..."
ospd-openvas --log-file /var/log/gvm/ospd-openvas.log --unix-socket /run/ospd/ospd-openvas.sock --socket-mode 0o666 --log-level INFO

while  [ ! -S /run/ospd/ospd-openvas.sock ]; do
	sleep 1
done

touch /var/log/gvm/ssh-connection.log
/connect.sh &

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ Your OpenVAS Scanner container is now ready to use! +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "-------------------------------------------------------"
echo "Scanner id: $(cat /var/lib/gvm/.scannerid)"
echo "Public key: $(cat /var/lib/gvm/.ssh/key.pub)"
echo "Master host key (Check that it matches the public key from the master):"
cat /var/lib/gvm/.ssh/known_hosts
echo "-------------------------------------------------------"
echo ""
echo "++++++++++++++++"
echo "+ Tailing logs +"
echo "++++++++++++++++"
tail -F /var/log/gvm/*
