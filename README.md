## Docker project: gbevan/ubuntu-foreman

This image was put together for training and demo purposes.  If intending any real use of this image, then you
should seriously consider persistent volumes for all critical data and configuration.

With Foreman 1.11 and latest Ansible v2

The container simply automates instructions at - http://theforeman.org/manuals/1.10/index.html#2.Quickstart

### To use it:

    docker run --restart=always -d -p 443:443 -p 8443:8443 -p 8140:8140 -h hostname.example.com gbevan/ubuntu-foreman

(Optional option --restart=always ensures the container is restarted in the event of failure or restart of the parent server/docker daemon.)

### Monitor the foreman install log, as it completes the installation:

    docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs docker logs -f

(the awk bit just gets the container id, and only really works if you are running just one container, its just a quick start guide)


Point your browser at https://your-host
