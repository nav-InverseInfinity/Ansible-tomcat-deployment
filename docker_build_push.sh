
#!/bin/bash

# Building and Pushing docker image to dockerhub private repo

echo "******* Building Docker Image *********"

#Build image - check if the image already exist or not

if [ -n "$(docker images -q tomcat_server_image)" ]; then 

	docker rmi -f "$(docker images -q tomcat_server_image)"
	
	docker build -t tomcat_server_image .
	
else
	docker build -t tomcat_server_image .
fi

echo "******* Tagging Docker Image *********"

#Tagging docker image - check if the image already exist or not

if [ -n "$(docker images -q inverseinfinity/tomcat_server)" ]; then 

	docker rmi -f "$(docker images -q inverseinfinity/tomcat_server)" 
	
	docker tag tomcat_server_image inverseinfinity/tomcat_server
	
else
	docker tag tomcat_server_image inverseinfinity/tomcat_server
fi

echo "******* Logging into Dockerhub *********"

#docker login

echo "$dockerpass" | docker login -u inverseinfinity --password-stdin


echo "******* Pushing Docker Image *********"

#pushing image to docker private repo

docker push inverseinfinity/tomcat_server:latest




