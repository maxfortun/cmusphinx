#!/bin/bash

cd $(dirname $0)
. setenv.sh

./stop.sh

cd ..

DEV_MIC_DIR=$(dirname "$DEV_MIC")
[ -d "$DEV_MIC_DIR" ] || mkdir -p "$DEV_MIC_DIR"
pushd "$DEV_MIC_DIR"
ABS_DEV_MIC_DIR=$PWD
popd
DEV_MIC_NAME=$(basename $DEV_MIC)

[ -d "$DEV_MIC_DIR" ] || mkdir -p "$DEV_MIC_DIR"
[ -p "$DEV_MIC" ] || mkfifo $DEV_MIC

cd docker

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

echo docker run -itd -e container=docker --privileged --cap-add SYS_ADMIN --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v "$ABS_DEV_MIC_DIR:/mnt/$DEV_MIC_DIR" $PORTS --name $NAME local/$NAME
docker run -itd -e container=docker --privileged --cap-add SYS_ADMIN --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v "$ABS_DEV_MIC_DIR:/mnt/$DEV_MIC_DIR" $PORTS --name $NAME local/$NAME
