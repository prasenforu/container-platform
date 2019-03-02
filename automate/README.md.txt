oc create cm webhook-hooks-configmap -n monitoring --from-file=./hooks.json
oc create cm webhook-kubeconfig-configmap -n monitoring --from-file=./kubeconfig
oc create cm webhook-sn-configmap -n monitoring --from-file=./sn.sh
oc create cm webhook-autoscale-configmap -n monitoring --from-file=./autoscale.sh
oc create cm webhook-pod-restart-configmap -n monitoring --from-file=./pod-restart.sh
oc create cm webhook-keypem-configmap -n monitoring --from-file=./prasen.pem
oc create cm webhook-ocp-node-restart-configmap -n monitoring --from-file=./ocp-node-restart.sh

-----------------
Files
-----------------
hooks.json
----------

[
  {
    "pass-arguments-to-command": [
      {
        "source": "url",
        "name": "in1"
      },
      {
        "source": "url",
        "name": "in2"
      },
      {
        "source": "payload",
        "name": "status"
      }
    ],
    "id": "autoscale-hook",
    "execute-command": "/etc/webhook/autoscale.sh",
    "command-working-directory": "/etc/webhook"
  },
  {
    "pass-arguments-to-command": [
      {
        "source": "url",
        "name": "in1"
      },
      {
        "source": "url",
        "name": "in2"
      },
      {
        "source": "payload",
        "name": "status"
      }
    ],
    "id": "pod-restart-hook",
    "execute-command": "/etc/webhook/pod-restart.sh",
    "command-working-directory": "/etc/webhook"
  },
  {
    "pass-arguments-to-command": [
      {
        "source": "payload",
        "name": "alerts.0.labels.instance"
      },
      {
        "source": "payload",
        "name": "alerts.0.annotations.message"
      },
      {
        "source": "payload",
        "name": "status"
      },
      {
        "source": "payload",
        "name": "alerts.0.labels.severity"
      }
    ],
    "id": "sn-hook",
    "execute-command": "/etc/webhook/sn.sh",
    "command-working-directory": "/etc/webhook"
  },
  {
    "pass-arguments-to-command": [
      {
        "source": "payload",
        "name": "alerts.0.labels.instance"
      },
      {
        "source": "payload",
        "name": "alerts.0.annotations.message"
      },
      {
        "source": "payload",
        "name": "status"
      }
    ],
    "id": "ocp-node-restart-hook",
    "execute-command": "/etc/webhook/ocp-node-restart.sh",
    "command-working-directory": "/etc/webhook"
  }
]

#################

kubeconfig
----------

