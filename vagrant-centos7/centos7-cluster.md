# Setup Kubernetes Cluster using kubeadm bootstraping
Documentation to set up a Kubernetes cluster on __CentOS 7__

## Prerequisites
2 or More CentOS_7 servers containing atleast __2 Cores and 2GB of RAM__ for clustering 

## On both KMaster Node and KWorker Node
Perform all the commands as root user in the server

##### Disable Firewall
```
systemctl disable firewalld; systemctl stop firewalld
```
##### Disable swap
```
swapoff -a; sed -i '/swap/d' /etc/fstab
```
##### Install containerd CRI
```
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y && sudo yum install -y containerd.io
sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo systemctl restart containerd
```
### Kubernetes Setup
##### Add yum repository
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```
##### Disable SELinux
```
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```
##### Install Kubernetes components
```
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```
##### Enable and Start kubelet service
```
systemctl enable --now kubelet
```
## On KMaster
##### Initialize Kubernetes Cluster
```
kubeadm init --apiserver-advertise-address=172.16.1.101
```
##### Deploy Calico pod network (CNI)
```
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.16/manifests/calico.yaml
```
##### Cluster node join command
```
kubeadm token create --print-join-command
```
##### To be able to run kubectl commands as root or non-root user
If you want to be able to run kubectl commands as non-root user, then as a non-root user perform these
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```
To run kubectl commands as root user then run following command
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```
## On KWorker
##### Join the cluster
Use the output from __kubeadm token create__ command in previous step from the master node or the token generated while initializing cluster and run here.

## Verifying the cluster
##### Get Nodes status
```
kubectl get nodes
```
##### Get pod status
```
kubectl get pods --all-namespaces
```

Thats done for you !!
