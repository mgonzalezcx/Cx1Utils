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
function cx1GetGroups(){
    baseURL=$1
    token=$2

    requestURL=$baseURL'/groups'

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

#get all projects in tenant
function cx1GetAllProjects(){
    baseURL=$1
    token=$2

    requestURL=$baseURL'/projects'

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

#get project details by name
function cx1GetProject(){
    baseURL=$1
    token=$2
    project="$3"

    #remove white spaces from name
    projectName=${project// /'%20'}

    requestURL=$baseURL"/projects/?name="$projectName

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

function cx1PatchProjectPreset(){
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