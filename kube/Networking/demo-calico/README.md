# Calico Policy Demo
![Alt text](https://github.com/prasenforu/container-platform/blob/master/kube/Networking/demo-calico/demo-calico.png "Overview")

## Lets start !!

Before using check any Network Policy in used. And make sure on host ```172.31.18.58``` MYSQL Database should run on port ```3306``` & ```3307```

Here is command to run mysql database as a container on host ```172.31.18.58```

```
docker run --name mysqldb-3306 -d -p 3306:3306 -e 'MYSQL_PASS=mypassword' prasenforu/mysql-db:1.0
docker run --name mysqldb-3307 -d -p 3307:3306 -e 'MYSQL_PASS=mypassword' prasenforu/mysql-db:1.0
```

- Namespace: ```allow3306, allow3307, denydball, test-db```
- Deployment: ```demodb```, ```App-A-allow3307```, ```App-B-allow3306```, ```Web-server-deny-db-all```

### 1. First create Namespace:

```
# kubectl create ns allow3306 allow3307 denydball test-db

# kubectl create ns allow3307

# kubectl create ns denydball

# kubectl create ns test-db

# kubectl get ns
NAME          STATUS    AGE
allow3306     Active    20h
allow3307     Active    20h
default       Active    2d
denydball     Active    20h
kube-public   Active    2d
kube-system   Active    2d
test-db       Active    1d
```
### 2. Create demodb deployment under namespace ```test-db```

```
# kubectl create -f demodb.yml
```
### 3. Create App-A-allow3307 deployment under namespace ```allow3307```

```
# kubectl create -f App-A-allow3307.yml
```
### 4. Create App-B-allow3306 deployment under namespace ```allow3306```

```
# kubectl create -f App-B-allow3306.yml
```

### 5. Create Web-server-deny-db-all deployment under namespace ```denydball```

```
# kubectl create -f Web-server-deny-db-all.yml
```

### 6. Make sure all containers are running perfectly

### As there was no policy implemented so form AppA, AppB & Web-Server to all (external & internal) db can connect, below URL for testing.

```
http://app-a-allow3307.cloudapps.cloud-cafe.in/connectdbout.php
http://app-a-allow3307.cloudapps.cloud-cafe.in/connectdbout1.php
http://app-a-allow3307.cloudapps.cloud-cafe.in/connectdbin.php

http://app-b-allow3306.cloudapps.cloud-cafe.in/connectdbout.php
http://app-b-allow3306.cloudapps.cloud-cafe.in/connectdbout1.php
http://app-b-allow3306.cloudapps.cloud-cafe.in/connectdbin.php

http://web-server.cloudapps.cloud-cafe.in/connectdbin.php
http://web-server.cloudapps.cloud-cafe.in/connectdbout.php
http://web-server.cloudapps.cloud-cafe.in/connectdbout1.php
```

### 7. Now we are going to setup calico policy from AppA & AppB to all (external & internal) db allow/deny network connection.

```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl apply -f - <<EOF
- apiVersion: v1
  kind: policy
  metadata:
    name: egress-allow-from-allow3306-to-external-db-3306
  spec:
    egress:
    - action: allow
      protocol: udp
      destination:
        selector: calico/k8s_ns == 'kube-system' && k8s-app=='kube-dns'
        ports:
        - 53
    - action: allow
      protocol: tcp
      destination:
        selector: calico/k8s_ns == 'test-db'
        ports:
        - 3306
    - action: allow
      protocol: tcp
      destination:
        net: 172.31.18.58/32
        ports:
        - 3306
    order: 500
    Selector: calico/k8s_ns == 'allow3306'
- apiVersion: v1
  kind: policy
  metadata:
    name: egress-allow-from-allow3307-to-external-db-3307
  spec:
    egress:
    - action: allow
      protocol: udp
      destination:
        selector: calico/k8s_ns == 'kube-system' && k8s-app=='kube-dns'
        ports:
        - 53
    - action: allow
      protocol: tcp
      destination:
        selector: calico/k8s_ns == 'test-db'
        ports:
        - 3306
    - action: allow
      protocol: tcp
      destination:
        net: 172.31.18.58/32
        ports:
        - 3307
    order: 501
    Selector: calico/k8s_ns == 'allow3307'
EOF
```

### 8. At this time, now execute below URL, check which URL coming timout

```
http://app-a-allow3307.cloudapps.cloud-cafe.in/connectdbout.php      -- it should work (it will connect external DB on port 3307)
http://app-a-allow3307.cloudapps.cloud-cafe.in/connectdbout1.php     -- it should fail (it try to connect external DB on port 3306)
http://app-a-allow3307.cloudapps.cloud-cafe.in/connectdbin.php       -- it should work (it will connect container DB)

http://app-b-allow3306.cloudapps.cloud-cafe.in/connectdbout.php      -- it should fail (it try to connect external DB on port 3307)
http://app-b-allow3306.cloudapps.cloud-cafe.in/connectdbout1.php     -- it should work (it will connect external DB on port 3306)
http://app-b-allow3306.cloudapps.cloud-cafe.in/connectdbin.php       -- it should work (it will connect container DB)

http://web-server.cloudapps.cloud-cafe.in/connectdbin.php            -- As no policy implemented, it should work
http://web-server.cloudapps.cloud-cafe.in/connectdbout.php           -- As no policy implemented, it should work
http://web-server.cloudapps.cloud-cafe.in/connectdbout1.php          -- As no policy implemented, it should work

```

### 9. Now are are going to block all db (internal & external) from Web Server, using below policy

```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl apply -f - <<EOF
- apiVersion: v1
  kind: policy
  metadata:
    name: egress-deny-from-denydball-to-all-db
  spec:
    egress:
    - action: allow
      protocol: udp
      destination:
        selector: calico/k8s_ns == 'kube-system' && k8s-app=='kube-dns'
        ports:
        - 53
    - action: deny
      protocol: tcp
      destination:
        selector: calico/k8s_ns == 'test-db'
        ports:
        - 3306
    - action: deny
      protocol: tcp
      destination:
        net: 172.31.18.58/32
        ports:
        - 3307
    - action: deny
      protocol: tcp
      destination:
        net: 172.31.18.58/32
        ports:
        - 3306
    order: 502
    Selector: calico/k8s_ns == 'denydball'
EOF
```

### 10. At this time, now execute below URL, expected URL coming timout

```
http://web-server.cloudapps.cloud-cafe.in/connectdbin.php            -- it should fail (it will connect container DB)
http://web-server.cloudapps.cloud-cafe.in/connectdbout.php           -- it should fail (it try to connect external DB on port 3306)
http://web-server.cloudapps.cloud-cafe.in/connectdbout1.php          -- it should fail (it try to connect external DB on port 3307)

```
#### Check list of policy
```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl get policy
```
#### Delete policys
```
kubectl exec -ti -n kube-system calicoctl -- /calicoctl delete policy egress-allow-from-allow3306-to-external-db-3306
kubectl exec -ti -n kube-system calicoctl -- /calicoctl delete policy egress-allow-from-allow3307-to-external-db-3307
kubectl exec -ti -n kube-system calicoctl -- /calicoctl delete policy egress-deny-from-denydball-to-all-db
```

#### At the end you can delete entire deployment

```
for yml in *.yml; do
  kubectl delete -f \"${yml}\"
done
```

