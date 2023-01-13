#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="presetUpdater.log"

#1. validate the csv
#2. loop through csv and add the preset
#3. report how many projects are updated

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#validate csv 
count=0
while IFS==",", read -r projectName presetName;  do
    #check headers
    if [[ $count == 0 ]]
    then
        if [[ $projectName == "projectName" && $presetName == "presetName" ]]
        then
            echo "Headers validated successfully" >> $log
            ((++count))
        else
            echo "Correct column headers" >> $log
            exit 1
        fi
    else
        #update the preset
        echo "Updating project $projectName setting preset at $presetName" >> $log
        #get project id
        projectInfo=$(cx1GetProject $cx1URL $token "$projectName")
        projectId=$(echo $projectInfo | jq -r '.projects[0].id')
    
        #add rule for preset
        result=$(cx1PatchProjectPreset $cx1URL $token $projectId "$presetName")
        echo $result >> $log

        ((++count))
    fi
done < $csvPath

