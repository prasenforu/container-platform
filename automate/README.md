### Creating Configmap
```
oc create cm webhook-hooks-configmap -n monitoring --from-file=./hooks.json
oc create cm webhook-kubeconfig-configmap -n monitoring --from-file=./kubeconfig
oc create cm webhook-sn-configmap -n monitoring --from-file=./sn.sh
oc create cm webhook-autoscale-configmap -n monitoring --from-file=./autoscale.sh
oc create cm webhook-pod-restart-configmap -n monitoring --from-file=./pod-restart.sh
oc create cm webhook-keypem-configmap -n monitoring --from-file=./prasen.pem
oc create cm webhook-ocp-node-restart-configmap -n monitoring --from-file=./ocp-node-restart.sh
```

### Create a kubeconfig file to authenticate to a Kubernetes cluster.

#### Step 1

Make sure you can authenticate yourself to the cluster. That means you have a kubeconfig file that uses your personal account. 

```ls -al $HOME/.kube```2

#### Step 2

Create a service account (webhook)
To create a service account on Kubernetes, you can leverage kubectl and a service account spec. 

#### Step 3

Fetch the name of the secrets used by the service account, this can be found by using the following command:
And Note down the ```Mountable secrets``` information which has the name of the secret that holds the token

```kubectl describe serviceAccounts webhook```

#### Step 4

Fetch the token from the secret

Using the ```Mountable secrets``` value, you can get the token used by the service account. 
Run the following command to extract this information:

```kubectl describe secrets <Mountable secrets value>```

Note down the ```token``` value

#### Step 5

Get the certificate info for the cluster

Every cluster has a certificate that clients can use to encryt traffic. Fetch the certificate and write to a file by running this command. In this case, we are using a file name cluster-cert.txt

```
kubectl config view --flatten --minify > cluster-cert.txt

cat cluster-cert.txt
```

Copy two pieces of information from here ```certificate-authority-data``` and ```server```

#### Step 6

Create a kubeconfig file

```vi kubeconfig```

Replace below information gathered so far

- token
- certificate-authority-data
- server
