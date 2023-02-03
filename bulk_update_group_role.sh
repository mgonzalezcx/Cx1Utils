#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="assigningRoles.log"

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#get full list of groups
groups=$(getGroups $cx1IamURL $token)
#get list of roles
roles=$(getRoles $cx1IamURL $token)

count=0
while IFS==",", read -r groupName roleName ;  do
    #check headers
    if [[ $count == 0 ]]
    then
        
        if [[ $groupName == "Group" &&  $roleName == "Role" ]]
        then
            echo "Headers validated successfully" >> $log
            ((++count))
        else
            echo "Correct column headers" >> $log
            exit 1
        fi
    else
    #check to see if the group exists
    unset groupInfo
    groupInfo=$(echo $groups | jq -r '.[] | select (.name=="'"$groupName"'")')
        if [[ -z "$groupInfo" ]]
        then
            response=$(createGroup $cx1IamURL $token "$groupName")
            unset groups
            groups=$(getGroups $cx1IamURL $token)

            echo "Created group: $groupName" >> $log
        fi
        #update the role
        echo "This is the groupName: $groupName and this is the roleName: $roleName" >> $log
        update=$(updateGroupRole $cx1IamURL $token "$groupName" "$roleName" "$groups" "$roles")
        echo $update >> $log
       
    fi
done < $csvPath