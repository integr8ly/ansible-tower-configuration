FROM centos:latest

WORKDIR /ansible-tower-configuration

ADD https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz /tmp/

# ansible, python-pip and tower-cli installation
RUN yum -y update && \
    yum install -y epel-release && \
    yum install -y ansible && \
    yum install -y python-pip && \
    yum clean all && \
    pip install --upgrade pip && \
    pip install ansible-tower-cli && \
    sh -c "tar -xzf /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz -C /tmp/" && \
    sh -c "mv /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit/oc /usr/bin/oc" && \ 
    sh -c "rm /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz" && \
    chmod 755 /usr/bin/oc