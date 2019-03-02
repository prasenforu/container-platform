#!/bin/sh

# Kube Autoscaling

app=`echo $2 | cut -d "-" -f1`

echo "Application ($app) status before scale up/down"
kubectl get deployment $app -n $1

# DESIRED value of dc/apps

de=`kubectl get deployment $app -n $1 | grep -v NAME | awk '{print $2}'`

# CURRENT value of dc/apps

cu=`kubectl get deployment $app -n $1 | grep -v NAME | awk '{print $3}'`

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
      kubectl get deployment $app -n $1
      exit                  
   fi                       
fi                          
                            
# IF CURRENT value & DESIRED value same then decrease one pod
                            
if [ $de = $cu ]; then      
   de=$((de $pm 1))  
   kubectl scale deployment $app -n $1 --replicas=$de     
else                        
   echo "Looks like CURRENT & DESIRED value NOT same."
   kubectl get deployment $app -n $1
   exit                     
fi                          
                            
# Status                    
echo "Application ($app) pod of Project ($1) going to $dpm"
kubectl get deployment $app -n $1
