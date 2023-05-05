#!/usr/bin/env bash
# This script update the NVTs in the background every 12 hours.
set -Eeuo pipefail

while true; do
	echo "Running Automatic NVT update..."
	su -c "greenbone-feed-sync -v --compression-level=9 --type=nvt" openvas-sync
	su -c "greenbone-feed-sync -v --compression-level=9 --type=notus" openvas-sync
	sleep 43200
done
