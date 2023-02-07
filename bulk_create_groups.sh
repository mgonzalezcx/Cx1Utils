#!/bin/bash
source ./CX1APIs.sh


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

count=0
while IFS==",", read -r groupName ;  do
    #check headers
    if [[ $count == 0 ]]
    then
        echo "this is the groupName: $groupName" >> $log
        if [[ $groupName == "groupName" ]]
        then
            echo "Headers validated successfully" >> $log
            ((++count))
        else
            echo "Correct column headers" >> $log
            exit 1
        fi
    else
        #Create the group
        response=$(createGroup $cx1IamURL $token "$groupName")
        echo $response >> $log
       
    fi
done < $csvPath