apiVersion: v1
kind: Config
users:
- name: webhook
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJtb25pdG9yaW5nIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6IndlYmhvb2stdG9rZW4tdm52OTYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoid2ViaG9vayIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjU2ZjRlMWY0LTM5YjAtMTFlOS1iMGJjLWU2MWNmNzdiZjRmZCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDptb25pdG9yaW5nOndlYmhvb2sifQ.JnaTBTV1wajOs7NCTXSpYs7SRTtjvkqVmhg0qAyLVkgou76hSIPOxQb_nCL5sRCBNQYRRz28G1I5We0LYtX_ix5vQK6mjxaA3YLfDh2Pu3YJxAuBX4f4sP91zl1LFncDkMKq7ImU0abpw-EdJxA7OkFDCRjLdP79diSP67W9Cqq8Kks1vU9SbOXSRt0d3ZjTNKCpxdMM94OVvrqxs6Vdb0-aNVH8Fr5N6UlRJOZv43wA3grwfAkYNyhwa6C_w_aWqum5KVXQQsmQ2rU6m-1PszQz-W_Ktoh1mLTBvx9BOIaSaKqyyLcUg0eb7_QlFsXHwqSqWrmFFnLzkPPX7EtmTSZZ0KrpYbjEMJGwtJNuA-K988WIApUmpvsFzyZnGTbiUkfatz0r-lIwPnxkFUIfeTzzyiOlU0gQww-VGEO8jdt0AJ7baL1o3pssTFXB_wfoJf-2_3eb49y6PEKNtd6AOlnka4cCEBTXf64haBk8Vlz9Jz8kEOfkEdFvEpG4rdqCaolE8ntjmWEWFlzQlO1N_WFd5kUqee-HZaHTWCWAKXRZnHtP-rOSFuPBen8QxUrbDryCEjXSc-pgiHRHaqLjSS9eCYz9U0-yZGLkUgz-8RJQ_DffqHm_GGYelgPE2X-37fZQx2Npd1aNs4eNAdaLBYgDSPQSNsRbv1ZHrjZRYTc
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUV5RENDQXJDZ0F3SUJBZ0lSQVBoUDF5bldZbks4dWdXZWxnQTBjTHN3RFFZSktvWklodmNOQVFFTEJRQXcKRFRFTE1Ba0dBMVVFQXhNQ1kyRXdIaGNOTVRrd01qSTJNRFkwTnpFNFdoY05NakV3TWpJMU1EWTBOekU0V2pBTgpNUXN3Q1FZRFZRUURFd0pqWVRDQ0FpSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnSVBBRENDQWdvQ2dnSUJBTGlmClp3eFk3L2V4OC8yajhEdFB4RVByZk80dTB0MXl1eWk4eHNxYWRRTWRNNUZmZ0VTVnFzbkl2aVhNZW9pcW0vMVIKdGk1K1ZvT3E5WEdmMW92YVAzR3VRMmFCejEvV3Mvd3RkdVJmL2xEbmxyeTFSYTR0RmJiOHEvamhrMjJMaHhoWgovS1JkUUppWldUOC8ybEIxbGkxNVhlVlhTaVJmeDVSdnRSaVFVLzRRYVVlODlyb2tHT2FCTUVzZE5oRjliVWp6CnlzdUIrSU95U1VmMEpSYm9Kb1o4QzU0SWppM1ZXdXR4R0s2QzdDcklQWkVQc0xxN2dDR2NEd3lZMi94MzVwTzUKR1c0MjRIc2d4ZDBQVEg4MVM2aThDczJta0padERZR3ZkbUJabHJVQ3NPMWg0U3R6akhGaHpBTXRJUGhPcUk1UQpScStKNktBSTRaRXZqcGJIRFY5aGlHOU1PTkdPd1lXWWFCaXRHbWhzWU9LeW1hSDR0VUVmZ0pYVXd2R2FXd3ZjCjN4dDlwOUcvUzFWMnRIenRQMzJ0eURPRWMxampiVHY3eWxFR0FHTzhGZzJlR00xemdUNUFrSHlxRDNvQVozWWwKMmN0VkIwVHM4elpyQVFaSmhUNzc1T0NLS1g4c1FiZSt1Z0F1OUM4WW54SmZKUE9SckM2Y2EyK09BUDBnOXFHZQo4cFJyMWtGSkYwY2c1V0xBRnVUWTlNOUxVNXozUS9aY1lJVFV4S2EzOUE1YXZRRGtMVzNMUlBwZmFjT1RkNGJBCnRrd0tQYWFuSkk1cy9WRnBvbmoxb0dRMUdvSWVNR25Lb2JWU3h0bkJ4dGNEaHV1ZDJMZUxyQy8vMjBSUnh5dmEKWitRRlg2WUR1MjN1QUNOSWFEYzd0b2REWm9HckVlRmxOQnUyQkNhSEFnTUJBQUdqSXpBaE1BNEdBMVVkRHdFQgovd1FFQXdJQ3BEQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQ0FRQlZJc3l1CjM0T1htUjBvcUVnRjRjVUczZVJxcG5ld294aVhPZlJnT01jd0dvNm1SMEFLank4YWF2RUs1L251ZDk4M3VCZXUKQWxDTFZ5STZSSFg5ZG1wandhWENaQXJGVnorZHFmc0E5eUtEMDc4ZE1Idlh3S25IZk1IV3RuOGV6VUZyTlptYgoxMnNQa1NNOFB6YkhZN2tZTTJZeGpRbGNtQjA2SkZid25sbGRPYVBXS0FZUS9PSEh6QWlCNDdNMk9nbWVGQkJNCk5wa3RBbm12NzRlWVByRmZuSXc5TlhLVDdFRjVOeWRaN1hpUlBXdmlST3N6U2pSMUFOZ1Y1M0lqVW51QTdzdU0KL0tSUkNBbVhmWEl3U2hvQ2loaWlPZUZ6WWtFN0N2K2RjV0VScThEcitibFdZSVJjaVBZL1hxdUU3aUE4c05BNgp5UjNKazFPQkRzM2pjSFIvTDk4aTI0dTR2cjl2UnpXd0RCTVRTMS9HZjE1SEhpWUFwd1hWRVR5YU9zTHNuRHVaCkxVVmk0Q2I5MitMT1QrbEd0N29YVzZ5WE0zV2hWUkxYK1hQWUVZdFRzdDNLd1B1SEhDeTRwTG9qZm4yclN3enMKZmRLY1BvZzhxb015THVwRjVOdjJyMXdWSHJnek04KzJyM0dTeUFGK1krQkUvbXM2YXNxR081RENrS1hLamxMdQp4K0JLTmZycTROQlFlbmEwUkQ3dlMyRUovSE9BYzc1UTJ5VDcxdm5HZFhVTnJIbWlOVTN3cWw1R3hld2F0RG8rCmU5TUZadHI2aDZoeVJrTnZjVGY2Z2FLR2FEdzc3OURtYmVyV0Uwb1lyQ1dQdlRWOXBPRDBwWjg2VXJsRlF5UWwKZEMraVZMdHVqcEFVV0lvMWJJaW5EK0tPYm1VUDBTSWUwa0NicGc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://gapk8s-53807c0f.hcp.eastus.azmk8s.io:443
  name: kubernetes-cluster
contexts:
- context:
    cluster: kubernetes-cluster
    user: webhook
  name: webhook-acct-context
current-context: webhook-acct-context

#################

sn.sh
-----

