### Goolge Kubenetes Cluster (GKE) Setup

#### Install

```
gcloud config set compute/zone us-central1-f
gcloud config set compute/region us-central1

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

###### Step 2# Edit couple file in repo

```
cd prometheus-operator/contrib/kube-prometheus/manifests/
sed -i -e 's/https/http/g' prometheus-serviceMonitorKubelet.yaml
```

Edit Grafana ```(grafana-service.yaml)```, Alertmanager ```(alertmanager-service.yaml)``` & Prometheus ```(prometheus-service.yaml)``` service files. with adding following line.

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

