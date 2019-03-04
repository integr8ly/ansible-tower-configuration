# Integreatly Ansible Tower Container

This folder container the linux container source code that contains _oc_ and _tower-cli_ utilities.

## Building

Build the image:

```
docker build -t quay.io/integreatly/ansible-tower-container:dev .
``` 

Push it:

```
docker push quay.io/integreatly/ansible-tower-container:dev
```

## Usage

To use this container, use it to replace the images inside the _ansible-tower_ pod in an Ansible Tower installation.
