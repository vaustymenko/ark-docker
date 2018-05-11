# https://hub.docker.com/_/ubuntu/

FROM ubuntu:16.04

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y -q --no-install-recommends sudo		

RUN echo "root:root" | chpasswd

RUN useradd -ms /bin/bash ark \
	&& echo "ark:ark" | chpasswd \
	&& usermod -G sudo,ark ark \
	&& mkdir -p /home/ark \
	&& chown -R ark:ark /home/ark \
	&& echo 'ark ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install ssh
#mkdir /home/devops-service/.ssh
#chmod 700 /home/devops-service/.ssh
#cat devops-service@v2-20150312.pub >> /home/devops-service/.ssh/authorized_keys
#chown devops-service:devops-service /home/devops-service -R

USER ark

# Install base dependencies
RUN sudo apt-get update && sudo apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        wget \
        vi
#    && rm -rf /var/lib/apt/lists/*

# Download ARK Deployer
RUN cd ~ && git clone https://github.com/ArkEcosystem/ark-deployer.git && cd ark-deployer

# Install NodeJS and NPM
ENV NVM_DIR /home/ark/.nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

ENV NODE_VERSION v8.9.1
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"

ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN sudo apt-get install -y jq

# Install & Setup Your Bridgechain
#RUN cd ~/ark-deployer && ./bridgechain.sh install-node --name MyTest --database ark_mytest --token MYTEST --symbol MT --node-ip 127.0.0.1 --explorer-ip 127.0.0.1 --autoinstall-deps
