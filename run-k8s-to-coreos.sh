#!/bin/bash

# Set CNI version to use
CNI_VERSION="v0.7.5"

# Set CRI version to use
CRICTL_VERSION="v1.12.0"

#
# INSTALL CNI
#

# Create folder
mkdir -p /opt/cni/bin

# Download and install CNI
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

#
# INSTALL CRI
#

# Create folder
mkdir -p /opt/bin

# Download and install CNI
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

#
# INSTALL KUBEADM, KUBECTL, KUBELET
#

# Get release version
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

# Install kubeadm, kubelet, kubectl
cd /opt/bin && curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

# Set up systemd services for kubelet
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service

mkdir -p /etc/systemd/system/kubelet.service.d

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Replace 10-kubeadm.conf with modified one
curl -sSL "URL" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Run Kubelet service
systemctl enable --now kubelet

#
# CREATE CLUSTER
#

# Initialize Kubernetes cluster
kubeadm init --pod-network-cidr=192.168.0.0/16

# Follow post-installation instructions from previous command
# Don't forget to add Kubernetes configuration to ~/.kube/config

# Download, customize and apply Calico configuration to pass CoreOS limitations
curl -sSL "https://docs.projectcalico.org/v3.8/manifests/calico.yaml" | sed "s:/usr/libexec/kubernetes/kubelet-plugins/volume/exec/nodeagent~uds:/var/lib/kubelet/volume-plugins/nodeagent~uds:g" > calico.yaml
kubectl apply -f calico.yaml

# Create user with full access
kubectl create -n kube-system serviceaccount administrator

# Download and apply admin binding policy
curl -sSL "URL" > create-administrator.yaml
kubectl apply -f create-administrator.yaml

# You can get authentication token with
# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep administrator | awk '{print $1}')

# Download and install Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
