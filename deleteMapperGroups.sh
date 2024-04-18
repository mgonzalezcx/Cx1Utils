#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="DeleteMapperGroups.log"

#Get list of groups from cx1
#Get list of all groups created by the mapper
#Delete all those groups 

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#get list of groups
echo "Getting groups"
groups=$(getGroups "$cx1IamURL" "$token")

#loop through groups and find those that were created by the mapper
echo $groups | jq -c '.[].id' | while read id; do 
    #remove double quotes from string
    unset $createdBy
    id=$(echo $id | sed 's/"//g')
    groupInfo=$(getGroupById $cx1IamURL "$token" $id)
    
    createdBy=$(echo $groupInfo | jq -r '.attributes.createdBy[]') >> $log
    
    #delete the group if user did not create it
    if [[ -z "$createdBy" ]]
    then
        result=$(deleteGroup "$cx1IamURL" "$token" "$id")
    fi
    
done