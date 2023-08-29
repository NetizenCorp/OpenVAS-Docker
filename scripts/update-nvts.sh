#!/usr/bin/env bash

echo "Running Automatic NVT update..."
su -c "greenbone-feed-sync -v --compression-level=9 --type=nvt" gvm
sleep 5
su -c "greenbone-feed-sync -v --compression-level=9 --type=notus" gvm
