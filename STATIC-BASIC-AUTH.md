# Kubernetes static basic authentication using CSV file


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
