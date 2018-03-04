#!/bin/bash

cd $(dirname $0)
. setenv.sh

sshPort=$(docker ps --format "{{.Ports}}" -f "name=$NAME" | sed 's/^.*:\([0-9]*\)->22.*$/\1/g')
echo "Connecting to port $sshPort"
ssh root@localhost -p $sshPort -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no


