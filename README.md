# Docker-Mediadrop
####Mediadrop on Docker with separate Nginx, uWSGI, and MariaDB containers

### Requirements:

- docker 1.8.x
- docker-compose

### Container Descriptions:
This application makes use of docker containerization. This is accomplished across 4 containers.

Their descriptions are outlined as follows:

1. *mediadrop-uwsgi* - Based in debian:jessie. On first start it checks if mediadrop has been and installed. If not, it will:
    * Clone the mediadrop repo from github this build was based on
    * Activates python virtual enviroment
    * Installs mediadrop from source
    * Adds customizations fto the deployment.ini
    * Configures UWSGI service in socket mode
    * Checks if database is not populated and runs the database scripts and optional databse search tables to the connected mediadtop-mariadb container


*Note: See [start.sh] (https://github.com/nmarus/docker-mediadrop/blob/master/uwsgi/start.sh)*


2. *mediadrop-nginx* - Based on official docker nginx image with customized.
nginx configuration, and self signed certs.


*Note: By default, the nginx.conf runs non SSL to get around the Adobe Flash player requirements that do not work with self signed certificates for file upload in regard the ["File I/O Error #2038."] (http://stackoverflow.com/questions/1789863/swfupload-on-https-not-working) To enable SSL, and continue to have file uploads work, you must use a trusted CA signed certificate. (This seems to only affect MAC versions of the flashplayer) See SSL section below under Advanced Configuration.)*


3. *mediadrop-mariadb* - Based on official docker mariadb image. Uses environment variables defined in the docker-compose.yml to setup the mediadrop database.

### Quick Start:

1. Clone this repository

        $ git clone https://github.com/nmarus/docker-mediadrop.git

2. Modify docker-compose.yml - Edit environment variables to include specifics for
deployment. It will however, work as-is.

3. Build the images - This script creates the docker images on the connected docker server.

        $ ./build.sh all

4. Run mediadrop - This starts all the images and create appropriate links between each container.

        $ docker-compose up -d

5. Wait approximately 5-10 minutes for the initial build before attempting to access the web interface.

### Advanced:

#### Enable SSL:

1. Modify the nginx/nginx.conf file
    - Remove the commented sections while also commenting out or removing the "listen 80" line in the main server section
    - Replace "<fqdn>" with the CNAME used to generate your CA signed certificates (i.e. video.example.com)

2. Upload your certificate and public key to the nginx folder replacing the self signed key found there. Make sure you use the same file names and have concatenated the intermediary certificates if required by your CA.

3. If you have already tested this with out SSL enabled, make sure you the mediadrop-nginx container from previous build.

        $ docker-compose stop
        $ docker-compose rm mediadrop-nginx

4. Rebuild the nginx image

        $ ./build.sh nginx

5. Restart mediadrop

        $ docker-compose up -d

#### Enable Volume Mapping

These steps will ensure that you have the non persistent files stored to your docker host. These changes are made from the docker-compose.yml file.

1. Enable the persistent data volumes for "mediadrop-uwsgi":

        volumes:
            - /local/path/for/wsgi:/wsgi
            - /local/path/for/mediadrop:/mediadrop
            - /local/path/for/venv:/venv

2. Enable the persistent data volume for "mediadrop-mariadb":

        volumes:
            - /local/path/for/mysql:/var/lib/mysql

#### Enable the Mediadrop Official Repository
The installer script downloads a snapshot of the mediadrop repositry as it was on October 17th, 2015. If you wish to download the latest updates, do the following.

###### Note 1: Depending on how much has changed in the repository, these scripts may not work.

###### Note 2: If you have not enabled the storing of non persistent data outside of docker, your current setup will be reset to default.

1. Add an environment variable to the mediadrop-uwsgi section of the docker-compose.yml file.

        environment:
            - USE_OFFICIAL_GIT=true

2. Remove containers and redeploy images with new docker-compose.yml file.

        $ docker-compose stop
        $ docker-compose rm -f
        $ docker-compose up -d
