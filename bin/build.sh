#!/bin/bash

cd $(dirname $0)
. setenv.sh

cd ../docker

if [ -f ~/.ssh/id_rsa.pub ]; then
	mkdir -p files/root/.ssh
	cp ~/.ssh/id_rsa.pub files/root/.ssh/authorized_keys
else
	echo "~/.ssh/id_rsa.pub is missing. Won't be able to ssh into the container."
fi

docker image rm local/$NAME
docker system prune -f
docker build --rm -t local/$NAME .
docker system prune -f

