#!/bin/bash

ENV_NAME="AgoraUS-G2-CabinaVotacion"
URL_VIRTUAL_HOST="cvotacion.agoraus1.egc.duckdns.org"
BRANCH="stable"


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
cp -r $PATH_ROOT/deploys/$ENV_NAME/beta/* $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/


echo "Desplegando contenedores para $ENV_NAME"

docker run -d --name $ENV_NAME-$BRANCH-python \
	-v "$PATH_ROOT_HOST/deploys/$ENV_NAME/$BRANCH/":/myapp \
 	-w /myapp \
	--add-host beta.censos.agoraus1.egc.duckdns.org:192.168.20.84 \
	--add-host censos.agoraus1.egc.duckdns.org:192.168.20.84 \
	--add-host beta.recuento.agoraus1.egc.duckdns.org:192.168.20.84 \
	--add-host recuento.agoraus1.egc.duckdns.org:192.168.20.84 \
	--add-host beta.authb.agoraus1.egc.duckdns.org:192.168.20.84 \
	--add-host authb.agoraus1.egc.duckdns.org:192.168.20.84 \
    	--restart=always \
	-e VIRTUAL_HOST="$URL_VIRTUAL_HOST" \
	-e VIRTUAL_PORT=8000 \
	-e "LETSENCRYPT_HOST=$URL_VIRTUAL_HOST" \
	-e "LETSENCRYPT_EMAIL=annonymous@alum.us.es" \
	--expose=8000 \
	korekontrol/ubuntu-java-python2 \
	bash -c "pip install -r requirements.txt && python manage.py syncdb && python manage.py runserver 0.0.0.0:8000"


echo "Aplicación desplegada en https://$URL_VIRTUAL_HOST"
