# Container As A Service (CAAS) with Docker and Kubernetes

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying Docker and Kubernetes on the Amazon Web Services (AWS) cloud. 

## Docker, Kubernetes & AWS Architecture

- Master: The host that contain Kubernetes  control components, including the API server and the controller manager server. The master manages nodes in its Kubernetes cluster and schedules pods to run on nodes.
- Hub: The host that contain Kubernetes Private registry, router. This server some people call as Infra Server. This server is important, we will point our wild card DNS “ec2-ip.nip.io”.
- Node1 and Node2: Nodes provide the runtime environments for containers. Each node in a Kubernetes cluster has the required services to be managed by the master. Nodes also have the required services to run pods, including Docker, a kubelet and a service proxy. 

image

## Prerequisites 
Before you deploy this Quick Start, we recommend that you become familiar with the following AWS services. (If you are new to AWS, see Getting Started with AWS.)

- Amazon Virtual Private Cloud (Amazon VPC)
- Amazon Elastic Compute Cloud (Amazon EC2)

It is assumes that familiarity with PaaS concepts and Red Hat OpenShift. For more information, see the Red Hat OpenShift documentation.

DNS is a requirement for OpenShift Enterprise. In fact most issues comes if you do not have properly working DNS environment.  As we are running in AWS so there is another complex because AWS use its own DNS server on their instances, we need to change make a separate DNS server and use in our environment.

In order to work properly Openshift require ```wild card DNS setup```. That you can setup with registered domain or you can use public ```(ec2-ip.nip.io)``` wild card DNS setup.


##### Setup Security Group

** OSE-Kube-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | 0.0.0.0/0 |
| Custom TCP | TCP | 6443 | 0.0.0.0/0 |
| DNS (UDP) | UDP | 53 | 0.0.0.0/0 |
| DNS (TCP) | TCP | 53 | 0.0.0.0/0 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |

### Install in all hosts (master & nodes)
```
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

# Install docker if you don't have it already.

apt-get install -y docker.io
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

systemctl enable docker;systemctl start docker
systemctl enable kubelet;systemctl start kubelet
```

### Install in master host
```
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<master private ip> | tee output.file

# Setup environment
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```
### Install in all (nodes) hosts
```
kubeadm join --token 80e1cd.558bc0a0ca2d2007 <master private ip>:6443
```

### Now Setup Cluster properly for use
```
## Flannel Network Setup

kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
kubectl create -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

## Kube Dashboard setup

kubectl create -f https://git.io/kube-dashboard

## Setting nodes with labels

kubectl label node <infra host ip> region="infra" zone="infranodes" --overwrite

kubectl label node <node1 host ip> region="primary" zone="east" --overwrite
kubectl label node <node2 host ip> region="primary" zone="west"

## Setting ingress 

kubectl create -f default-backend.yaml
kubectl create -f nginx-ingress-controller-rbac.yaml

```

## Setting Cockpit on Ubuntu 16.04:

```
add-apt-repository ppa:cockpit-project/cockpit
apt-get update
apt-get -y install cockpit
systemctl enable cockpit
systemctl start cockpit
```

### Troubleshooting
```
echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables
```

### Check status from master host and get console URL
```
  oc get nodes
  oc get all
```

### Exit container cleanup command

```
docker rm `docker ps -a | grep -v CONTAINER | grep Exited | awk '{print $1}'`
```

# Feedback

We'll love to hear feedback and ideas on how we can make it more useful. Just create an issue.

Thanks !!
