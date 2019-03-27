# Ansible Tower Bootstrap Container

This folder contains instructions on how to build the tower bootstrapping container, which includes the following packages: ansible, python-pip and tower-cli

## Building

Build the image:

```
docker build -t quay.io/integreatly/tower-bootstrap .
``` 

Push it:

```
docker push quay.io/integreatly/tower-bootstrap
```