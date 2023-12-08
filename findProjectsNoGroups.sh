#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="ProjectsWithNoGroups.log"
csv="ProjectsWithNoGroups.csv"


#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log


#get list of projects
projectsResponse=$(getAllProjects $cx1URL $token)
projects=$(echo "$projectsResponse" | jq -r '.projects[]')

#add csv headers
echo "ProjectId,ProjectName" >> $csv

#check to see if projects have 0 groups assigned
IFS=$'\n'
for project in $(echo ${projects} | jq -c '.'); do
    groups=$(echo "$project" | jq -r '.groups')
    projectId=$(echo "$project" | jq -r '.id')
    projectName=$(echo "$project" | jq -r '.name')
    
    if [ "$groups" == "[]" ] 
    then 
        #add project to the csv
        echo "this project has no groups" >> $log
        echo $project | jq -r >> $log
        echo "$projectId,$projectName" >> $csv
    fi
done

