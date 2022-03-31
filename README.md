# Table of contents

- General Info
- Technologies
- Setup
- Process - CI/CD Pipeline
- Screenshot


## General Info
The aim of this project is to implement Ansible for deploying a simple WAR file on Tomcat server which runs on Docker conatiners using Continuous Integration and Continuous Deployment.
The source code to build the WAR file comes from Github, Jenkins pulls the code from Git and build the WAR file using MAVEN tool. After building the file, the artifact will be tested and pushed to Ansible server. 
Using ansible as a deployment tool, we will have to script these following files to deploy the artificat onto remote server.
- Dockerfile -to build tomcat container
- Bash Script "docker_build_push.sh" - to build, tag and push Docker image into DockerHub repo
- Ansible-playbook - to login into Dockerhub, pull the Docker image and deploy it on the remote server.

![Flow-chart](https://user-images.githubusercontent.com/98486154/161120309-4cc11b16-3350-4747-baad-3ebc704cdffa.jpg)



## Technologies

- Bash Scripting
- Github
- Ansible
- Docker
- Jenkins
- Maven


 
## Setup

As per the aim of this project, we need 3 VM instances, here we are using AWS EC2 instances,
1. Jenkins server
2. Ansible server (to deploy)
3. Remote server (Deployment)

Frist thing, we need to install Jenkins for Continuous Integration and Continuous Deployment on Jenkins server. To setup Jenkins please refer my Jenkins installation guide on [here](https://github.com/nav-InverseInfinity/Jenkins-setup)
Similarly, we will need Maven to build a WAR file from Github source code.

### Maven setup 


```sh
 #goto https://maven.apache.org/download.cgi
 cd /opt

 sudo wget https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz

 #Extract tar 
 sudo mkdir maven && sudo tar -xvzf apache-maven-3.8.5-bin.tar.gz -C maven
```
 For maven we need to set up PATH for two varibales M2_HOME & M2. M2_HOME should refer to /opt/maven and M2 should refer to /opt/maven/bin
 #### In order to do that goto .profile on Ubuntu distro add & update the PATH
```sh
vi ~/.profile 
#add these lines

M2=/opt/maven/bin
M2_HOME=/opt/maven

#update PATH
PATH=$PATH:$M2:$M2_HOME

#save the file

```
### Next we will have to setup the Jenkins interface as well 
- install "Maven Invoker" plugin 
- goto "Manage Jenkins" --> Global Tool Configuration --> Add Maven Installation
- Under Name "M2_HOME" and Maven Home is the path /opt/maven

		
![maven-jenkkins](https://user-images.githubusercontent.com/98486154/161148538-2df87996-b00b-43b9-9bea-92fef2da8a7b.jpg)


### On Anisble server we will have to install Ansible  for deployment.

### Ansible installation for amazon-linux-2
```bash

#Update packages

sudo yum update -y

#Install ansible

sudo amazon-linux-extras install ansible2 -y

#Check version

ansible –version

```

### Next we will have to install Docker on both Ansible server and remote server 
### To install docker please refer my guide [here](https://github.com/nav-InverseInfinity/docker-setup)

### After installation from Ansible server, we will have to write Dockerfile to build docker image from tomcat, Bash Script and Ansible-playbook.

- ###   Dockerfile - please refer to my Dockerfile [here](https://github.com/nav-InverseInfinity/Ansible-tomcat-deployment/blob/main/Dockerfile) 	
  Base from tomcat, however the latest version have two directories "webapps" & "webapps.dist", by deafult tomcat run files from "webapps", but in the latest version default files are loacted in "webapps.dist", so we will have to move the files from "webapps.dist" to "webapps"

		
![tomcat-webapp](https://user-images.githubusercontent.com/98486154/161153701-d39e6ef6-6452-4a37-ab01-b69d91221dcb.jpg)


	

- ### Bash script to build, tag and push Docker image into DockerHub repo -  please refer [here](https://github.com/nav-InverseInfinity/Ansible-tomcat-deployment/blob/main/docker_build_push.sh)

     This script will check if the same image already exist or not, if exist it will remove it and build a new image, if not, then will build a new image. Similarly, to Tag the build image it follows the same check condition and Tag the image correspond to my DockerHub username/image_name. After tagging the image, it will push the tagged image to my private DockerHub repo.

- ### Ansible-Playbook yaml file to login into Dockerhub, pull the Docker image and deploy it on the remote server. This yaml ansible playbook will perform the *following tasks on the remote server  - please refer to my Ansible-playbook [here](https://github.com/nav-InverseInfinity/Ansible-tomcat-deployment/blob/main/deployment-playbook.yml) 
  *  login into my DockerHub and pull the image 
  *  If the image already exists, it will run a "remove_docker.sh" bash script to remove the image, otherwise skip it. -refer [here](https://github.com/nav-InverseInfinity/Ansible-tomcat-deployment/blob/main/remove_docker.sh)
  *  Changing the ownership on the docker socket so it can run docker as a non-root user.
  *  Running docker image to initiate the tomcat container which has our built artifact WAR file, thus deployed on the remote server which can be seen on the browser.
	
  #### Note - Since we are going to automate the whole process via Jenkins and it will be controlled by "Jenkins", we will have to create a user called Jenkins with UID - 1000 (Jenkins perform task on UID 1000) in Ansible server, so we can run the bash script to push Docker image "docker_build_push.sh" [here](https://github.com/nav-InverseInfinity/Ansible-tomcat-deployment/blob/main/docker_build_push.sh).  

  #### Once after completing the above setups, on Ansible server, we will have to do the following 

  #### Create user named Jenkins
  ```sh useradd jenkins ```

  #### To change the userid, you will have to logout from current user (ec2-user) and login as different user -in this case we have "ansadmin" (Note -you    should turn on ssh - PasswordAuthentication YES to log ansadmin with password) 

  #### change userid and group id 
  ```sh sudo usermod -u 1003 ec2-user ```
  ```sh sudo groupmod -g 1003 ec2-user ```

  #### Now assign jenkins user to UID 1000 
  ```sh sudo usermod -u 1000 jenkins ```
  ```sh sudo groupmod -g 1000 jenkins ```
	


In order to automate the whole CI/CD environment, we will have to establish the connections between servers. Since we are going to connect to our Ansible server, we will have to install “**SSH-Agent**” plugin and make the connection, please refer my guide to Jenkins connections [repo]([https://github.com/nav-InverseInfinity/Jenkins-setup](https://github.com/nav-InverseInfinity/Jenkins-setup)).

![ansadmin-jenkiins](https://user-images.githubusercontent.com/98486154/161155956-fe06dae5-3252-4026-a9f0-564864505577.jpg)


We should also establish connection between Ansible server and remtoe server via ssh

```bash

ssh-keygen  
#goto “./.ssh” and copy public id

cat ./.ssh/id_rsa.pub

#Then onto remote server under ./.ssh directory

vi authorized_keys

#paste the ansible server’s public_key and save it

```
### Now we have connection between Jenkins to Ansible and Ansible to Remote server. Jenkins can continuously build and delivery and Ansible can continuously deploy the built on the remote server.
## Process - CI/CD Pipeline

Plan is to build Jenkins CI/CD pipeline with environmental variables, here we are going to pass docker login password and AWS IP as “**secret text**”. DockerHub password = **PASS** and AWS IP = **AWS_IP**
Since we are going to build WAR file from JAVA source code, we will need "tools" - here we are using "maven"
```sh
 tools {
        maven "M2_HOME"
    }
``` 

### CI/CD Stages refer [here](https://github.com/nav-InverseInfinity/Jenkins-tomcat-deployment/blob/main/Jenkins_pipeline)


- #### *Build* - pull the source code (simple java code) from GitHub and build a WAR file aritifact and then test it.
```sh
	git branch: 'main', url: 'https://github.com/InverseInfinity/tomcat_test.git'
	sh "mvn -Dmaven.test.failure.ignore=true clean package"
```
- #### *Push_Artifact* - After building and testing the artifact, we will have to copy the *.WAR file to Ansible server for building Docker image

```sh
	scp /var/lib/jenkins/workspace/ansible_tomcat_deployment/webapp/target/*.war ansadmin@$aws_ip:/opt/docker/
```
- #### *Build_Push_Docker_Image* - From Ansible server, with the help of "docker_build_push.sh"  bash script which will build a Docker image based on the copied artifact WAR file and tag it and psuh it into DockerHub.

```sh
   ssh ansadmin@$aws_ip "cd /opt/docker/ && ./docker_build_push.sh"
```
- #### *Deploying* - From Ansible server, we will have to run the deployment-playbook.yml  yaml file which will perform several tasks on the remote server - pull the uploaded Docker image from Dockerhub using Docker login with $PASS env varibale, run a "remove_docker.sh" basch script to check if the images already exist or not and if exist, it will remove the images, so we can run the latest build Docker container. Next, it will run the Docker container where tomcat up and running with the WAR file in it.
```sh
   ssh ansadmin@$aws_ip "cd /opt/docker/ && ansible-playbook -i /opt/docker/hosts deployment-playbook.yml"
```


Since we need to automate the process, that is whenever there is a change in the source code, Jenkins should trigger and run the pipeline, so we can see the change on the deployment. 
#### To do this, we will have to activate Jenkins Poll SCM, which will monitor for any changes in the source code, if there is any change occurs, Jenkins deployment job will be triggered and start to deploy the new changes, this way it can be completely automated.

## Screenshot
![screenshot](https://user-images.githubusercontent.com/98486154/161156374-b8354d8b-a1d2-48ad-890c-a70a3a077145.jpg)

