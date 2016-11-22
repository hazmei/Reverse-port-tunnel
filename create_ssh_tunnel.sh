#!/bin/bash
createTunnel() {
    /usr/bin/autossh -M MONITORPORT -f -o "StrictHostKeyChecking no" -T -N middleman
    if [[ $? -eq 0 ]]; then
        echo Tunnel to jumpbox created successfully
    else
        echo An error occured creating a tunnel to jumpbox. RC was $?
    fi
}

/bin/pidof ssh
if [[ $? -ne 0 ]]; then
    echo Creating new tunnel connection
    createTunnel
else
    echo Tunnel already exists, pid is $(pidof ssh authssh)
fi