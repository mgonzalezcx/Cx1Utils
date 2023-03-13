#!/bin/bash

#set variables
cx1Tenant="ps_na_miguel_gonzalez"
clientId="api_client"
clientSecret="ar20YVywgpPdKkIGg4pTm2h87fi0mIxW"
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant"/protocol/openid-connect/token"
project="Jenkins_NodeGoat"

#generate a token
auth=$(curl --location --request POST $cx1TokenURL --header 'Content-Type: application/x-www-form-urlencoded' --data-raw 'grant_type=client_credentials&client_id='"$clientId"'&client_secret='$clientSecret)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")

#get the project id
projectName=${project// /'%20'}
requestURL=$cx1URL"/projects/?name="$projectName
projectData=$(curl -X GET $requestURL -H "Authorization: Bearer $token")
projectId=$(echo $projectData | jq -r '.projects[].id')

#get application info
app=$(echo $projectData | jq -r '.projects[].tags.APP')
appName=${app// /'%20'}
requestURL=$cx1URL"/applications/?offset=0&limit=20&name="$appName
appData=$(curl -X GET $requestURL -H "Authorization: Bearer $token")
application=$(echo $appData | jq -r '.applications[]')

#check to see if application exists
if [ -z "$application" ]; then 

    #create the applciation if it doesn't exist
    body='{
            "name": "'"$app"'",
            "rules": [
                        {
                        "type": "project.name.in",
                        "value": "'"$project"'"
                        }
                      ]
          }'
    
    requestURL=$cx1URL"/applications"
    response=$(curl --request POST "$requestURL" --header "Authorization: Bearer $token" --data "$body")

else
    #grab the import parts of the response
    appProjectIds=$(echo $application | jq -r '.projectIds')
    appId=$(echo $application | jq -r '.id')

    #Check to see if project is associated with the app
    exists=0
    for id in ${appProjectIds[@]}; do
        if [[ $projectId = $id ]]; then
            exists=1
        fi
    done
    
    #add project to the application if needed
    if [[ $exists -eq 0 ]]; then
        #add the project name to the json body
        projectNames=$(echo $application | jq -r '.rules[].value')
        updatedProjectNames=$projectNames";$project"
        updatedApp=$(echo $application | jq --arg new "$updatedProjectNames" '.rules[].value = $new')
        
        #prepare the api call to add the project
        body=$(echo $updatedApp | jq -r '.')
        requestURL=$cx1URL"/applications/"$appId
        response=$(curl --request PUT "$requestURL" --header "Authorization: Bearer $token" --data "$body")

    fi
fi
