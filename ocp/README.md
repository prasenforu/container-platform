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
htpasswd -cb /root/users.htpasswd admin admin2675
```
###### After Installation all configuration stores in ```\var\lib\origin\openshift.local.config\```. 
###### Edit ```master\master-config.yaml``` file as follows & mention ```users.htpasswd``` file location properly.
```
identityProviders:
 - name: my_htpasswd_provider
 challenge: true
 login: true
 mappingMethod: claim
 provider:
 apiVersion: v1
 kind: HTPasswdPasswordIdentityProvider
 file: /root/users.htpasswd
```
#### Restart Openshift Cluster
```
oc cluster down
oc cluster up --public-hostname=<EC2-PUBLIC-IP> --routing-suffix=<EC2-PUBLIC-IP>.nip.io
oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin
# Gives the default service account in the current project access to run as UID 0 (root)
oc adm policy add-scc-to-user anyuid -z default
```

#### Troubleshotting

##### Issue
When you execute ```oc get pod``` in ```default``` namespace you will find that router and docker registry not running.
To resolve the issue please execute following commands.
```
oc deploy router --retry
oc deploy docker-registry --retry
```
