FROM jenkins/jenkins:lts

# Suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

# Used to set the docker group ID
# Set to 497 by default, which is the group ID used by AWS Linux ECS Instance
ARG DOCKER_GID=497

# Create Docker Group with GID
# Set default value of 497 if DOCKER_GID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-497} docker

# Used to control Docker and Docker Compose versions installed
# NOTE: As of February 2016, AWS Linux ECS only supports Docker 1.9.1
ARG DOCKER_ENGINE=19.03.8
ARG DOCKER_COMPOSE=1.25.0

# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https curl python3-pip python3-dev python3-setuptools gcc make libssl-dev software-properties-common build-essential -y

# Install Docker Engine
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu cosmic stable" && \
    apt-get update -y && \
    apt-get install docker-ce docker-ce-cli containerd.io -y && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -aG docker jenkins && \
    usermod -aG users jenkins

# Install Docker Compose
RUN pip3 install docker-compose==${DOCKER_COMPOSE:-1.25.0} && \
    pip3 install ansible boto boto3

# Change to jenkins user
USER jenkins

# Add Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt