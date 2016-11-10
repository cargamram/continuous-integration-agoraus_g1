#!/bin/bash 

echo "Eliminando carpeta configuraciones ($JENKINS_HOME/continuous-delivery-playground/)"
rm -r $JENKINS_HOME/continuous-delivery-playground/
mkdir $JENKINS_HOME/continuous-delivery-playground/

echo "Moviendo archivos..."
mv $WORKSPACE/* $JENKINS_HOME/continuous-delivery-playground/
mv $WORKSPACE/util-scripts/jenkinsUpdateContinuousDelivery.sh $JENKINS_HOME/

echo "Estos son los archivos en $JENKINS_HOME/continuous-delivery-playground/"

ls -lah $JENKINS_HOME/continuous-delivery-playground/
