# Kubernetes basic authentication using CSV file


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

in ```command``` section

```- --basic-auth-file=/etc/kubernetes/auth.csv```

in ```volumeMounts``` section

```
    volumeMounts:
    - mountPath: /etc/kubernetes/auth.csv
      name: kubernetes-dashboard
      readOnly: true
```

in ```volumes``` section

```
  volumes:
  - hostPath:
      path: /etc/kubernetes/auth.csv
    name: kubernetes-dashboard
```

#### Step #3 Check API server pod UP & running

```kubectl get pod -n kube-system```

#### Step #4 Create following role/rolebindings/clusterrolebindings

vi test.yaml

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

