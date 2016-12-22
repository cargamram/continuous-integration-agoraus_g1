#!/bin/bash

ENV_NAME="AgoraUS-G10-Frontend"
URL_VIRTUAL_HOST="beta.frontend.agoraus1.egc.duckdns.org"
BRANCH="beta"
PROJECT_JENKINS_NAME="AgoraUS-G10-Frontend_make"

PATH_ROOT="/var/jenkins_home"
PATH_ROOT_HOST="/home/egcuser/jenkins_home"

echo "Eliminando contenedores antiguos"
ContainerId2=`docker ps -qa --filter "name=$ENV_NAME-$BRANCH-nodejs"`
if [ -n "$ContainerId2" ]
then
	echo "Stopping and removing existing $ENV_NAME-$BRANCH-nodejs container"
	docker stop $ContainerId2
	docker rm -v $ContainerId2
fi


echo "Preparando archivos para despliegue"

rm -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

mkdir -p "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

# NODEJS FOLDER
cp -r $PATH_ROOT/builds/$PROJECT_JENKINS_NAME/* $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/


echo "Desplegando contenedores para $ENV_NAME"

docker run -d --name $ENV_NAME-$BRANCH-nodejs \
	-v "$PATH_ROOT_HOST/deploys/$ENV_NAME/$BRANCH/":/myapp \
    -w /myapp \
    --add-host recuento.agoraus1.egc.duckdns.org:192.168.20.84 \
    --add-host beta.recuento.agoraus1.egc.duckdns.org:192.168.20.84 \
    --restart=always \
	-e VIRTUAL_HOST="$URL_VIRTUAL_HOST" \
	-e VIRTUAL_PORT=8080 \
	-e "LETSENCRYPT_HOST=$URL_VIRTUAL_HOST" \
	-e "LETSENCRYPT_EMAIL=annonymous@alum.us.es" \
	--expose=8080 \
	anapsix/nodejs


echo "Aplicación desplegada en https://$URL_VIRTUAL_HOST"
