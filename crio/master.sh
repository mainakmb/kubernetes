#!/bin/bash

OS=xUbuntu_20.04
VERSION=1.20

echo "[TASK 1] Disabling and Turning off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stopping and Disabling Firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Enabling and Loading Kernel Modules"
cat >>/etc/modules-load.d/crio.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 4] Adding Kernel Settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[TASK 5] Installing CRI-O Runtime"
cat >>/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list<<EOF
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
cat >>/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list<<EOF
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add - >/dev/null 2>&1
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers-cri-o.gpg add - >/dev/null 2>&1
apt update -qq >/dev/null 2>&1
apt install -qq -y cri-o cri-o-runc cri-tools >/dev/null 2>&1
cat >>/etc/crio/crio.conf.d/02-cgroup-manager.conf<<EOF
[crio.runtime]
conmon_cgroup = "pod"
cgroup_manager = "cgroupfs"
EOF
systemctl daemon-reload
systemctl enable --now crio >/dev/null 2>&1

echo "[TASK 6] Adding repo for Kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[TASK 7] Installing Kubernetes Components (kubeadm, kubelet, kubectl)"
apt install -qq -y kubeadm=1.20.5-00 kubelet=1.20.5-00 kubectl=1.20.5-00 >/dev/null 2>&1

echo "[TASK 8] Initializing Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.16.1.101 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[TASK 9] Generateing and Saving Cluster join command to clusterjoin.sh"
cat /root/kubeinit.log | tail -2 > /root/clusterjoin.sh 2>/dev/null

echo "[TASK 10] Deploy CNI plugin"
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" >/dev/null 2>&1
