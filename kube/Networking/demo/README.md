# Kubernetes Network policy test
Before using Network Policy, we first verify that the pod is interoperable if it is not used. Here our test environment is this:

- Namespace: ns-demo1, ns-demo2, ns-demo3
- Deployment: ns-demo1 / demo1-nginx, ns-demo2 / busybox, ns-demo3 / busybox
- Service: ns-demo1 / demo1-nginx

### 1. First create Namespace:

```
# kubectl create -f ns-demo1.yml
namespace "ns-demo1" created
# kubectl create -f ns-demo2.yml
namespace "ns-demo2" created
# kubectl create -f ns-demo3.yml
namespace "ns-demo3" created
# kubectl get ns
NAME          STATUS    AGE
default       Active    9d
kube-public   Active    9d
kube-system   Active    9d
ns-demo1    Active    12s
ns-demo2    Active    8s
ns-demo3    Active    5s
```
### 2. Create demo1-nginx deployment under namespace ```ns-demo1```

```
# kubectl create -f deployment-demo1-nginx.yml
deployment "demo1-nginx" created
service "demo1-nginx" created
# kubectl get svc -n ns-demo1
NAME          CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
demo1-nginx   10.108.133.64   <none>        80/TCP    41s
# kubectl get pod -o wide -n ns-demo1
NAME                           READY     STATUS    RESTARTS   AGE       IP            NODE
demo1-nginx-3342339170-bnszn   1/1       Running   0          1m        10.244.1.31   kube-hub.cloud-cafe.in
# kubectl create -f demo1-busybox-without-label.yml
pod "demo1-busybox-without-labels" created
# kubectl get pod -o wide -n ns-demo1
NAME                           READY     STATUS    RESTARTS   AGE       IP            NODE
demo1-busybox-without-labels   1/1       Running   0          32s       10.244.1.32   kube-hub.cloud-cafe.in
demo1-nginx-3342339170-bnszn   1/1       Running   0          3m        10.244.1.31   kube-hub.cloud-cafe.in
```
### 3. Create demo2-busybox pod under namespace ```ns-demo2```

```
# kubectl create -f demo2-busybox.yml
pod "demo2-busybox" created
# kubectl get pod -o wide -n ns-demo2
NAME            READY     STATUS    RESTARTS   AGE       IP            NODE
demo2-busybox   1/1       Running   0          6s        10.244.1.33   kube-hub.cloud-cafe.in
```
### 4. Test service has been installed, and now we board demo2-busybox to see if it can connect demo1-nginx, interconnect from different namespaces.

```
# kubectl exec -it demo2-busybox -n ns-demo2 -- wget --spider --timeout=1 demo1-nginx.ns-demo1
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)
# kubectl exec -it demo1-busybox-without-labels ping 10.244.1.31 -n ns-demo1
PING 10.244.1.31 (10.244.1.31): 56 data bytes
64 bytes from 10.244.1.31: seq=0 ttl=63 time=0.109 ms
64 bytes from 10.244.1.31: seq=1 ttl=63 time=0.071 ms
64 bytes from 10.244.1.31: seq=2 ttl=63 time=0.070 ms
# kubectl exec -it demo2-busybox ping 10.244.1.31 -n ns-demo2
PING 10.244.1.31 (10.244.1.31): 56 data bytes
64 bytes from 10.244.1.31: seq=0 ttl=63 time=0.078 ms
64 bytes from 10.244.1.31: seq=1 ttl=63 time=0.071 ms
64 bytes from 10.244.1.31: seq=2 ttl=63 time=0.069 ms

```

You can see in the absence of network isolation when the two different Namespace Pod can be interoperable.

Now we are going to add network policy.

### 5. First, modify the namespace configuration of ```ns-demo1```
   
```
# kubectl annotate ns ns-demo1 "net.beta.kubernetes.io/network-policy={\"ingress\": {\"isolation\": \"DefaultDeny\"}}"
```

### 6. Lets see if this time to test whether the two pod connectivity from same namespace ```ns-demo1``` as well as different namespace ```ns-demo2``` 

```
# kubectl exec -it demo2-busybox -n ns-demo2 -- wget --spider --timeout=1 demo1-nginx.ns-demo1                
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)
wget: download timed out

# kubectl exec -it demo1-busybox-without-labels -n ns-demo1 -- wget --spider --timeout=1 demo1-nginx.ns-demo1
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)
wget: download timed out

# kubectl exec -it demo2-busybox ping 10.244.1.31 -n ns-demo2                                                 
PING 10.244.1.31 (10.244.1.31): 56 data bytes
^C
--- 10.244.1.31 ping statistics ---
6 packets transmitted, 0 packets received, 100% packet loss

# kubectl exec -it demo1-busybox-without-labels ping 10.244.1.31 -n ns-demo1                                  
PING 10.244.1.31 (10.244.1.31): 56 data bytes
^C
--- 10.244.1.31 ping statistics ---
7 packets transmitted, 0 packets received, 100% packet loss

```

It will not work.

This is what we want the effect of different Namespace between the pod should not communicate, of course, this is only the most simple case, if this time ns-demo1 pod to connect ns-demo2 pod, or interoperability. Because ns-demo2 does not set Namespace annotations.

Also, this time ns-demo1 will reject any pod's communication request. Because, Namespace annotations just specify the rejection of all communication requests, and does not specify when to accept other pod communication requests.

### 7. Now we are going to setup network policy for pod to allow network connection. Here, we specify that only pods with user = demo1 tags can be interconnected.

```
# kubectl create -f demo1-network-policy.yml
networkpolicy "demo1-network-policy" created
# kubectl create -f demo1-busybox.yaml
pod "demo1-busybox" created
```

### 8. At this time, if I connect demo1-nginx through demo1-busybox-without-labels, you can see its connected.

```
# kubectl exec -it demo1-busybox-without-labels -n ns-demo1 -- wget --spider --timeout=1 demo1-nginx.ns-demo1
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)

```
But we can not comminucate from different namespace ```ns-demo2```

```
# kubectl exec -it demo2-busybox -n ns-demo2 -- wget --spider --timeout=1 demo1-nginx.ns-demo1
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)
wget: download timed out

kubectl exec -it demo2-busybox ping 10.244.1.31 -n ns-demo2
PING 10.244.1.31 (10.244.1.31): 56 data bytes
^C
--- 10.244.1.31 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss
```

### 9. Now are are going to create another container in different namespace and create network policy to allow isolated namespace.

```
# oc create -f demo3-busybox.yml
pod "demo3-busybox" created

# kubectl exec -it demo3-busybox -n ns-demo3 -- wget --spider --timeout=1 demo1-nginx.ns-demo1
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)
wget: download timed out
```

As you can see its from different namespace so its not allowing to connect.

Now applying network policy to allow connection from namespace ```ns-demo3``` to ```ns-demo1```

```
# kubectl create -f demo3-network-policy.yml
networkpolicy "demo3-network-policy" created
```
Now its allowing connection from namespace ```ns-demo3``` to ```ns-demo1```

```
# kubectl exec -it demo3-busybox -n ns-demo3 -- wget --spider --timeout=1 demo1-nginx.ns-demo1
Connecting to demo1-nginx.ns-demo1 (10.108.133.64:80)
```

So that we realized Kubernetes' network isolation. Based on Network Policy, you can implement a public cloud security group policy.

#### At the end you can delete entire deployment

```
for yml in *.yml; do
  oc delete -f \"${yml}\"
done
```

