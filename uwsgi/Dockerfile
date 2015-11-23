# docker-mediadrop
# https://github.com/nmarus/docker-mediadrop
# Nicholas Marus <nmarus@gmail.com>

FROM debian:jessie
MAINTAINER Nicholas Marus <nmarus@gmail.com>

#setup apt
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    apt-get -y install apt-utils && \
    apt-get -y install curl git mysql-client && \
    apt-get -y install libjpeg-dev zlib1g-dev libfreetype6-dev libmysqlclient-dev && \
    apt-get -y install build-essential python-dev python-pip python-setuptools python-virtualenv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#install uwsgi
RUN pip install uwsgi
RUN pip install uwsgitop

#startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Startup
CMD ["/start.sh"]
