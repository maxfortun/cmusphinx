#!/bin/bash

cd $(dirname $0)
. setenv.sh

docker stop $NAME

