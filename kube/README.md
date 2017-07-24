# Container As A Service (CAAS) with Docker and Kubernetes

## Overview
This Quick Start reference deployment guide provides step-by-step instructions for deploying Docker and Kubernetes on the Amazon Web Services (AWS) cloud. 

## Docker, Kubernetes & AWS Architecture

- DNS: The host that contain Red Hat OpenShift control components, including the API server and the controller manager server. The master manages nodes in its Kubernetes
- Master: The host that contain Kubernetes  control components, including the API server and the controller manager server. The master manages nodes in its Kubernetes cluster and schedules pods to run on nodes.
- Hub: The host that contain Kubernetes Private registry, router. This server some people call as Infra Server. This server is important, we will point our wild card DNS “cloudapps.cloud-cafe.in” in godaddy.in in my domain configuration.
- Node1 and Node2: Nodes provide the runtime environments for containers. Each node in a Kubernetes cluster has the required services to be managed by the master. Nodes also have the required services to run pods, including Docker, a kubelet and a service proxy. 

image

## Prerequisites 
Before you deploy this Quick Start, we recommend that you become familiar with the following AWS services. (If you are new to AWS, see Getting Started with AWS.)

- Amazon Virtual Private Cloud (Amazon VPC)
- Amazon Elastic Compute Cloud (Amazon EC2)

It is assumes that familiarity with PaaS concepts and Red Hat OpenShift. For more information, see the Red Hat OpenShift documentation.
If you want to access publically your openshift then you need registered domain. Here I use my domain (cloud-café.in) which I purchase from godaddy.in


##### Step #4	Setup Security Group

** OSE-DNS-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | 0.0.0.0/0 |
| Custom TCP | TCP | 8443 | 10.90.0.0/16 |
| DNS (UDP) | UDP | 53 | 10.90.0.0/16 |
| DNS (TCP) | TCP | 53 | 10.90.0.0/16 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |
| All ICMP | All | N/A | 10.90.0.0/16 |

 ** OSE-MASTER-SG **
 
| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| Custom UDP | UDP | 10250 | 10.90.0.0/16 |
| HTTP | TCP | 80 | 0.0.0.0/0  |
| Custom TCP | TCP | 4789 | 10.90.0.0/16 |
| SSH | TCP | 22 | OSE-DNS-SG  |
| Custom TCP | TCP | 8443 | 0.0.0.0/0 |
| Custom TCP | TCP | 6443 | 0.0.0.0/0 |
| Custom UDP | UDP | 2049 | 10.90.0.0/16 |
| Custom TCP | TCP | 10250 | 10.90.0.0/16 |
| DNS (UDP) | UDP | 53 | 10.90.0.0/16 |
| DNS (TCP) | TCP | 53 | 10.90.0.0/16 |
| Custom UDP | UDP | 4789 | 10.90.0.0/16 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| All ICMP | All | N/A | 10.90.0.0/16 |
| NFS | TCP | 2049 | 10.90.0.0/16 |

** OSE-HUB-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| Custom UDP | UDP | 10250 | 10.90.0.0/16 |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| Custom TCP | TCP | 4789 | 10.90.0.0/16 |
| SSH | TCP | 22 | OSE-DNS-SG |
| Custom TCP | TCP | 8443 | 10.90.0.0/16 |
| Custom UDP | UDP | 2049 | 10.90.0.0/16 |
| Custom TCP | TCP | 10250 | 10.90.0.0/16 |
| DNS (UDP) | UDP | 53 | 10.90.0.0/16 |
| DNS (TCP) | TCP | 53 | 10.90.0.0/16 |
| Custom UDP | UDP | 4789| 10.90.0.0/16 |
| HTTPS| TCP | 443 | 0.0.0.0/0 |
| All ICMP | All | N/A | 10.90.0.0/16 |
| NFS | TCP | 2049 | 10.90.0.0/16 |

** OSE-NODE-SG **

