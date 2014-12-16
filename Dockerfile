# Build:
# 	docker build -t gbevan/ubuntu-foreman .
#
# Run:
#	docker run -d -P -h foreman.example.com gbevan/ubuntu-foreman
#
# tail log:
# 	docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs docker logs -f
#
# get port 80 exposed on host
#	docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs -I id docker port id 80
#
# resolve dns issues:
# /etc/conf/docker
#	DOCKER_OPTS="--dns 194.168.4.100 --dns 194.168.8.100"

FROM ubuntu:14.04
MAINTAINER Graham Bevan "graham.bevan@ntlworld.com"
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y wget && echo "deb http://deb.theforeman.org/ trusty 1.7" > /etc/apt/sources.list.d/foreman.list && echo "deb http://deb.theforeman.org/ plugins 1.7" >> /etc/apt/sources.list.d/foreman.list && wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && apt-get update && apt-get install -y foreman-installer
EXPOSE 80
EXPOSE 8140
EXPOSE 8443
CMD foreman-installer --foreman-locations-enabled --enable-foreman-compute-ec2 --enable-foreman-compute-gce --enable-foreman-compute-ovirt --enable-foreman-compute-vmware --foreman-proxy-tftp=false --enable-puppet --puppet-server-envs-dir=/etc/puppet/environments --puppet-server-environments=test && tail -f /var/log/foreman/production.log
#CMD /bin/bash
