#!/bin/bash

#login and get token
function cx1login(){
    baseURL=$1
    PAT=$2

    requestURL=$baseURL'/protocol/openid-connect/token'

    curl --location --request POST $requestURL \
                 --header 'Content-Type: application/x-www-form-urlencoded' \
                 --data-raw 'grant_type=refresh_token&client_id=ast-app&refresh_token='$PAT
}

#get all groups in tenant
function getGroups(){
    baseURL=$1
    token=$2

    requestURL=$baseURL'/groups'

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

function getGroupByName(){
    baseURL=$1
    token=$2
    groupName=$3

    groups=$(getGroups $baseURL $token)

    groupInfo=$(echo $groups | jq -r '.[] | select (.name=="'"$group"'")')

    echo $groupInfo
}

#get all projects in tenant
function getAllProjects(){
    baseURL=$1
    token=$2

    requestURL=$baseURL'/projects'

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

#get project details by name
function getProject(){
    baseURL=$1
    token=$2
    project="$3"

    #remove white spaces from name
    projectName=${project// /'%20'}

    requestURL=$baseURL"/projects/?name="$projectName

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

#Api to update the project rules to add a preset
function patchProjectPreset(){
    baseURL=$1
    token=$2
    projectId=$3
    preset="$4"

    requestURL=$baseURL"/configuration/project?project-id=$projectId"

    #json body to update the preset
    body='[
            {
                    "key": "scan.config.sast.presetName",
                    "name": "presetName",
                    "category": "sast",
                    "originLevel": "Project",
                    "value": "'$presetName'",
                    "allowOverride": true
            }
          ]'

    curl --location --request PATCH $requestURL \
         --header "Authorization: Bearer $token" \
         --header 'Content-Type: application/json' \
         --data "$body"

}

#Grab project id from project api response to add a preset by name
function updatePreset(){
    cx1URL=$1
    token=$2
    projectName="$3"
    preset=$4
    
    projectInfo=$(cx1GetProject $cx1URL $token "$projectName")
    
    projectId=$(echo $projectInfo | jq -r '.projects[0].id')

    result=$(cx1PatchProjectPreset $cx1URL $token $projectId "$preset")
    echo $result
}

#Create a new group by name
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

#Delete group by ID
function deleteGroup(){
    baseURL=$1
    token=$2
    groupID="$3"

    requestURL=$baseURL'/groups/'$groupID

    curl --location --request DELETE $requestURL \
         --header "Authorization: Bearer $token" 
}

function updateGroupRole(){
    baseURL=$1
    token=$2
    groupName="$3"
    roleName="$4"
    groups=$5

    #Find the Id of the group that will be updated
    if [ -z "$groups" ]
    then
        groupInfo=$(getGroupByName $baseURL $token "$groupName")
    else
        groupInfo=$(echo $groups | jq -r '.[] | select (.name=="'"$groupName"'")')
    fi
    
    groupId=$(echo $groupInfo | jq -r '.id')
    #Get the client id for ast-app
    clientId=$(getClientIdByName $baseURL $token "ast-app")

    #Get the role info
    roleInfo=$(getRoleByName $baseURL $token "$roleName")

    
    requestURL=$baseURL'/groups/'$groupId'/role-mappings/clients/'$clientId

    curl --location --request POST $requestURL \
         --header "Authorization: Bearer $token" \
         --header 'Content-Type: application/json' \
         --data "[$roleInfo]"
}


function getClientIdByName(){
    baseURL=$1
    token=$2
    client="$3"

    requestURL=$baseURL'/clients'

    clients=$(curl -X GET $requestURL -H "Authorization: Bearer $token")

    clientId=$(echo $clients | jq -r '.[] | select (.clientId=="'"$client"'") | '.id'')

    echo $clientId
}

function getRoleByName(){
    baseURL=$1
    token=$2
    roleName=$3

    astappID=$(getClientIdByName $baseURL $token "ast-app")

    requestURL=$baseURL'/clients/'$astappID'/roles'

    roles=$(curl -X GET $requestURL -H "Authorization: Bearer $token")

    targetRole=$(echo $roles | jq -r '.[] | select(.name=="'$role'")')
    
    echo $targetRole
}