| Type | Protocol | Port Range | Source |
| ------ | ------ | ------ | ------ |
| Custom UDP | UDP | 10250 | 10.90.0.0/16 |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| Custom TCP | TCP | 4789 | 10.90.0.0/16 |
| SSH | TCP | 22 | OSE-DNS-SG |
| Custom TCP | TCP | 8443 | 10.90.0.0/16 |
| Custom UDP | UDP | 2049 | 10.90.0.0/16 |
| Custom TCP | TCP | 10250 | 10.90.0.0/16 |
| DNS (UDP) | UDP | 53 | 10.90.0.0/16 |
| DNS (TCP) | TCP | 53 | 10.90.0.0/16 |
| Custom UDP | UDP | 4789 | 10.90.0.0/16 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| All ICMP | All | N/A | 10.90.0.0/16 |
| NFS | TCP | 2049 | 10.90.0.0/16 |


## Deployment Steps

DNS is a requirement for OpenShift Enterprise. In fact most issues comes if you do not have properly working DNS environment.  As we are running in AWS so there is another complex because AWS use its own DNS server on their instances, we need to change make a separate DNS server and use in our environment.

### Preparation of custom DNS Environment in AWS

1.	Go to your VPC
2.	Choose your VPC from “Filter by VPC:”
3.	Click “DHCP Option Sets”
4.	Create DHCP Option Set 
5.	Give your domain name “cloud-café-in” in Domain name
6.	Give DNS server IP in Domain name servers.
7.	You can set NTP servers on same DNS server, give DNS server IP in NTP servers (optional).

### Now activate your DNS server for your VPC

1.	Now go to your VPC
2.	Choose your VPC from “Filter by VPC:”
3.	Click “Your VPCs”
4.	Select Openshift-VPC
5.	Click Action
6.	Then “Edit DHCP Option Set “
7.	Then Select what you created from earlier.

### Now launch an EC2 in Public Subnet with 10.90.1.78 ip 

Add below content in user data in Advance section.
```
#!/bin/bash
echo nameserver 8.8.8.8 >> /etc/resolv.conf
yum install git unzip -y
```

Once DNS host is up and running, login on that dns host and make ready dns host for staring installation

### Clone packeges 
```
git clone https://github.com/prasenforu/caas.git
cd caas
```
### Add EC2 key-pair (add pem key content to prasen.pem file) & change prmission

```
chmod 400 prasen.pem
chmod 755 *.sh
```
### Edit install-aws-cli.sh (Add access-key & secret-access-key)

#### 1.	Setup DNS
```
	./setup-dns.sh
	reboot dns host
```
#### 2.	Install AWS CLI for Instance creation & Management
	Add access-key, secret-access-key & region in this file.
```
	./install-aws-cli.sh
```
#### 3. 	Now launch master, hub and nodes instance, there are two way.

###### a.	From console launch following instances with below details.

| Host | Private IP | Public IP | Security Group | Subnet |
| ------ | ------ | ------ | ------ | ------ |
| ose-master | 10.90.1.208 | Yes | OSE-MASTER-SG | Public |
| ose-hub | 10.90.1.209 | Yes |	OSE-HUB-SG | Public |
| ose-node1 | 10.90.2.210 | No | OSE-NODE-SG | Private |
| ose-node2 | 10.90.2.211 | No | OSE-NODE-SG | Private |

### OR

###### b. 	Create Instances (Master, Hub, Node1 & Node2) using AWS CLI
	You Can change script based on your requirement.
	(Type of host, volume size, etc.)
	
```
	./instance-creation.sh
```
#### 4. 	This script will do passwordless login & prepare all hosts
	### Note: Before running this script make sure you add your key-pair content in prasen.pem file
	
```
	./next-step1.sh 
```
#### 5.	This script will install & update packages and prepare docker storage in different volume
```
	./install-docker-storage.sh
```
#### 6.	Starting Kubernetes Installation 
```
	./start-kube-installation.sh
```
#### 7.	After Kubernetes Installation, there few setup need to make environment ready

	
	### Note: This script need to run from ose-master host
	
```
	ssh ose-master
	./post-kube-setup.sh
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

#### For security reason, you can delete access-key, secret-access-key and pem files

```
rm ~/.aws/config install-aws-cli.sh prasen.pem

```

# Feedback

We'll love to hear feedback and ideas on how we can make it more useful. Just create an issue.

Thanks !!
