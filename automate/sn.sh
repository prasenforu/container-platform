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
 --data '{"short_description":"In Container Environment '"$hst"' '"$summ"'","caller_id":"'"$SNCALLID"'","urgency":"'"$pri"'","category":"'"$SNCATAGORY"'","assignment_group":"'"$SNASSINGRP"'","assigned_to":"'"$SNASSINTO"'","sys_created_by":"'"$SNCALLID"'"}' \
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
