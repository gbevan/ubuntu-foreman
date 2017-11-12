#!/bin/bash -e

export PATH=$PATH:/opt/puppetlabs/bin

if [ -f /var/lib/foreman/.firsttime ]
then
  /etc/init.d/foreman stop
  /etc/init.d/postgresql stop

  sed -i "s/client_certname: .*$/client_certname: ${HOSTNAME}/" /etc/foreman-installer/scenarios.d/foreman-answers.yaml
  sed -i "s/server_certname: .*$/server_certname: ${HOSTNAME}/" /etc/foreman-installer/scenarios.d/foreman-answers.yaml
  sed -i "s?:ssl_cert: .*?:ssl_cert: \"/etc/puppetlabs/puppet/ssl/certs/${HOSTNAME}.pem\"?" /etc/puppetlabs/puppet/foreman.yaml
  sed -i "s?:ssl_key: .*?:ssl_key: \"/etc/puppetlabs/puppet/ssl/private_keys/${HOSTNAME}.pem\"?" /etc/puppetlabs/puppet/foreman.yaml
  sed -i "s/certname = .*/certname = ${HOSTNAME}/g" /etc/puppetlabs/puppet/puppet.conf
  sed -i "s?ssl-cert: .*?ssl-cert: /etc/puppetlabs/puppet/ssl/certs/${HOSTNAME}.pem?" /etc/puppetlabs/puppetserver/conf.d/webserver.conf
  sed -i "s?ssl-key: .*?ssl-key: /etc/puppetlabs/puppet/ssl/private_keys/${HOSTNAME}.pem?" /etc/puppetlabs/puppetserver/conf.d/webserver.conf

  puppet cert list -a

  (puppet master --no-daemonize --verbose &)

  echo "sleeping for puppet master to initialise certs"
  sleep 60

  ps -fe | grep '/opt/puppetlabs/bin/puppet master' | awk '{ print $2; }' | xargs -i@ kill @ || /bin/true
fi

/etc/init.d/postgresql start
echo "sleeping for postgresql to ensure started"
sleep 10

/etc/init.d/foreman start

if [ -f /var/lib/foreman/.firsttime ]
then
  rm /var/lib/foreman/.firsttime
  (/usr/sbin/foreman-rake db:seed || /bin/true)
  (/usr/sbin/foreman-rake permissions:reset || /bin/true)
fi

/opt/puppetlabs/bin/puppet agent
/etc/init.d/puppetserver start

puppet resource service apache2 ensure=running
/usr/sbin/cron
service foreman-proxy restart

echo "*** Startup Complete, logging foreman... ***"
tail -f /var/log/foreman/production.log
