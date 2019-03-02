#!/bin/sh

# OCP Authentication

if [ $KUBEPASS != "" ]; then
   oc login https://$KUBEHOST:$KUBEPORT --username=$KUBEUSER --password=$KUBEPASS --insecure-skip-tls-verify=true
fi

if [ $KUBETOKEN != "" ]; then
   oc login https://$KUBEHOST:$KUBEPORT --token=$KUBETOKEN
fi

# OCP project selection

oc project $1

# Checking Status

echo "Application=$2 in namespace=$1 status before restart"
oc get po/$2

# Deleting POD

# if [ $3 == "firing" ]; then
    oc delete pod $2 --grace-period=0 
# fi

# Checking Status & errors

sleep 10
echo "Application=$2 in namespace=$1 status after restart"
oc get po/$2
oc logs $2 -c promethus | grep bad

