#!/bin/bash
# https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7

# Fail on errors
set -e


# Set timezone 
TZ="US/Eastern"
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 
echo $TZ > /etc/timezone


#yum -y update
yum -y install yum-utils
yum -y groupinstall development
yum -y install python-devel
yum -y install net-tools
yum -y install socat
yum -y install java-1.8.0-openjdk 
yum -y install java-1.8.0-openjdk-devel
yum -y install wget
yum -y install unzip

export JAVA_HOME=/usr

# Install gradle
gradle_version=4.6
[ ! -d /opt/gradle ] && mkdir /opt/gradle
pushd /opt/gradle
curl -O https://services.gradle.org/distributions/gradle-${gradle_version}-all.zip
unzip gradle-${gradle_version}
ln -sf gradle-4.6 /opt/gradle/latest
popd

export PATH="/opt/gradle/latest/bin:$PATH"

# Switch into scripts directory
pushd $(dirname $0)

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

git clone https://github.com/cmusphinx/sphinx4.git
pushd sphinx4
gradle build
popd

pushd /usr/local/share/pocketsphinx/model

for model in \
	"US English/cmusphinx-en-us-5.2.tar.gz" \
	"US English/cmusphinx-en-us-semi-5.1.tar.gz" \
	"US English/cmusphinx-en-us-semi-full-5.1.tar.gz" \
	"US English/en-70k-0.2-pruned.lm.gz" \
	"US English/cmusphinx-en-us-8khz-5.2.tar.gz" \
	"US English/en-70k-0.2.lm.gz" \
	"Russian/cmusphinx-ru-5.2.tar.gz" \
	"Russian/zero_ru_cont_8k_v3.tar.gz" ; do

		curl -O -C - "https://downloads.sourceforge.net/project/cmusphinx/Acoustic%20and%20Language%20Models/$model"
done

for model in *.gz; do
	gunzip "$model"
done

for model in *.tar; do
	tar xvf "$model" && rm -f "$model"
done

popd

# on docker side
# socat tcp-listen:3643,reuseaddr,fork - | pocketsphinx_continuous -hmm /usr/local/share/pocketsphinx/model/en-us/en-us -lm /usr/local/share/pocketsphinx/model/en-us/en-us.lm.bin -dict /usr/local/share/pocketsphinx/model/en-us/cmudict-en-us.dict -infile /dev/stdin -logfn /var/log/pocketsphinx_continuous.log
a
# on host side
# sox -d -c 1 -r 16k -b 16 -L -t wav - |  socat - tcp-connect:localhost:33643


# https://stackoverflow.com/questions/43312975/record-sound-on-ubuntu-docker-image
# https://github.com/jsalsman/featex

