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
#
# Used the following projects as reference:
#   riskable/docker-foreman
#   xnaveira/foreman-docker

FROM ubuntu:latest
MAINTAINER Graham Bevan "graham.bevan@ntlworld.com"

ENV DEBIAN_FRONTEND noninteractive
ENV FOREOPTS --foreman-locations-enabled \
        --enable-foreman-compute-ec2 \
        --enable-foreman-compute-gce \
        --enable-foreman-compute-ovirt \
        --enable-foreman-compute-vmware \
        --enable-foreman-compute-libvirt \
        --enable-foreman-compute-openstack \
        --enable-foreman-compute-rackspace \
        --enable-puppet \
        --puppet-listen=true \
        --puppet-show-diff=true \
        --puppet-server-envs-dir=/etc/puppet/environments

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget aptitude htop vim vim-puppet git traceroute dnsutils && \
    echo "deb http://deb.theforeman.org/ trusty 1.7" > /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ plugins 1.7" >> /etc/apt/sources.list.d/foreman.list && \
    wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && \
    apt-get update && \
    apt-get install -y foreman-installer && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y python-pip ansible && \
    pip install http://github.com/diyan/pywinrm/archive/master.zip#egg=pywinrm && \
    echo "set modeline" > /root/.vimrc && \
    echo "export TERM=vt100" >> /root/.bashrc

EXPOSE 443
EXPOSE 8140
EXPOSE 8443

CMD ( test ! -f /etc/foreman/.first_run_completed && \
        ( echo "FIRST-RUN: Please wait while Foreman is installed and configured..."; \
        /usr/sbin/foreman-installer $FOREOPTS; \
        sed -i -e "s/START=no/START=yes/g" /etc/default/foreman; \
        touch /etc/foreman/.first_run_completed \
        ) \
    ); \
    /etc/init.d/puppet stop; \
    /etc/init.d/apache2 stop; \
    /etc/init.d/foreman stop; \
    /etc/init.d/postgresql stop; \
    /etc/init.d/postgresql start; \
    /etc/init.d/foreman start; \
    /etc/init.d/apache2 start; \
    /etc/init.d/puppet start; \
    tail -f /var/log/foreman/production.log
