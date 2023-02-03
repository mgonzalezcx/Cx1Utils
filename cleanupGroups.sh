#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="groupCleanup.log"

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#get array of groups to keep from csv
csvGroups=()
while IFS=',' read -r group _; do
  csvGroups+=("$group")
done < $csvPath

#get all groups currently in cx1
cx1Groups=$(getGroups $cx1IamURL $token)

IFS=$'\n'
for group in $(echo "${cx1Groups}" | jq -c '.[]'); do
  #check to see if group is in csv list provided
  groupName=$(echo "$group" | jq -r '.name')
  groupId=$(echo "$group" | jq -r '.id')
  
  if [[ " ${csvGroups[*]} " =~  "$groupName" ]]; then
    echo "success"
  else
    #delete the groups that are not found in the csv list
    echo ""$groupName" Not found in list and will be deleted" >> $log
    response=$(deleteGroup $cx1IamURL $token $groupId)
    echo "$response" >> $log
  fi

done
