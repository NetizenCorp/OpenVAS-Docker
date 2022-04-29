#!/usr/bin/env bash
set -Eeuo pipefail

MASTER_PORT=${MASTER_PORT:-22}
export AUTOSSH_LOGLEVEL=7
export AUTOSSH_LOGFILE=/var/log/gvm/ssh-connection.log

SCANNER_ID=$(cat /var/lib/gvm/.scannerid)

autossh -M 0 -N -T -i /var/lib/gvm/.ssh/key -o TCPKeepAlive=yes -o ServerAliveInterval=15 -o ServerAliveCountMax=20 -o ExitOnForwardFailure=yes -o UserKnownHostsFile=/var/lib/gvm/.ssh/known_hosts -p $MASTER_PORT -R /sockets/$SCANNER_ID.sock:/run/ospd/ospd-openvas.sock gvm@$MASTER_ADDRESS
