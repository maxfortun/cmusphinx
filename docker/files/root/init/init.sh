#!/bin/bash
# https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7
set -e

cd $(dirname $0)

#yum -y update
yum -y install yum-utils
yum -y groupinstall development
yum -y install python-devel
yum -y install net-tools
yum -y install socat

# https://github.com/cmusphinx
# http://sphinxsearch.com/downloads/

for p in sphinxbase sphinxtrain pocketsphinx; do
	#svn checkout svn://svn.code.sf.net/p/cmusphinx/code/trunk/$p
	git clone https://github.com/cmusphinx/$p.git
	pushd $p
	./autogen.sh 
	make
	make install
	popd
done

# on docker side
# socat tcp-listen:3643,reuseaddr - | pocketsphinx_continuous -hmm /usr/local/share/pocketsphinx/model/en-us/en-us -lm /usr/local/share/pocketsphinx/model/en-us/en-us.lm.bin -dict /usr/local/share/pocketsphinx/model/en-us/cmudict-en-us.dict -infile /dev/stdin
a
# on host side
# sox -d -c 1 -r 16k -e signed -b 16 -t wav - |  socat - tcp-connect:localhost:33643


# https://stackoverflow.com/questions/43312975/record-sound-on-ubuntu-docker-image
# https://github.com/jsalsman/featex

