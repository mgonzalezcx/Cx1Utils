#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="groupCreate.log"

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#Get list of Cx1 Clients
#clients=$(getClients $cx1IamURL $token)
#astappClient=$(echo $clients | jq -r '.[] | select (.clientId=="ast-app") | '.id'')

#echo $astappClient


#######################
group="Csv Group 1"
role="Developer"
client="Developer"
#######################

update=$(updateGroupRole $cx1IamURL $token "$group" "$role")
echo $update

#get full list of groups
#groups=$(GetGroups $cx1IamURL $token)

#grab the info for the selected group
#groupInfo=$(echo $groups | jq -r '.[] | select (.name=="'"$group"'")')
#groupID=$(echo $groupInfo | jq -r '.id')



#echo $groupUpdate