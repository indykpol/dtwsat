# Replace with your preferred system docker if you wish
FROM ubuntu
# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        git \
        libssl-dev \
        wget \
        curl \
        libproj-dev \
        libgdal-dev \
	libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 12.10.0

WORKDIR $NVM_DIR

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN mkdir /usr/app
RUN mkdir /usr/app/log

WORKDIR /usr/app

# log dir
VOLUME /usr/app/log

# Bundle app source
COPY . /usr/app
# Install app dependencies
RUN npm install

EXPOSE  3000
CMD ["node", "server.js"]

RUN npm -g install gh

RUN mkdir /home/dwtSat

FROM r-base
RUN R -e "install.packages('devtools')"
RUN R -e "devtools::install_github('vwmaus/dtwSat')"
