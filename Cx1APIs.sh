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

function cx1GetGroups(){
    baseURL=$1
    token=$2

    requestURL=$baseURL'/groups'

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

function cx1GetAllProjects(){
    baseURL=$1
    token=$2

    requestURL=$baseURL'/projects'

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}


function cx1GetProject(){
    baseURL=$1
    token=$2
    project=$3

    requestURL=$baseURL"/projects/?name=$project"

    curl -X GET $requestURL -H "Authorization: Bearer $token"
}

function cx1PatchProjectPreset(){
    baseURL=$1
    token=$2
    projectId=$3
    presetName=$4

    requestURL=$baseURL"/configuration/project?project-id=$projectId"
    
#    body="{
#            'key': 'scan.config.sast.prestName',
#            'name': 'presetName',
#            'category': 'sast',
#            'originLevel': 'project',
#            'value': $preset,
#            'allowOverride': true
#        }"
    echo "this is the body"
    body=$(jq --null-input \
            --arg key "scan.config.sast.presetName" \
            --arg name "presetName" \
            --arg category "sast" \
            --arg originLevel "project" \
            --arg value "$presetName" \
            --arg allowOverride true \
            '{"key": $key,"name": $name,"category": $category,"originLevel": $originLevel,"value": $value,"allowOverride": $allowOverride}') 
    
    echo "${body}"
    #curl -X PATCH $requestURL -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d "${body}"
}