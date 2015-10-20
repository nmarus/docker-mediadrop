FROM debian:jessie
MAINTAINER Nick Marus <nmarus@gmail.com>

#setup apt
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    apt-get -y install apt-utils && \
    apt-get -y install curl git mysql-client && \
    apt-get -y install libjpeg-dev zlib1g-dev libfreetype6-dev libmysqlclient-dev && \
    apt-get -y install build-essential python-dev python-pip python-setuptools python-virtualenv && \
    apt-get clean

#install uwsgi
RUN pip install uwsgi
RUN pip install uwsgitop

#install python virtual environment
RUN mkdir /venv && cd /venv && virtualenv --distribute --no-site-packages mediadrop

#startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh
