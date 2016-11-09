#!/bin/bash 

ENV_NAME="AgoraUS-G1-Deliberations"
URL_VIRTUAL_HOST="deliberations.agoraus1.egc.duckdns.org"
BRANCH="unstable"
PROJECT_JENKINS_NAME="test31"

PATH_ROOT="/var/jenkins_home"
PATH_ROOT_HOST="/home/egcuser/jenkins_home"

SQL_DUMP_PATH="$PATH_ROOT_HOST/workspace/$JOB_NAME/DeliberationsScript.sql"
MYSQL_PROJECT_ROUTE="localhost"
MYSQL_ROOT_PASSWORD="$(date +%s | sha256sum | base64 | head -c 32)"


echo "Eliminando contenedores antiguos"

ContainerId1=`docker ps -qa --filter "name=$ENV_NAME-mysql"`
if [ -n "$ContainerId1" ]
then
	echo "Stopping and removing existing $ENV_NAME-mysql container"
	docker stop $ContainerId1
	docker rm $ContainerId1
fi

ContainerId2=`docker ps -qa --filter "name=$ENV_NAME-tomcat"`
if [ -n "$ContainerId2" ]
then
	echo "Stopping and removing existing $ENV_NAME-tomcat container"
	docker stop $ContainerId2
	docker rm $ContainerId2
fi


echo "Preparando archivos para despliegue"

rm -r "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/"

mkdir -p "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/"

# WAR
find "$PATH_ROOT/jobs/$PROJECT_JENKINS_NAME/lastSuccessful/" -follow -name *.war -exec cp {} "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/" \;
mv $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/*.war $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/ROOT.war
# mv "$PATH_ROOT/jobs/$PROJECT_JENKINS_NAME/lastSuccessful/**/*.war" "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/webapps/ROOT.war"

# SQL -> "jobs/test31/builds/lastSuccessfulBuild/archive/DeliberationsScript.sql"
find "$PATH_ROOT/jobs/$PROJECT_JENKINS_NAME/lastSuccessful/archive/" -follow -name *.sql -exec cp {} "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/" \;
mv $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/*.sql $PATH_ROOT/deploys/$ENV_NAME/$BRANCH/populate.sql

# mv "$PATH_ROOT/jobs/$PROJECT_JENKINS_NAME/lastSuccessful/archive/*.sql" "$PATH_ROOT/deploys/$ENV_NAME/$BRANCH/populate.sql"


echo "Desplegando contenedores para $ENV_NAME"

docker run --name $ENV_NAME-mysql \
    -v "$PATH_ROOT_HOST/deploys/$ENV_NAME/$BRANCH/populate.sql":/home/user/populate.sql \
    -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
    -d mysql:5.7 \
    --bind-address=0.0.0.0
#     -v "$PATH_ROOT_HOST/config-continuous/agoraus1/$ENV_NAME/mysql/mysqld.cnf":/etc/mysql/mysql.conf.d/mysqld.cnf  \

    
echo "$ENV_NAME-mysql creado !"
echo "$ENV_NAME-mysql creado ($MYSQL_ROOT_PASSWORD)!"

sleep 20

docker exec -it $ENV_NAME-mysql \
    sh -c "exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < /home/user/populate.sql"

echo "$ENV_NAME-mysql populado !"

docker run -d --name $ENV_NAME-tomcat \
    --link $ENV_NAME-mysql:$MYSQL_PROJECT_ROUTE \
    -v "$PATH_ROOT_HOST/deploys/$ENV_NAME/$BRANCH/webapps/":/usr/local/tomcat/webapps \
    -e "LETSENCRYPT_HOST=$URL_VIRTUAL_HOST" \
    -e "LETSENCRYPT_EMAIL=annonymous@alum.us.es" \
	-e VIRTUAL_HOST="$URL_VIRTUAL_HOST" \
	tomcat:7

