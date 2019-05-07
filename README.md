# Ansible-tower-configuration

Repo for bootstrapping Ansible Tower instances.

## Table of contents


  - [1. Credentials repository](#1-credentials-repository)
  - [2. Building Images](#2-building-images)
    - [2.1 Integreatly Ansible Tower Base Image](#2.1-integreatly-ansible-tower-base-image)
    - [2.2 Ansible Tower Bootstrap Image](#ansible-tower-bootstrap-image)
  - [3. Ansible Tower Installation](#3-ansible-tower-installation)
    - [3.1 Tower Bootstrapping](#tower-bootstrapping)
  - [4. Bootstrapping](#4-bootstrapping)
    - [4.1 Tower Bootstrapping](#tower-bootstrapping)
      - [4.1.1 Openshift Dedicated](#openshift-dedicated)
    - [4.2 Prerequisite Bootstrapping](#prerequisite-bootstrapping)
    - [4.3 Integreatly Bootstrapping](#integreatly-bootstrapping)
    - [4.4 Integreatly Install](#integreatly-Install)
    - [4.5 Cluster Create](#cluster-create)
    - [4.6 Cluster Deprovision](#cluster-deprovision)

## 1. Credentials repository

This project uses an [external credentials repository](https://github.com/integr8ly/tower_dummy_credentials) as it's inventory source which also includes all of the variables required and the password to be used for the running of the playbooks in the project.

Once the [external credentials repository](https://github.com/integr8ly/tower_dummy_credentials) has been bootstrapped with the required variables to suit your own environment, it should be used as the inventory source for executing playbooks in this project, replacing `<path-to-local-credentials-project>` with the path to your local credentials project.

## 2. Building Images

### 2.1 Integreatly Ansible Tower Base Image

To build and tag the Integreatly Ansible Tower Base docker image simply run:

```bash
cd images/tower_base/ && make
```

To push the built image to quay.io run:

```bash
make image/push
```

### 2.2 Ansible Tower Bootstrap Image

To build and tag the Ansible Tower Bootstrap docker image simply run:

```bash
cd images/tower_bootstrap/ && make
```

To push the built image to quay.io run:

```bash
make image/push
```

## 3. Ansible Tower Installation

The `install_tower.yml` playbook will install Ansible Tower on a target Openshift cluster. The playbook requires the target tower environment to be specified.

* `tower_openshift_master_url`: The URL of the target Openshift cluster

```bash
ansible-playbook -i <path-to-local-credentials-project>/inventories/hosts playbooks/install_tower.yml -e tower_openshift_master_url=<tower_openshift_master_url> --ask-vault-pass
```

A number of default values are used when installing Ansible Tower on the target Openshift cluster, any of which can be overridden with the use of environmental variables. These default values include several password values which are assigned a default value of `CHANGEME`, as can be seen below.

* `tower_openshift_project`: The name of the newly created Openshift project (default project name is `tower`)
* `tower_version`: The version of the Ansible Tower Openshift setup project to install (default version is `3.4.3`)
* `tower_archive_url`: The URL of the Ansible Tower Openshift installation project archive file to be used (default URL is `https://releases.ansible.com/ansible-tower/setup_openshift/<tower_version>`)
* `tower_admin_user`: The username required to login to the newly installed Tower instance (default username is `admin`)
* `tower_admin_password`: The password required to login to the newly installed Tower instance (default password is `CHANGEME`)
* `tower_rabbitmq_password`: The password required to login to RabbitMQ (default password is `CHANGEME`)
* `tower_pg_password`: The password required to login to PostgreSQL (default password is `CHANGEME`)

### 3.1 Tower Host Name Update

Once the new Tower instance has successfully been installed on the target Openshift cluster, the host name of the new Tower instance must be placed into the `tower_host` variable value, which is located in the `tower.yml` file in the `external_credentials_repo` project.

```bash
<env>_tower_host: 'tower.example.com'
```

## 4. Bootstrapping

### 4.1 Tower Bootstrapping

The `bootstrap.yml` playbook will run the Prerequisite, Integreatly, Cluster Create and Cluster Teardown bootstrap playbooks in succession. These individual playbooks can be run independently if required, with instructions on how to do so in the following sections. The playbook requires the target tower environment to be specified.

* `tower_environment`: The Ansible Tower environment (dev/test/qe etc.)

```bash
ansible-playbook -i <path-to-local-credentials-project>/inventories/hosts playbooks/bootstrap.yml -e tower_environment=<tower-environment> --ask-vault-pass
```

#### 4.1.1 Openshift Dedicated

If you also wish to bootstrap the tower instance with the OSD integreatly install workflow you need to run this play after running the bootstrap.yml play.

```bash
ansible-playbook -i inventories/hosts playbooks/bootstrap_osd_integreatly_install.yml -e tower_environment=<tower-environment>
```

This will create the resources necessary to use the *Integreatly_Bootstrap_and_install_[OSD]* workflow which will install Integreatly on a targeted OSD cluster.

### 4.2 Prerequisite Bootstrapping

Prior to running any jobs stored in this repository, the target Ansible tower instance must first be bootstrapped with some generic resources. The playbook requires the target tower environment to be specified.

* `tower_environment`: The Ansible Tower environment (dev/test/qe)

```bash
ansible-playbook -i <path-to-local-credentials-project>/inventories/hosts playbooks/bootstrap_tower.yml -e tower_environment=<tower-environment>
```

### 4.3 Integreatly Bootstrapping

The `bootstrap_integreatly.yml` playbook will bootstrap a target Ansible Tower instance with all resources required to execute a workflow that allows end users to install Integreatly against a specified Openshift cluster. Note: This is currently limited to clusters that are provisioned via the Tower cluster provision workflow.

There are no additional parameters required by default:

```bash
ansible-playbook -i <path-to-local-credentials-project>/hosts playbooks/bootstrap_integreatly.yml --ask-vault-pass
```

### 4.4 Integreatly Install

Following the bootstrapping of Integreatly resources, a new workflow named `Integreatly Install Workflow` should be available from the Tower console:

The workflow requires the following parameters to be specified before running:

* `Cluster Name`: The name/ID of the Openshift cluster to target
* `Openshift Master URL`: The Public URL of the Openshift Master
* `Cluster Admin Username`: The username of a cluster-admin account on the target Openshift cluster
* `Cluster Admin Password`: The password of the cluster admin user account specified
* `GIT URL`: The URL of the target Integreatly installer Git repository
* `GIT Ref`: Git reference for Integreatly installer repository
* `User Count`: The number of users to pre-seed the Integreatly environment with
* `Self Signed Certs`: Set to `false` by default. Set to `true` if the target Openshift cluster uses self signed certificates

### 4.5 Integreatly Uninstall

Following the bootstrapping of Integreatly resources, a new workflow named `Integreatly Uninstall Workflow` should be available from the Tower console:

The workflow requires the following parameters to be specified before running:

* `Cluster Name`: The name/ID of the Openshift cluster to target
* `Openshift Master URL`: The Public URL of the Openshift Master
* `Cluster Admin Username`: The username of a cluster-admin account on the target Openshift cluster
* `Cluster Admin Password`: The password of the cluster admin user account specified
* `GIT URL`: The URL of the target Integreatly installer Git repository
* `GIT Ref`: Git reference for Integreatly installer repository

### 4.6 Cluster Create

Once the tower bootstrapping has been run you can bootstrap the cluster create resources. To create all the resources necessary to run a cluster create you must run the `bootstrap_cluster_create.yml` playbook. The playbook doesn't take any extra variables so the command to run is:

```bash
ansible-playbook -i <path-to-local-credentials-project>/hosts playbooks/bootstrap_cluster_create.yml --ask-vault-pass
```

Once the cluster provision resources have been bootstrapped, a new workflow named `Provision Cluster` should be available from the Tower console:

The workflow requires the following parameters to be specified before running:

* `Cluster Name`: The name/ID of the Openshift cluster to target
* `AWS Region`: The region to create the cluster in
* `Domain Name`: The domain name to be used to create the cluster
* `AWS Account Name`: The name of the AWS account to be used to create the cluster

### 4.7 Cluster Deprovision

Once the tower bootstrapping has been run you can bootstrap the cluster deprovision resources. To create all the resources necessary to run a cluster deprovision you must run the `bootstrap_cluster_teardown.yml` playbook. The playbook doesn't take any extra variables so the command to run is:

```bash
ansible-playbook -i <path-to-local-credentials-project>/hosts playbooks/bootstrap_cluster_teardown.yml -ask-vault-pass
```

Once the cluster deprovision resources have been bootstrapped, a new workflow named `Deprovision Cluster` should be available from the Tower console:

The workflow requires the following parameters to be specified before running:

* `Cluster Name`: The name/ID of the Openshift cluster to target
* `AWS Region`: The region that the cluster resides in
* `Domain Name`: The cluster domain name
* `AWS Account Name`: The name of the AWS account used to create the cluster