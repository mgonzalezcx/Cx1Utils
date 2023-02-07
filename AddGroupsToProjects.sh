#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="AddGroupsToProjects.log"

#Get list of groups from cx1
#validate csv
#add all groups to a given project

#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#get list of groups
echo "Getting groups"
groups=$(getGroups $cx1IamURL $token)

#get list of projects
projectsResponse=$(getAllProjects $cx1URL $token)
projects=$(echo "$projectsResponse" | jq -r '.projects')


count=0
while IFS==",", read -r projectName groupName ;  do
    #check headers
    if [[ $count == 0 ]]
    then
        echo "this is the groupName: $groupName"
        if [[ $projectName == "Project" && $groupName == "Group" ]]
        then
            echo "Headers validated successfully" >> $log
            ((++count))
        else
            echo "Correct column headers" >> $log
            exit 1
        fi
    else
        #Add group to project
        unset projectInfo
        unset groupInfo
        projectInfo=$(echo "$projects" | jq -r '.[] | select (.name=="'"$projectName"'")')
        groupInfo=$(echo "$groups" | jq -r '.[] | select (.name=="'"$groupName"'")')
        
        #check to see of project name is valid
        if [[ -z "$projectInfo" ]] 
        then
            echo "this project doesn't exist: "$projectName"" >> $log
        else
            #check to see if group name is valid
            if [[ -z "$groupInfo" ]]
            then
                echo "This group does not exist: "$groupName"" >> $log 
            else
                groupId=$(echo "$groupInfo" | jq -r '.id')
                updateProject=$(updateProjectGroup $cx1URL $token "$projectInfo" $groupId)
                echo $updateProject >> $log
            fi
        fi
        ((++count))
    fi
done < $csvPath