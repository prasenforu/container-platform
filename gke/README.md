### Google Kubenetes Cluster (GKE) Setup

#### Install

```
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-f

gcloud container clusters create pk-kube-11174-rbac-gap --cluster-version 1.11.7-gke.4 --machine-type "custom-1-2560" --disk-type "pd-standard" --disk-size "50" --num-nodes 3 --preemptible --enable-autoscaling --min-nodes 3 --max-nodes 5 --no-enable-legacy-authorization
```

##### Verify

```
gcloud container clusters get-credentials pk-kube-11174-rbac-gap
gcloud compute instances list

kubectl create clusterrolebinding prasenforu-cluster-admin-binding --clusterrole=cluster-admin --user=prasenforu@gmail.com
```


#### Monitoring GAP

###### Step 1# Clone the repositories

```git clone https://github.com/coreos/prometheus-operator.git```

###### Step 2# Edit file (prometheus-serviceMonitorKubelet.yaml) in repo

```
cd prometheus-operator/contrib/kube-prometheus/manifests/
sed -i -e 's/https/http/g' prometheus-serviceMonitorKubelet.yaml
```

###### Step 3# Edit Grafana ```(grafana-service.yaml)```, Alertmanager ```(alertmanager-service.yaml)``` & Prometheus ```(prometheus-service.yaml)``` service files. with adding following line.

``` type: LoadBalancer```

Examples :

```
apiVersion: v1
kind: Service
metadata:
  labels:
    prometheus: k8s
  name: prometheus-k8s
  namespace: monitoring
spec:
  ports:
  - name: web
    port: 9090
    targetPort: web
  selector:
    app: prometheus
    prometheus: k8s
  sessionAffinity: ClientIP
  type: LoadBalancer
```

###### Step 4# Now deploy yamls fille.

```
cd
kubectl create -f prometheus-operator/contrib/kube-prometheus/manifests/
```

###### Step 5# Verify GAP
```kubectl get pods -n monitoring```