#!/bin/sh
# ServiceNow Integration, Incident create/Close/Resolve

hst=$1
summ=$2
stat=$3
sev=$4

if [ $sev == "CRITICAL" ]; then
  pri=1
elif [ $sev == "critical" ]; then
  pri=1
elif [ $sev == "criticalNode" ]; then
  pri=1
elif [ $sev == "MEDIUM" ]; then
  pri=2
elif [ $sev == "medium" ]; then
  pri=2
elif [ $sev == "WARNING" ]; then
  pri=3
elif [ $sev == "warning" ]; then
  pri=3
else
  pri=4
fi

# Creating incident

if [ $stat == "firing" ]; then

curl --user $SNUSER:$SNPASS \
 --header "Content-Type:application/json" \
 --header "Accept: application/json" \
 --request POST \
 --data '{"short_description":"In OCP '"$hst"' '"$summ"'","caller_id":"'"$SNCALLID"'","urgency":"'"$pri"'","category":"'"$SNCATAGORY"'","assignment_group":"'"$SNASSINGRP"'
","assigned_to":"'"$SNASSINTO"'","sys_created_by":"'"$SNCALLID"'"}' \
https://$SNURL/api/now/table/incident > /etc/webhook/op.txt

INCID=`jq '.result.sys_id' /etc/webhook/op.txt | tr -d '"'`
echo "$INCID:$hst:$summ:$pri" >> /etc/webhook/incident.txt

fi

###########

# Closing incident

if [ $stat == "resolved" ]; then
SNINCID=`grep $hst:"$summ":"$pri" /etc/webhook/incident.txt | cut -d ":" -f1`

curl --user $SNUSER:$SNPASS \
--header "Content-Type:application/json" \
--header "Accept: application/json" \
--request PUT \
--data '{"close_code":"Closed/Resolved By User ('"$SNCALLID"')","state":"'"7"'","caller_id":"'"$SNCALLID"'","close_notes":"Closed from webhook by API"}' \
https://$SNURL/api/now/table/incident/$SNINCID

sed -i "/$SNINCID/d" /etc/webhook/incident.txt

fi

#################

autoscale.sh
------------

#!/bin/sh

# OSE Authentication

if [ $KUBEPASS != "" ]; then
   oc login https://$KUBEHOST:$KUBEPORT --username=$KUBEUSER --password=$KUBEPASS --insecure-skip-tls-verify=true
fi

if [ $KUBETOKEN != "" ]; then
   oc login https://$KUBEHOST:$KUBEPORT --token=$KUBETOKEN
fi

oc project $1

app=`echo $2 | cut -d "-" -f1`

echo "Application ($app) status before scale up/down"
oc get all | grep dc/$app

# DESIRED value of dc/apps

de=`oc get all | grep dc/$app | awk '{print $3}'`

# CURRENT value of dc/apps

cu=`oc get all | grep dc/$app | awk '{print $4}'`

# Checking for POD  status addition for firing and substaraction for resolved
# If CURRENT & DESIRED value same and below one (1) then it will exit

if [ $3 == "firing" ]; then
   pm='+'
   dpm=scale-up
fi                          
                            
if [ $3 == "resolved" ]; then
   if [ $de = $cu ] && [ $de -gt 1 ] && [ $cu -gt 1 ]; then
      pm='-'                
      dpm=scale-down        
   else                     
      echo "Looks like CURRENT & DESIRED value NOT same or below one (1)"
      oc get all | grep dc/$app
      exit                  
   fi                       
fi                          
                            
# IF CURRENT value & DESIRED value same then decrease one pod
                            
if [ $de = $cu ]; then      
   de=$((de $pm 1))         
   oc scale dc/$app --replicas=$de
else                        
   echo "Looks like CURRENT & DESIRED value NOT same."
   oc get all | grep dc/$app
   exit                     
fi                          
                            
# Status                    
echo "Application ($app) pod of Project ($1) going to $dpm"
oc get all | grep dc/$app 


#################

pod-restart.sh
--------------

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


#################

prasen.pem
----------



#################

ocp-node-restart.sh
-------------------
    #!/bin/sh
    #### Automation for node,docker,api,controller & host

    hst=$1
    alrn=$2
    stat=$3

    hstip=`echo $hst | cut -d ":" -f1`
     
    docstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active docker"`
    nodstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active origin-node"`

    if [ $stat == "firing" ]; then

    ### Checking OCP Node client

     if [ $nodstat == "inactive" ]; then
        ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl start origin-node"
        sleep 7
     fi

    nodstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active origin-node"`

     if [ $nodstat == "active" ]; then
        echo "OCP Node Client is Running in Host : $1 "
     fi

    ### Checking OCP Docker client

     if [ $docstat == "inactive" ]; then
        ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl start docker"
        sleep 7
     fi

    docstat=`ssh -o "StrictHostKeyChecking no" -i /etc/webhook/prasen.pem centos@$hstip "sudo systemctl is-active docker"`

     if [ $docstat == "active" ]; then
        echo "Docker is Running in Host : $1 "
     fi

    fi



#################

