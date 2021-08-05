# ECS Anywhere via Docker-in-Docker

In order to run ECS Anywhere you need systemd and Docker. This repository is an approach for running that *within* Docker using a Docker-in-Docker approach.

## Building the Docker file

The Dockerfile in this folder will build an Amazon Linux 2 container that has both systemd and docker that can serve as an ECS Anywhere sandbox for us.

On a machine with Docker Desktop installed and running run the following commands:
1. Clone the GitHub repository:
   `git clone https://github.com/aws-samples/amazon-ecs-anywhere-container-in-container-with-docker`
1. Change directory:
   `cd ecsanywhere-dind`
1. Authenticate with ECR Public to avoid reaching Docker pull rate limits ( not required but usefull to avoid ducker pull limits ):
   `aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws`
1. Pull Amazon Linux 2 image from ECR Public locally:
   `docker pull public.ecr.aws/amazonlinux/amazonlinux:2`
1. Build the Docker image:
   `docker build -t ecsanywhere-dind .`
1. Run the Docker image in the background in privileged mode and name it `ecsanywhere`:  
   `docker run -d --privileged --name ecsanywhere -p 8080-8090:8080-8090 ecsanywhere-dind:latest`
1. Enter the interactive shell for this container: 
   `docker exec -it ecsanywhere /bin/bash`
    We'll paste the command to join this to Systems manager and ECS into that interactive shell within the container in a moment.

## Add the ECS Anywhere container as a managed instance on Systems Manager

In the AWS Console:
1. Go to the ECS Service
1. Click the blue `Create Cluster` button
1. Choose Networking only (should already be selected by default) and click the blue `Next step` button
1. Type `ECSAnywhere` for the Cluster name, click the box to enable CloudWatch Container Insights, and then click the blue `Create` button
1. Click the blue `View Cluster` button
1. Go to the ECS Instances tab in the middle of the console
1. Click the `Register External Instances` button
1. Click the blue `Next step` button
1. Click the blue `Copy` button to copy the command we need to the clipboard

Then just paste that command in to the interactive shell within our ecsanywhere-dind container to register this container against both SSM and ECS Anywhere.

## Notes: Docker in Docker
Note that this is a separate nested docker and network within the one on your Mac/Win machine (which itself is a separate Linux VM on those machines). 

This means that:
* You won't see the containers ECS launches by doing a `docker ps` on the host - you'll need to do a `docker exec` into the running ecsanywhere container interactive shell and do the `docker ps` there to see the Amazon ECS agent running. 
* There is a double NATing happening (ecsanywhere-dind->Docker Desktop->Host). We have exposed the range 8080-8090 in the `docker run` example above so you need to ensure that your ECS-scheduled containers use hostports in that range to be able to access them from a browser on your PC/Mac host - or change the ports/range in that command to meet your needs if that doesn't.

## Clean-up

1. Type `exit` to exit the interactive shell.
1. You can stop a container with the command `docker stop ecsanywhere` to pause it and `docker start ecsanywhere` to start it up again.    
1. To remove the container, you can type `docker rm` which will remove it from being an ECS cluster member.
1. From the AWS console go to `AWS Systems Manager` then `Fleet Manager` to select the instance starting with `mi-` and identify your ECS Anywhere instance and select it, then click `Instrance actions` then `Deregister this managed instance`.

CREDIT - the Dockerfile/approach was inspired by https://github.com/nikovirtala/amazonlinux-dind
