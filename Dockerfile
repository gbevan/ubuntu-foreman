# Build:
#   docker build -t gbevan/ubuntu-foreman .
#
# Run:
#  docker run -d -p 443:443 -p 8443:8443 -p 8140:8140 -h foreman.example.com gbevan/ubuntu-foreman
#
# tail log:
#   docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs docker logs -f
#
# Point your browser at https://your-host
#
# resolve dns issues:
# /etc/conf/docker
#  DOCKER_OPTS="--dns ip_1 --dns ip_2"
#
# Used the following projects as reference:
#   riskable/docker-foreman
#   xnaveira/foreman-docker

FROM ubuntu:14.04
MAINTAINER Graham Bevan "graham.bevan@ntlworld.com"

ENV FOREMANVER 1.11
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
    apt-get upgrade -y && \
    apt-get -y install ca-certificates wget && \
    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    dpkg -i puppetlabs-release-trusty.deb && \
    apt-get install -y wget aptitude htop vim vim-puppet git traceroute dnsutils && \
    echo "deb http://deb.theforeman.org/ trusty $FOREMANVER" > /etc/apt/sources.list.d/foreman.list && \
    echo "deb http://deb.theforeman.org/ plugins $FOREMANVER" >> /etc/apt/sources.list.d/foreman.list && \
    wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add - && \
    apt-get install -y software-properties-common && \
    apt-add-repository ppa:git-core/ppa -y && \
    apt-get update && \
    apt-get install -y foreman-installer && \
    apt-get install -y git python-pip iotop sysstat krb5-user libkrb5-dev python-dev python-jinja2 python-yaml python-paramiko python-httplib2 python-six python-crypto sshpass && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y ansible && \
    pip install 'pywinrm>=0.1.1' && \
    pip install 'kerberos==1.2.2' && \
    echo "set modeline" > /root/.vimrc && \
    echo "export TERM=vt100" >> /root/.bashrc && \
    LANG=en_US.UTF-8 locale-gen --purge en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    rm -f /usr/share/foreman-installer/checks/hostname.rb && \
    export FACTER_fqdn="foreman.example.com" && \
    echo "127.1.1.2  foreman.example.com" >> /etc/hosts && \
    /usr/sbin/foreman-installer $FOREOPTS; \
    sed -i -e "s/START=no/START=yes/g" /etc/default/foreman

EXPOSE 443
EXPOSE 8140
EXPOSE 8443

#CMD ( test ! -f /etc/foreman/.first_run_completed && \
#        ( echo "FIRST-RUN: Please wait while Foreman is installed and configured..."; \
#        /usr/sbin/foreman-installer $FOREOPTS; \
#        sed -i -e "s/START=no/START=yes/g" /etc/default/foreman; \
#        touch /etc/foreman/.first_run_completed \
#        ) \
#    ); \
CMD /etc/init.d/puppet stop && \
    /etc/init.d/apache2 stop && \
    /etc/init.d/foreman stop && \
    /etc/init.d/postgresql stop && \
    echo "sleeping for postgresql to ensure stopped" && \
    sleep 60 && \
    /etc/init.d/postgresql start && \
    echo "sleeping for postgresql to ensure started" && \
    sleep 60 && \
    /etc/init.d/foreman start && \
    /etc/init.d/apache2 start && \
    /etc/init.d/puppet start && \
    /etc/init.d/foreman-proxy start && \
    /usr/sbin/cron && \
    foreman-rake permissions:reset && \
    /usr/sbin/foreman-rake db:seed && \
    service foreman-proxy restart && \
    tail -f /var/log/foreman/production.log
