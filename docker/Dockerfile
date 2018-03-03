FROM	centos/systemd

ENV	container docker

COPY files /

RUN sh -C /root/init/init.sh

# Below is needed for ssh
RUN yum -y install	openssh-server openssh-clients; \
	rm /etc/ssh/ssh_host_*_key*; \
	/usr/bin/ssh-keygen -A; \
	sed -i '/^session.*pam_loginuid.so/s/^session/# session/' /etc/pam.d/sshd ; \
    sed -i 's/Defaults.*requiretty/#Defaults requiretty/g' /etc/sudoers ; \
    rm /usr/lib/tmpfiles.d/systemd-nologin.conf; \
	chmod -R u+rw,og-rwx /root/.ssh

# ssh
EXPOSE 22/tcp

# openvpn
EXPOSE 1194/tcp
EXPOSE 1194/udp

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]

