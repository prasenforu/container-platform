#!/bin/bash
set -e
set -o pipefail

# Add user to k8s using service account, no RBAC (must create RBAC after this script)
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
 echo "usage: $0 <service_account_name> <namespace>"
 exit 1
fi

SERVICE_ACCOUNT_NAME=$1
NAMESPACE="$2"
KUBECFG_FILE_NAME="/tmp/kube/k8s-${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-conf"
TARGET_FOLDER="/tmp/kube"

create_target_folder() {
    echo -n "Creating target directory to hold files in ${TARGET_FOLDER}..."
    mkdir -p "${TARGET_FOLDER}"
    rm -f "$KUBECFG_FILE_NAME"
cat <<EOF >>"$KUBECFG_FILE_NAME"
apiVersion: v1
kind: Config
users:
- name: AAAAA
  user:
    token: TTTTT
clusters:
- cluster:
    certificate-authority-data: CCCCC
    server: https://SSSSS:6443
  name: kube-cluster
contexts:
- context:
    cluster: kube-cluster
    namespace: NNNNN
    user: AAAAA
  name: NNNNN-context
current-context: NNNNN-context
EOF

    printf "done"
}

create_service_account() {
    echo -e "\\nCreating a service account in ${NAMESPACE} namespace: ${SERVICE_ACCOUNT_NAME}"
    kubectl create sa "${SERVICE_ACCOUNT_NAME}" --namespace "${NAMESPACE}"
}

get_secret_name_from_service_account() {
    echo -e "\\nGetting secret of service account ${SERVICE_ACCOUNT_NAME} on ${NAMESPACE}"
    SECRET_NAME=$(kubectl get sa "${SERVICE_ACCOUNT_NAME}" --namespace="${NAMESPACE}" -o json | jq -r .secrets[].name | grep token)
    echo "Secret name: ${SECRET_NAME}"
}

extract_ca_crt_from_secret() {
    echo -e -n "\\nExtracting ca.crt from secret..."
    CA_DATA=$(kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["ca.crt"]')
    printf "done"
}

get_user_token_from_secret() {
    echo -e -n "\\nGetting user token from secret..."
    USER_TOKEN=$(kubectl get secret --namespace "${NAMESPACE}" "${SECRET_NAME}" -o json | jq -r '.data["token"]' | base64 -d)
    printf "done"
}

get_kube_config_values() {
    context=$(kubectl config current-context)
    echo -e "\\nSetting current context to: $context"

    CLUSTER_NAME=$(kubectl config get-contexts "$context" | awk '{print $3}' | tail -n 1)
    echo "Cluster name: ${CLUSTER_NAME}"

    ENDPOINT=$(kubectl config view \
    -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}" | cut  -f2 -d ":" | cut  -f3 -d "/")
    echo "Endpoint: ${ENDPOINT}"

}

create_kube_config_file() {
    echo -e -n "\\nCreating kubeconfig file..."
    sed -i "s/CCCCC/$CA_DATA/g" "$KUBECFG_FILE_NAME"
    sed -i "s/TTTTT/$USER_TOKEN/g" "$KUBECFG_FILE_NAME"
    sed -i "s/SSSSS/$ENDPOINT/g" "$KUBECFG_FILE_NAME"
    sed -i "s/NNNNN/$NAMESPACE/g" "$KUBECFG_FILE_NAME"
    sed -i "s/AAAAA/$SERVICE_ACCOUNT_NAME/g" "$KUBECFG_FILE_NAME"
    printf "done"
}

create_target_folder
#create_service_account
get_secret_name_from_service_account
extract_ca_crt_from_secret
get_user_token_from_secret
get_kube_config_values
create_kube_config_file

echo -e "\\nAll done! Test with:"
echo "Your KUBECONFIG is ${KUBECFG_FILE_NAME}"
echo "you should not have any permissions by default - you have just created the authentication part"
echo "You will need to create RBAC permissions"
