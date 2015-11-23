#!/bin/bash
#used to build images for mediadrop

set -e

#colors
NONE=$(echo -e '\033[00m')
RED=$(echo -e '\033[00;31m')
GREEN=$(echo -e '\033[00;32m')
YELLOW=$(echo -e '\033[00;33m')
PURPLE=$(echo -e '\033[00;35m')
CYAN=$(echo -e '\033[00;36m')
WHITE=$(echo -e '\033[00;37m')
BOLD=$(echo -e '\033[1m')
UNDERLINE=$(echo -e '\033[4m')

#print timestamp
timestamp() {
  date +"%Y-%m-%d %T"
}

#screen/file logger
#$1 = string
sflog() {
    #if $1 is not null
    if [ ! -z ${1+x} ]; then
        message=$1
        echo "${CYAN}$(timestamp)${NONE} ${message}"
    else
        #exit function
        return 1;
    fi
    #if $LOG_FILE is not null
    if [ ! -z ${LOG_FILE+x} ]; then
    #if $2 is regular file or does not exist
        if [ -f ${LOG_FILE} ] || [ ! -e ${LOG_FILE} ]; then
            echo "${CYAN}$(timestamp)${NONE} ${message}" >> ${LOG_FILE}
        fi
    fi
}

#screen/file logger
#read from stdin
#$1 message
#$2 color code
sfpipe() {
    while read in; do
        sflog "${2}${1}${NONE} $in"
    done
}

#check for root access and re-init /srv folders
reset_srv() {
    if [ "$(whoami)" == "root" ]; then
        #remove data folders for rebuild
        rm -rf /srv/wsgi &> /dev/null || true
        rm -rf /srv/mediadrop &> /dev/null || true
        rm -rf /srv/venv &> /dev/null || true
        rm -rf /srv/mariadb &> /dev/null || true
    else
        sflog "This command must be run as root or sudo."
    fi
}

#build nginx
build_nginx() {
    {
        #remove image
        (docker rmi mediadrop-nginx &> /dev/null || true )
        (cd nginx && docker build --rm --no-cache -t mediadrop-nginx . )
    } | sfpipe nginix ${RED}
}

#build uwsgi
build_uwsgi() {
    {
        #remove image
        (docker rmi mediadrop-uwsgi &> /dev/null || true )
        (cd uwsgi && docker build --rm --no-cache -t mediadrop-uwsgi .)
    } | sfpipe uwsgi ${GREEN}
}

#build mariadb
build_mariadb() {
    {
        #pull latest base image
        docker pull mariadb
    } | sfpipe mariadb ${YELLOW}
}

#simple args parse
if [ ! -z ${1+x} ]; then
    if [ "${1}" = "all" ]; then
        build_nginx &
        build_uwsgi &
        build_mariadb &
        sleep 5
        while (($(ps aux | grep 'mediadrop' | grep -v 'grep' | wc -l) != 0)); do
            sleep 5 &> /dev/null
        done
    elif [ "${1}" = "nginx" ]; then
        build_nginx
    elif [ "${1}" = "uwsgi" ]; then
        build_uwsgi
    elif [ "${1}" = "reset" ]; then
        reset_srv
    fi
    sflog "Done."
else
    echo "Usage: ${0} all|nginx|uwsgi|reset"
fi
docker rmi $(docker images -q -f dangling=true) &> /dev/null
