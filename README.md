## Docker project: gbevan/ubuntu-foreman

To use it:

    docker run -d -P -h hostname.example.com gbevan/ubuntu-foreman

It takes a while to finish the installation, to keep an eye on it:

    docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs docker logs -f

Once finish find out which local port is assigned to the docker's https/443:

    docker ps | awk '/gbevan\/ubuntu-foreman/ {print $1}' | xargs -I id docker port id 443