## Docker project: gbevan/ubuntu-foreman

Tested with foreman 1.7.

To use it:

    docker run --restart=always -d -P -h hostname.example.com gbevan/ubuntu-foreman

(Optional option --restart=always ensures the container is restarted in the event of failure or restart of the parent server/docker daemon.) 

It takes a while to finish the installation, to keep an eye on it:

    docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs docker logs -f

Once finish find out which local port is assigned to the docker's https/443:

    docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs -I id docker port id 443