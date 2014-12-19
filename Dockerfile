# Build:
# 	docker build -t gbevan/ubuntu-foreman .
#
# Run:
#	docker run -d -P -h foreman.example.com gbevan/ubuntu-foreman
#
# tail log:
# 	docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs docker logs -f
#
# get port 443 exposed on host
#	docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs -I id docker port id 443
#
# resolve dns issues:
# /etc/conf/docker
#	DOCKER_OPTS="--dns ip_1 --dns ip_2"

FROM ubuntu:14.04
MAINTAINER Graham Bevan "graham.bevan@ntlworld.com"

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget aptitude htop vim vim-puppet git traceroute && \
    echo "deb http://deb.theforeman.org/ trusty 1.7" > /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ plugins 1.7" >> /etc/apt/sources.list.d/foreman.list && \
    wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && \
    apt-get update && \
    apt-get install -y foreman-installer

EXPOSE 443
EXPOSE 8140
EXPOSE 8443

CMD foreman-installer \
    --foreman-locations-enabled \
    --enable-foreman-compute-ec2 \
    --enable-foreman-compute-gce \
    --enable-foreman-compute-ovirt \
    --enable-foreman-compute-vmware \
    --enable-foreman-compute-libvirt \
    --enable-foreman-compute-openstack \
    --enable-puppet \
    --puppet-listen=true \
    --puppet-show-diff=true \
    --puppet-server-envs-dir=/etc/puppet/environments \
    ; tail -f /var/log/foreman/production.log
