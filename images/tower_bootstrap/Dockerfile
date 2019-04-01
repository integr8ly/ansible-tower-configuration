FROM centos:latest

WORKDIR /ansible-tower-configuration 

# ansible, python-pip and tower-cli installation
RUN yum -y update && \
    yum install -y epel-release && \
    yum install -y ansible && \
    yum install -y python-pip && \
    yum clean all && \
    pip install --upgrade pip && \
    pip install ansible-tower-cli