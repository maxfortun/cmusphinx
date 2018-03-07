#!/bin/bash
while true; do
	socat tcp-listen:3643,reuseaddr,fork - | pocketsphinx_continuous -hmm /usr/local/share/pocketsphinx/model/en-us/en-us -lm /usr/local/share/pocketsphinx/model/en-us/en-us.lm.bin -dict /usr/local/share/pocketsphinx/model/en-us/cmudict-en-us.dict -infile /dev/stdin -logfn /var/log/pocketsphinx_continuous.log 2> /var/log/sphinxd.err | socat - udp-sendto:127.255.255.255:3644,broadcast
	sleep 5
done 
