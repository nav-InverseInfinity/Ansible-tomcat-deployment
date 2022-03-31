#!/bin/bash


if [ -n "$(docker ps -a -f name=tomcat)" ]; then

        docker ps -a -f name=tomcat | docker stop tomcat

        docker ps -a -f name=tomcat | docker rm tomcat

else
        echo "tomcat container is not running at the moment"

fi


