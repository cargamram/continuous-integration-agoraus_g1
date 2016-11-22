#!/bin/bash

rm -rf $JENKINS_HOME/builds/$JOB_NAME/
mkdir -p $JENKINS_HOME/builds/$JOB_NAME/
cp -r * $JENKINS_HOME/builds/$JOB_NAME/