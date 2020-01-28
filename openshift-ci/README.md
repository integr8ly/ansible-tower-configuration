## OpenShift CI

### Dockerfile.tools

Base image used on CI for all builds and test jobs. See [here](https://github.com/integr8ly/ci-cd/blob/master/openshift-ci/README.md) for more information on creating and deploying a new image.

#### Build and Test

```
$ docker build -t registry.svc.ci.openshift.org/integr8ly/ansible-tower-base-image:latest - < Dockerfile.tools
$ IMAGE_NAME=registry.svc.ci.openshift.org/integr8ly/ansible-tower-base-image:latest test/run
ansible-playbook 2.9.2
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.5 (default, Aug  7 2019, 00:51:29) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
ansible-lint 3.5.1
SUCCESS!
```
