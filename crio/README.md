# Kubeadm with CRI-O
Setting up kubernetes cluster with container runtime interface CRIO

## Prerequisites
Vagrant, VirtualBox provider. Use Vagrantfile for infrastructure provisioning.

## Cluster setup
After VMs are ready, run master.sh script on controlplane/master node and worker.sh on worker node. Avoid running worker.sh before master.sh finishes execution.

## Setup kubectl cli
To make kubectl work properly, run below command on controlplane node 
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```
