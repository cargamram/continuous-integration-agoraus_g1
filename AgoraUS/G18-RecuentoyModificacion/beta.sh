#!/bin/bash

ENV_NAME="AgoraUS-G18-RecuentoyModificacion"
URL_VIRTUAL_HOST="beta.recuento.agoraus1.egc.duckdns.org"
BRANCH="beta"
PROJECT_JENKINS_NAME="AgoraUS-G18-Recuento_make"

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
cp $PATH_ROOT/private-config/G18-RecuentoyModificacion/private.key $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/keypair/private.key


echo "Desplegando contenedores para $ENV_NAME"


docker run -d --name $ENV_NAME-$BRANCH-nodejs \
	-v "$PATH_ROOT_HOST/deploys/$ENV_NAME/$BRANCH/":/myapp \
 	-w /myapp \
    --restart=always \
	-e VIRTUAL_HOST="$URL_VIRTUAL_HOST" \
	-e VIRTUAL_PORT=80 \
	-e "LETSENCRYPT_HOST=$URL_VIRTUAL_HOST" \
	-e "LETSENCRYPT_EMAIL=annonymous@alum.us.es" \
	--expose=80 \
	dionakra/nodejs-java8
	
docker exec $ENV_NAME-$BRANCH-nodejs apk add tzdata && \
docker exec $ENV_NAME-$BRANCH-nodejs cp /usr/share/zoneinfo/Europe/Madrid /etc/localtime


echo "Aplicación desplegada en https://$URL_VIRTUAL_HOST"
