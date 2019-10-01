# Kubernetes authentication & authorization

Authentication and authorization are two very important requirements when setting up a Kubernetes cluster. The basic authentication and authorization flow in a Kubernetes cluster can be understood from the following figure:

```
-------------------------------------------------------------------------------------------
| Kube Client  =>   API-SERVER    => Auth-Policy =>   Admission Control   => Allow Access |
|  (kubectl)     (https://IP:6443)     (RBAC)       (Policy Valification)                 |
|                 Authentication     Authorization                                        |
-------------------------------------------------------------------------------------------
```

There are following popular authentication methods available in Kubernetes ...

- Client Certificate Authentication
- Token based Authentication
- HTTP Basic Authentication
- Open ID

And Kubernetes supports following types of authorization method ..

- AlwaysDeny (This policy denies all the requests)
- AlwaysAllow (This policy allows all the requests)
- Node (a special-purpose authorization mode that specifically authorizes API requests made by kubelets)
- Attribute Based Access Control (ABAC - allows to configure policies using local files)
- Role Based Access Control (RBAC - allows to create and store policies using the Kubernetes API)
- Webhook (HTTP callback mode allows to manage authorization using a remote REST endpoint)

## HTTP Basic Authentication

#### Step #1 Create User & Password CSV file
Make sure content should be below format

```password,username,id```

```vi /etc/kubernetes/auth.csv```

- Example 

```
Welcome123,ltadmin,11
Devuser123,devuser,12
```
#### Step #2 Edit/update API server pod yaml
Make sure take a backup of api server pod yaml file

```vi /etc/kubernetes/manifests/kube-apiserver.yaml```

Add below content in /etc/kubernetes/manifests/kube-apiserver.yaml file

- in ```command``` section

```- --basic-auth-file=/etc/kubernetes/auth.csv```

- in ```volumeMounts``` section

```
    volumeMounts:
    - mountPath: /etc/kubernetes/auth.csv
      name: kubernetes-dashboard
      readOnly: true
```

- in ```volumes``` section

```
  volumes:
  - hostPath:
      path: /etc/kubernetes/auth.csv
    name: kubernetes-dashboard
```

#### Step #3 Check API server pod UP & running

```kubectl get pod -n kube-system```

#### Step #4 Create following role/rolebindings/clusterrolebindings file

```vi test.yaml```

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: user-read-view
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicationcontrollers", "replicationcontrollers/status", "replicasets", "pods", "pods/log", "pods/status", "services", "events"]
  verbs: ["get", "list", "watch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: user-read-view-binding
  namespace: default
subjects:
- kind: User
  name: devuser
  apiGroup: ""
roleRef:
  kind: Role
  name: user-read-view
  apiGroup: ""
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
subjects:
- kind: User
  name: ltadmin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin 
  apiGroup: rbac.authorization.k8s.io
```

#### Step #5 Download, update & deploy ```Kubernetes-dashoboard```

##### Download 

```wget https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml```

##### Edit

```vi kubernetes-dashboard.yaml```

- add following in ```service``` section above file (kubernetes-dashboard.yaml)

```
      nodePort: 32000
  type: NodePort
```  

- add following in ```deployment``` section above file (kubernetes-dashboard.yaml)

```
- --authentication-mode=basic
```

#### Step #6 Verify using login in  ```Kubernetes-dashoboard```

- Login with admin user (ltadmin)
- Create an app using image "mongo:latest"
- Verify its running
- Logout

Switch to deffierent user (devuser)

- Login with admin user (devuser)
- Verify PODs are running
- Try to delete POD
- Logout

"CREATE FROM TEXT INPUT"  use following..

```
apiVersion: v1
kind: Pod
metadata:
  name: mongo
  labels:
    name: mongo
    context: docker-chat
spec:
  containers:
    -
      name: mongo
      image: mongo:latest
      ports:
        -
          containerPort: 27017
```

## Certificate based Authentication

- Create a private key for your user. In this example, we will name the file devuser.key (devuser is user)

```openssl genrsa -out devuser.key 2048```

- Create a certificate sign request devuser.csr using the private key you just created (devuser.key in this example). 
Make sure you specify your username and group in the -subj section (CN is for the username and O for the group). 
As previously mentioned, we will use devuser as the name and devgroup as the group:

```openssl req -new -key devuser.key -out devuser.csr -subj "/CN=devuser/O=devgroup"```

Locate your Kubernetes cluster certificate authority (CA). This will be responsible for approving the request and generating the necessary certificate to access the cluster API. Its location is normally /etc/kubernetes/pki/. 

- Generate the final certificate devuser.crt by approving the certificate sign request, devuser.csr, you made earlier. 
Make sure you substitute the CA_LOCATION placeholder with the location of your cluster CA. In this example, the certificate will be valid for 500 days:

```openssl x509 -req -in devuser.csr -CA CA_LOCATION/ca.crt -CAkey CA_LOCATION/ca.key -CAcreateserial -out devuser.crt -days 500```

- Save both devuser.crt and devuser.key in a safe location (in this example we will use /home/devuser/.certs/)

```
cp devuser.crt /home/devuser/.certs/
cp devuser.key /home/devuser/.certs/
```

- Add a new context with the new credentials for your Kubernetes cluster. 

```
kubectl config set-credentials devuser --client-certificate=/home/devuser/.certs/devuser.crt  --client-key=/home/devuser/.certs/devuser.key
kubectl config set-context devuser-context --cluster=kube-cluster --namespace=default --user=devuser
```

#### Note: If we are using TOKEN based authentication we should NOT use step #5 ```- --authentication-mode=basic```, Instead of that we should use ```- --authentication-mode=token``` which is default.

###### https://www.youtube.com/watch?v=Izi1dOQD5m8
