## OCP in AWS ubuntu single host

#### Download packages
```
apt-get update && apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
```

#### Install & start docker
```
apt-get install -y docker.io
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

systemctl enable docker;systemctl start docker
echo 'DOCKER_OPTS="--insecure-registry 172.30.0.0/16"' | sudo tee -a /etc/default/docker
systemctl restart docker
```

#### Download oc client
```
wget https://github.com/openshift/origin/releases/download/v1.5.0/openshift-origin-client-tools-v1.5.0-031cbe4-linux-64bit.tar.gz
tar zxvf openshift-origin-client-tools-v1.5.0-031cbe4-linux-64bit.tar.gz
mv openshift-origin-client-tools-v1.5.0-031cbe4-linux-64bit ocp
cp ocp/oc /usr/local/bin/
```

#### Start Openshift Cluster
```
oc cluster up --public-hostname=<EC2-PUBLIC-IP> --routing-suffix=<EC2-PUBLIC-IP>.nip.io
```

#### Install HTPASSWORD enable for Openshift Cluster
```
apt-get install apache2-utils
htpasswd -cb users.htpasswd admin admin2675
oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm policy add-scc-to-user anyuid -z default
```

#### Troubleshotting
oc deploy router --retry
oc deploy docker-registry --retry
