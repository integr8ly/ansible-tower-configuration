# ansible-tower-configuration

Repo for bootstrapping Ansible Tower instances

## Building Images

### Integreatly Ansible Tower Base Image

To build and tag the Integreatly Ansible Tower Base docker image simply run:

```bash
cd images/tower_base/ && make
```

To push the built image to quay.io run:

```bash
make image/push
``` 

### Ansible Tower Bootstrap Image

To build and tag the Ansible Tower Bootstrap docker image simply run:

```bash
cd images/tower_bootstrap/ && make
```

To push the built image to quay.io run:

```bash
make image/push
``` 

## Ansible Tower Installation

The `install_tower.yml` playbook will install Ansible Tower on a target Openshift cluster.

The playbook requires a number of configs to be passed in, namely:

* `tower_openshift_master_url`: The hostname of the target Openshift cluster
* `tower_openshift_username`: The username to be used to login to the Openshift cluster (requires admin permissions)
* `tower_openshift_password`: The password of the Openshift user specified

```bash
ansible-playbook -i inventories/hosts playbooks/install_bootstrap.yml -e tower_openshift_master_url=<tower_openshift_master_url> -e tower_openshift_username=<tower_openshift_username> -e tower_openshift_password=<tower_openshift_password>
```

A number of default values are used when installing Ansible Tower on the target Openshift cluster, any of which can be overridden with the use of environmental variables. These default values include several password values which are assigned a default value of `CHANGEME`, as can be seen below.

* `tower_openshift_project`: The name of the newly created Openshift project (default project name is `tower`)
* `tower_version`: The version of the Ansible Tower Openshift setup project to install (default version is `3.4.3`)
* `tower_archive_url`: The URL of the Ansible Tower Openshift installation project archive file to be used (default URL is `https://releases.ansible.com/ansible-tower/setup_openshift/<tower_version>`)
* `tower_admin_user`: The username required to login to the newly installed Tower instance (default username is `admin`)
* `tower_admin_password`: The password required to login to the newly installed Tower instance (default password is `CHANGEME`)
* `tower_rabbitmq_password`: The password required to login to RabbitMQ (default password is `CHANGEME`)
* `tower_pg_password`: The password required to login to PostgreSQL (default password is `CHANGEME`)

## Bootstrapping

### Tower Bootstrapping

The `bootstrap.yml` playbook will run the Prerequisite, Integreatly and Cluster Create bootstrap playbooks in succession. These individual playbooks can be run independently if required, with instructions on how to do so in the following sections.

The bootstrap playbook requires a number of configs to be passed in, namely:

* `tower_host`: The hostname of the target Ansible Tower instance
* `tower_username`: The username to login with when integrating with Tower (requires admin permissions)
* `tower_password`: The password of the tower_user specified
* `tower_verify_ssl`: (Optional) Determines whether to verify the SSL certs installed on the Tower instance. By default this is set to `false`

```bash
ansible-playbook -i inventories/hosts playbooks/bootstrap.yml -e tower_host=<tower-host> -e tower_username=<tower-username> -e tower_password=<tower-password>
```

### Prerequisite Bootstrapping

Prior to running any jobs stored in this repository, the target Ansible tower instance must first be bootstrapped with some generic resources.

The following bootstrap playbook requires a number of configs to be passed in, namely:

* `tower_host`: The hostname of the target Ansible Tower instance
* `tower_username`: The username to login with when integrating with Tower (requires admin permissions)
* `tower_password`: The password of the tower_user specified
* `tower_verify_ssl`: (Optional) Determines whether to verify the SSL certs installed on the Tower instance. By default this is set to `false`

```bash
ansible-playbook -i inventories/hosts playbooks/bootstrap_tower.yml -e tower_host=<tower-host> -e tower_username=<tower-username> -e tower_password=<tower-password>
```

### Integreatly Bootstrapping

The `bootstrap_integreatly.yml` playbook will bootstrap a target Ansible Tower instance with all resources required to execute a workflow that allows end users to install Integreatly against a specified Openshift cluster. Note: This is currently limited to clusters that are provisioned via the Tower cluster provision workflow.

There are no additional parameters required by default:

```bash
ansible-playbook -i inventories/hosts playbooks/bootstrap_integreatly.yml
```

### Integreatly Workflow

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

### Cluster Create

Once the tower bootstrapping has been run you can bootstrap the cluster create resources. To create all the resources necessary to run a cluster create you must run the `bootstrap_cluster_create.yml` playbook. The playbook doesn't take any extra variables so the command to run is:

```bash
ansible-playbook -i inventories/hosts playbooks/bootstrap_cluster_create.yml
```

## Cluster Deprovision

Once the tower bootstrapping has been run you can bootstrap the cluster deprovision resources. To create all the resources necessary to run a cluster deprovision you must run the `bootstrap_cluster_teardown.yml` playbook. The playbook doesn't take any extra variables so the command to run is:

```bash
ansible-playbook -i inventories/hosts playbooks/bootstrap_cluster_teardown.yml
```