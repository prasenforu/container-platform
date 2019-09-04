## Kubernetes cluster certificates renew

The Kubernetes cluster certificates have a lifespan of one year. If the Kubernetes cluster certificate expires on the Kubernetes master, then the kubelet service will fail. Issuing a kubectl command, such as kubectel get pods or kubectl exec -it container_name bash, will result in a message similar to Unable to connect to the server: x509: certificate has expired or is not yet valid.

### Verification

```openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt```

### Procedure

To regenerate a new certificate and update worker nodes:

#### Step #1

Serach for ```kubeadm.yaml``` MasterConfiguration file 

