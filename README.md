# Ansible-tower-configuration

Repo for bootstrapping Ansible Tower instances.

## Table of contents

  - [1. Credentials repository](#1-credentials-repository)
  - [2. Building Images](#2-building-images)
    - [2.1 Integreatly Ansible Tower Base Image](#21-integreatly-ansible-tower-base-image)
    - [2.2 Ansible Tower Bootstrap Image](#22-ansible-tower-bootstrap-image)
  - [3. Ansible Tower Installation](#3-ansible-tower-installation)
    - [3.1 Tower Host Name Update](#31-tower-host-name-update)
  - [4. Bootstrapping](#4-bootstrapping)
    - [4.1 Tower Bootstrapping](#41-tower-bootstrapping)
      - [4.1.1 Openshift Dedicated](#411-openshift-dedicated)
    - [4.2 Prerequisite Bootstrapping](#42-prerequisite-bootstrapping)
    - [4.3 Integreatly Bootstrapping](#43-integreatly-bootstrapping)
    - [4.4 Integreatly Uninstall](#44-integreatly-uninstall)
    - [4.5 Cluster Create](#45-cluster-create)
    - [4.6 Cluster Deprovision](#46-cluster-deprovision)
    - [4.7 Validation Bootstrapping](#47-validation-bootstrapping)
    - [4.8 Notifications Bootstrapping](#48-notifications-bootstrapping)
  - [5. Performance Tuning](#5-performance-tuning)
    - [5.1 Task Execution Container](#51-task-execution-container)
    - [5.2 Resource Requests and Request Planning](#52-resource-requests-and-request-planning)
  - [6. Contributing](#6-contributing)

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
ansible-playbook -i <path-to-local-credentials-project>/inventories/hosts playbooks/install_tower.yml -e tower_openshift_master_url=<tower_openshift_master_url> -e tower_openshift_pg_pvc_size=10Gi --ask-vault-pass
```

A number of default values are used when installing Ansible Tower on the target Openshift cluster, any of which can be overridden with the use of environmental variables. These default values include several password values which are assigned a default value of `CHANGEME`, as can be seen below.

* `tower_openshift_project`: The name of the newly created Openshift project (default project name is `tower`)
* `tower_version`: The version of the Ansible Tower Openshift setup project to install (default version is `3.4.3`)
* `tower_archive_url`: The URL of the Ansible Tower Openshift installation project archive file to be used (default URL is `https://releases.ansible.com/ansible-tower/setup_openshift/<tower_version>`)
* `tower_admin_user`: The username required to login to the newly installed Tower instance (default username is `admin`)
* `tower_admin_password`: The password required to login to the newly installed Tower instance (default password is `CHANGEME`)
* `tower_rabbitmq_password`: The password required to login to RabbitMQ (default password is `CHANGEME`)
* `tower_pg_password`: The password required to login to PostgreSQL (default password is `CHANGEME`)
* `tower_openshift_pg_pvc_size`: Size of Postgres persistent volume. Defaults to `100Gi` which is recommended for production environments

### 3.1 Tower Host Name Update

Once the new Tower instance has successfully been installed on the target Openshift cluster, the host name of the new Tower instance must be placed into the `tower_host` variable value, which is located in the `tower.yml` file in the `external_credentials_repo` project.

```bash
<env>_tower_host: 'tower.example.com'
```

## 4. Bootstrapping

### 4.1 Tower Bootstrapping

The `bootstrap.yml` playbook will run the Prerequisite, Integreatly, Cluster Create, Cluster Teardown, Validation and Notification bootstrap playbooks in succession. These individual playbooks can be run independently if required, with instructions on how to do so in the following sections. The playbook requires the target tower environment to be specified.

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

### 4.3 Integreatly Install

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

### 4.4 Integreatly Uninstall

Following the bootstrapping of Integreatly resources, a new workflow named `Integreatly Uninstall Workflow` should be available from the Tower console:

The workflow requires the following parameters to be specified before running:

* `Cluster Name`: The name/ID of the Openshift cluster to target
* `Openshift Master URL`: The Public URL of the Openshift Master
* `Cluster Admin Username`: The username of a cluster-admin account on the target Openshift cluster
* `Cluster Admin Password`: The password of the cluster admin user account specified
* `GIT URL`: The URL of the target Integreatly installer Git repository
* `GIT Ref`: Git reference for Integreatly installer repository

### 4.5 Cluster Create

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

### 4.6 Cluster Deprovision

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

### 4.7 Validation Bootstrapping

The `bootstrap_validation.yml` playbook will bootstrap the target Ansible Tower instance with the resources required to compare the variables in the supplied repository with the variables in the [external credentials repository](https://github.com/integr8ly/tower_dummy_credentials).

```bash
ansible-playbook -i <path-to-local-credentials-project>/hosts playbooks/bootstrap_validation.yml -ask-vault-pass
```

Once the bootstrapping process has completed, a new job template named `Compare Project Variables` will be available, which  requires the following parameters to be specified via the survey before running:

* `Tower Dummy Credentials Repository Branch`: The branch of the tower dummy credentials project
* `Comparison Project Name`: The name of the project to compare against
* `Comparison Project SSH URL`: The Github SSH URL of the project to compare
* `Comparison Project Branch`: The branch of the comparison project to used in the comparison
* `Inventory Path`: The inventory source path of the variables in the comparison project

### 4.8 Notifications Bootstrapping

The `bootstrap_notifications.yml` playbook will bootstrap the target Ansible Tower instance with resources required to send an email notification if the [validation job](https://github.com/integr8ly/ansible-tower-configuration#47-validation-bootstrapping) fails. A scheduled job named `Credential Repositories Sync` that runs the `Compare Project Variables` job template is also created, with this scheduled job being disabled default.

```bash
ansible-playbook -i <path-to-local-credentials-project>/hosts playbooks/bootstrap_notifications.yml -ask-vault-pass
```
## 5. Performance Tuning

In order to support a large number of running jobs concurrently on Ansible Tower, it's important to ensure that the necessary resources have been configured.

### 5.1 Task Execution Container

All jobs on Tower are run from the Task Execution container named `ansible-tower-celery`. When looking to assign additional resources to Tower jobs, it's this container that needs to be updated with new limits.

By default, the `ansible-tower-celery` container has set limits of `1500` millicores CPU and `2Gi` Memory. To update these limits, edit the `ansible-tower` stateful set and modify existing limits, see example snippet below:

```yaml
      name: ansible-tower-celery
      resources:
        requests:
          cpu: 1500m
          memory: 2Gi
```

For new installations, the default limits can be overridden as part of the install using the below variables:

```yaml
tower_task_mem_request
tower_task_cpu_request
```

NOTE: There is also a limit set for the Tower namespace named `tower-core-resource-limits`. The default values here may need to be updated to match the set values in the steps above.

### 5.2 Resource Requests and Request Planning

Ansible Tower is intelligent enough to limit the number of jobs executed based on set limits. These limits are determined using algorithms for both CPU and Memory, see official docs for full details:

https://docs.ansible.com/ansible-tower/3.3.0/html/administration/openshift_configuration.html#resource-requests-and-request-planning


## 6. Contributing
Please open a Github issue for any bugs or problems you encounter.