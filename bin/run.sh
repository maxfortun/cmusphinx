#!/bin/bash

cd $(dirname $0)
. setenv.sh

./stop.sh

cd ../docker

PORTS=
while read dockerPort; do 
	hostPrefix=$PORT_PREFIX
	hostPort=$hostPrefix$dockerPort
	while [ "$hostPrefix" != "" -a "$hostPort" -gt "65535" ]; do
		hostPrefix=${hostPrefix%?}
		hostPort=$hostPrefix$dockerPort
	done
	PORTS="$PORTS -p $hostPort:$dockerPort"
done < <(grep -o 'EXPOSE[[:space:]]*[[:digit:]]*' Dockerfile|awk '{ print $2 }'|sort -fu)

docker system prune -f

docker run -itd -e container=docker --privileged --cap-add SYS_ADMIN --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro $PORTS --name $NAME local/$NAME
