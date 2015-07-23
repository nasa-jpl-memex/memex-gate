# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This Dockerfile will build the required environment and stack to easily 
# get up and running with running LegisGATE
# For more documentation please see https://github.com/lewismc/legisgate

FROM google/debian:wheezy

MAINTAINER Lewis John McGibbney <lewis.j.mcgibbney@jpl.nasa.gov>

# Get the package containing apt-add-repository installed for adding repositories
RUN apt-get update && apt-get install -y software-properties-common

# Install openJDK 1.7
RUN apt-get install -y openjdk-7-jdk 

# Install various dependencies
RUN apt-get install -y ant wget maven openssh-server openssh-client git vim telnet subversion rsync curl build-essential

RUN echo "JAVA_HOME=/usr/bin" >> /etc/environment

RUN echo 'PATH=$PATH:HOME/bin:$JAVA_HOME/bin' >> /etc/profile &&\
    echo 'export JAVA_HOME' >> /etc/profile &&\
    echo 'export PATH' >> /etc/profile

RUN addgroup hadoop
RUN adduser -ingroup hadoop --gecos "" --disabled-password hduser

RUN rm -rf /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key

USER hduser

RUN ssh-keygen -q -N "" -t rsa -f /home/hduser/.ssh/id_rsa
RUN cp /home/hduser/.ssh/id_rsa.pub /home/hduser/.ssh/authorized_keys
# add localhost to hduser's list of known_hosts files without need ssh login
RUN ssh-keyscan -H localhost >> ~/.ssh/known_hosts

USER root

WORKDIR /tmp

########################
# Apache Mahout 0.10.0 #
########################
ENV MAHOUT_PKG_NAME mahout-distribution-0.10.0
RUN wget http://archive.apache.org/dist/mahout/0.10.0/$MAHOUT_PKG_NAME.tar.gz && \
    tar -xvzf $MAHOUT_PKG_NAME.tar.gz && \
    rm -f $MAHOUT_PKG_NAME.tar.gz && \
    mv $MAHOUT_PKG_NAME /usr/local/mahout

# Needed to specify that we are running without a cluster
ENV MAHOUT_LOCAL true
ENV MAHOUT_HOME /usr/local/mahout

# SSH login fix so user isn't kicked after login
RUN sed 's#session\s*required\s*pam_loginuid.so#session optional pam_loginuid.so#g' -i /etc/pam.d/sshd

# so you can call 'mahout'
ENV PATH $PATH:/usr/local/mahout/bin

########################
# Apache Hadoop 2.2.0  #
########################
ENV HADOOP_PKG_NAME hadoop-2.2.0
RUN wget http://archive.apache.org/dist/hadoop/core/hadoop-2.2.0/$HADOOP_PKG_NAME.tar.gz && \
    tar -xvzf $HADOOP_PKG_NAME.tar.gz && \
    rm -f $HADOOP_PKG_NAME.tar.gz && \
    mv $HADOOP_PKG_NAME /usr/local/hadoop

WORKDIR /usr/local
RUN chown -R hduser:hadoop hadoop

# ENV needs to be used, as the above doesn't seem to be visible from cli
ENV JAVA_HOME /usr
ENV HADOOP_HOME /usr/local/hadoop

# so you can call 'hadoop', etc
ENV PATH $PATH:/usr/local/hadoop/bin

#######################
# Elasticsearch 1.5.0 #
#######################
ENV ES_PKG_NAME elasticsearch-1.5.0
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar -xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv $ES_PKG_NAME /usr/local/elasticsearch

# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/local/elasticsearch/config/elasticsearch.yml

# Define default command.
CMD ["/usr/local/elasticsearch/bin/elasticsearch"]

# Expose ports.
# - 9200: HTTP
# - 9300: transport
EXPOSE 9200
EXPOSE 9300

# Obtain the sources for DigitalPebble's Behemoth
#WORKDIR /usr/local
#RUN git clone https://github.com/DigitalPebble/behemoth.git
#cd behemoth && mvn clean install -DskipTests

#############
# MemexGATE #
#############
WORKDIR /usr/local
RUN git clone https://github.com/memex-explorer/memex-gate.git
ENV MEMEXGATE_HOME /usr/local/memex-gate 
#so you can call 'memexgate'
ENV PATH $PATH:$MEMEXGATE_HOME/bin

