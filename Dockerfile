FROM registry.access.redhat.com/ansible-tower-34/ansible-tower

USER root

COPY centos-key /tmp/

ADD https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 /usr/bin/jq
ADD https://github.com/mikefarah/yq/releases/download/2.2.1/yq_linux_amd64 /usr/bin/yq
ADD https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz /tmp/

RUN rpm --import /tmp/centos-key && \
    yum-config-manager --add-repo=http://mirror.centos.org/centos-7/7/os/x86_64/ && \
    yum-config-manager --add-repo=http://mirror.centos.org/centos/7/updates/x86_64/ && \
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install unzip httpd-tools java-1.8.0-openjdk-headless dh-autoreconf && \
    sh -c "git clone https://github.com/ansible/tower-cli.git ; cd tower-cli ; make install" && \
    sh -c "tar -xzf /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz -C /tmp/" && \
    sh -c "mv /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit/oc /usr/bin/oc" && \ 
    sh -c "rm /tmp/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz" && \
    sh -c ". /var/lib/awx/venv/awx/bin/activate" && \
    chmod 755 /usr/bin/yq /usr/bin/jq /usr/bin/oc

USER awx
