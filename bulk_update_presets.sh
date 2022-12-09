#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 
#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant

#1. validate the csv
#2. get PAT
#3. loop through csv and add the preset
#4. report how many projects are updated

#read the csv project map - for later

auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")

echo "Getting groups"
#get list of groups
groups=$(cx1GetGroups $cx1IamURL $token)

#get project data 
projectInfo=$(cx1GetProject $cx1URL $token "BB-OnPrem")
echo $projectInfo | jq -r
projectId=$(echo $projectInfo | jq -r '.projects[0].id')

preset="ASA Premium"

echo "check this out"
#echo cx1PatchProjectPreset $cx1URL $token $projectId $preset
result=$(cx1PatchProjectPreset $cx1URL $token $projectId $preset)
#echo $result

#echo $groups
#get list of projects
#projectsJson=$(cx1GetProjects $cx1URL $token)
#echo $projectsJson | jq -r '.projects'

#projectCount=$(echo $projectsJson | jq '.projects | length')
#echo $projectCount

