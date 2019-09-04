## Kubernetes cluster certificates renew

The Kubernetes cluster certificates have a lifespan of one year. If the Kubernetes cluster certificate expires on the Kubernetes master, then the kubelet service will fail. Issuing a kubectl command, such as kubectel get pods or kubectl exec -it container_name bash, will result in a message similar to Unable to connect to the server: x509: certificate has expired or is not yet valid.

### Verification

```openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt```

### Backup

Take a backup of your existing certificates

```cp -rf /etc/kubernetes /opt/```

### Procedure

To regenerate a new certificate and update worker nodes:

#### Step #1

Serach for ```kubeadm.yaml``` MasterConfiguration file 

#### Step #2

Remove the existing certificate and key files

```rm /etc/kubernetes/pki/{apiserver*,front-proxy-client*}```

#### Step #3

Create new certificates

```kubeadm --config <PATH of kubeadm.yaml file> alpha phase certs all```

#### Step #4

Remove the old configuration files

```
rm /etc/kubernetes/admin.conf
rm /etc/kubernetes/kubelet.conf
rm /etc/kubernetes/controller-manager.conf
rm /etc/kubernetes/scheduler.conf
```

#### Step #5

Generate new configuration files

```kubeadm --config <PATH of kubeadm.yaml file> alpha phase kubeconfig all```

#### Step #6

Ensure that your kubectl service is using the correct configuration files

```
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
export KUBECONFIG=.kube/config
```

#### Step #7

Check and ensure that the kubelet service is running

```systemctl status kubelet```

#### Step #8

Verify with kubectl command

```kubectl get nodes```

#### Step #8

Reboot the Kubernetes master node.

```reboot```

### Note: If its HA cluster (3 Master) do same above steps for rest of all master servers.

