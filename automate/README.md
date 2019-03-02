oc create cm webhook-hooks-configmap -n monitoring --from-file=./hooks.json
oc create cm webhook-kubeconfig-configmap -n monitoring --from-file=./kubeconfig
oc create cm webhook-sn-configmap -n monitoring --from-file=./sn.sh
oc create cm webhook-autoscale-configmap -n monitoring --from-file=./autoscale.sh
oc create cm webhook-pod-restart-configmap -n monitoring --from-file=./pod-restart.sh
oc create cm webhook-keypem-configmap -n monitoring --from-file=./prasen.pem
oc create cm webhook-ocp-node-restart-configmap -n monitoring --from-file=./ocp-node-restart.sh

