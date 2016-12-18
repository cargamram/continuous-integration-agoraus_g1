#!/bin/bash

ENV_NAME="AgoraUS-G25-CabinaVotacionTelegram"
# URL_VIRTUAL_HOST="beta.cvtelegram.agoraus1.egc.duckdns.org"
BRANCH="beta"
PROJECT_JENKINS_NAME="AgoraUS-G25-CabinaVotacionTelegram_make"

PATH_ROOT="/var/jenkins_home"
PATH_ROOT_HOST="/home/egcuser/jenkins_home"

echo "Eliminando contenedores antiguos"
ContainerId2=`docker ps -qa --filter "name=$ENV_NAME-$BRANCH-python"`
if [ -n "$ContainerId2" ]
then
	echo "Stopping and removing existing $ENV_NAME-$BRANCH-python container"
	docker stop $ContainerId2
	docker rm -v $ContainerId2
fi


echo "Preparando archivos para despliegue"

rm -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

mkdir -p "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

# PYTHON FOLDER
cp -r $PATH_ROOT/builds/$PROJECT_JENKINS_NAME/* $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/
cp $PATH_ROOT/private-config/G25-CabinaTelegram/config_beta.ini $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/config.ini


echo "Desplegando contenedores para $ENV_NAME"

docker run -d --name $ENV_NAME-$BRANCH-python \
    -v "$PATH_ROOT_HOST/deploys/$ENV_NAME/$BRANCH/":/myapp \
    -v /etc/hosts:/etc/hosts:ro \
    -w /myapp \
    --restart=always \
    gurken2108/python3-java \
    bash -c "pip install -r requirements.txt && python3 cabinaTelegram.py"


echo "Aplicación desplegada en https://telegram.me/CabinaEGCDevBot"
