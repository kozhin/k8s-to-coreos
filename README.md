# Kubernetes on CoreOS

Simple script for Kubernetes master node setup on running CoreOS instance.

## Before running

1. Set proper hostname with `hostnamectl set-hostname SOME_HOST_NAME` and restart CoreOS
2. Remove SWAP if was previously enabled
3. Add your SSH keys with `echo 'PUBLIC_KEY_STRING' | update-ssh-keys -a USER_NAME`

## Installation

Use root account to run `run-k8s-to-coreos.sh` script.

## After installation

Add new nodes, connect k8s with GitLab, deploy you apps :)
