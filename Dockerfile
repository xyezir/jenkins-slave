FROM ubuntu:16.04
MAINTAINER yecn

ADD ./sources.list /etc/apt/sources.list

WORKDIR /opt
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Install base
RUN apt-get update && \
    apt-get install -y unzip wget git curl build-essential gcc make python2.7-dev python-pip vim unattended-upgrades apt-transport-https ca-certificates python-software-properties software-properties-common

# Install Jdk
RUN add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-set-default && \
    java -version

# Install docker
RUN curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get -y update && \
    apt-get -y install docker-ce && \
    docker -v

# Install php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y --force-yes php7.1-cli php7.1 php-pgsql php-sqlite3 php-gd php-apcu php-curl php7.1-mcrypt php-imap php-mysql php-memcached php7.1-readline php-xdebug php-mbstring php-xml php7.1-zip php7.1-intl php7.1-bcmath php-soap && \
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini  && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini  && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini  && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini && \
    php -v

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    # Add Composer Global Bin To Path
    printf "\nPATH=\"$(composer config -g home 2>/dev/null)/vendor/bin:\$PATH\"\n" | tee -a ~/.profile

#Install nvm & nodejs
ENV NVM_DIR "$HOME/.nvm"
RUN git clone https://github.com/creationix/nvm.git "$NVM_DIR" && \
    cd "$NVM_DIR" && \
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin` && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install v7.9 && \
    node -v && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
ARG GRADLE_VERSION=2.13
WORKDIR /usr/bin
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip && \
  unzip gradle-${GRADLE_VERSION}-all.zip && \
  ln -s gradle-${GRADLE_VERSION} gradle && \
  rm gradle-${GRADLE_VERSION}-all.zip

ENV GRADLE_HOME /usr/bin/gradle
ENV PATH $PATH:$GRADLE_HOME/bin
ENV GIT_SSL_NO_VERIFY 1

ADD init.gradle ~/.gradle/
ADD start.sh /opt/start.sh
ADD slave.jar /opt/slave.jar
ADD daemon.json /etc/docker/daemon.json

RUN chmod +x /opt/start.sh

ENTRYPOINT ["/opt/start.sh"]
