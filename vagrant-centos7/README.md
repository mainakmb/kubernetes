# Pre and Post Setup Instructions

I used __Vagrant__ and __VirtualBox__ for automated provisioning of centos7 nodes with prebuilt network configuration .
Please change the __network configuration__ accordingly to your own network infrastructure .
Please note that the password is __"superuser"__ for root ssh authentication, you can change it in __bootstrap.sh__ file . Look into __centos7-cluster.md__ for detailed approach . 

#### Download Vagrant

```
https://www.vagrantup.com/downloads.html
```
#### Download VirtualBox

```
https://www.virtualbox.org/wiki/Downloads
```
#### Installing Dashboard
Use __dashboard.yaml__ for installing dashboard into cluster
To setup dashboard servics account with login token perform the following
```
kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default  --clusterrole=cluster-admin  --serviceaccount=default:dashboard
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
```
Use the token output from kubectl get secret command for dashboard login
#### Installing Metrics Server
As we have our cluster in VM baremetal and so the config file for setting up metrics server is __metrics-server.yaml__
