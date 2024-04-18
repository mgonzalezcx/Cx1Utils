#!/bin/bash

#set variables
cx1Tenant=$1
PAT=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
groupName="API_Test"

function cx1login(){
    baseURL=$1
    PAT=$2

    requestURL=$baseURL'/protocol/openid-connect/token'

    curl --location --request POST $requestURL \
                 --header 'Content-Type: application/x-www-form-urlencoded' \
                 --data-raw 'grant_type=refresh_token&client_id=ast-app&refresh_token='$PAT
}

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

function createGroup(){
    baseURL=$1
    token=$2
    groupName="$3"

    requestURL=$baseURL'/groups'

    body='{
            "name": "'$groupName'"
          }'

    curl --location --request POST $requestURL \
         --header "Authorization: Bearer $token" \
         --header 'Content-Type: application/json' \
         --data "$body"
}

#Create the group
response=$(createGroup $cx1IamURL $token "$groupName")
echo $response

