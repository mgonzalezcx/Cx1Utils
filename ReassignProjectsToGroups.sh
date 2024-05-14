#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2 #always leave empty line in CSV since it will not be parsed
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="ReassignGroups.log"


#Get Cx1 Token
auth=$(cx1login $cx1TokenURL $PAT)
token=$(echo $auth | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g")
echo "Authenitcation Successful" >> $log

#get list of groups
echo "Getting groups"
groups=$(getGroups $cx1IamURL $token)

#get list of projects
projectsResponse=$(getAllProjects $cx1URL $token)
projects=$(echo "$projectsResponse" | jq -r '.projects[]')

#count=1
while IFS=",", read -r oldGroup newGroup ;  do
	
	# echo $count
	# echo "old: ${oldGroup}"
	# echo "new: ${newGroup}"
	
	## remove linefeed from the column (especially true for the last column).
	oldGroup=${oldGroup//[$'\r\n']}
	newGroup=${newGroup//[$'\r\n']}
	
	# echo "oldx: ${oldGroup}"
	# echo "newx: ${newGroup}"
	
	oldGroupInfo=$(echo "$groups" | jq -r '.[] | select (.name=="'"${oldGroup}"'")')
	oldGroupId=$(echo "$oldGroupInfo" | jq -r '.id')
	
	newGroupInfo=$(echo "$groups" | jq -r '.[] | select (.name=="'"${newGroup}"'")')
	newGroupId=$(echo "$newGroupInfo" | jq -r '.id')

	# echo "oldGroupInfo: ${oldGroupInfo}"
	# echo "newGroupInfo: ${newGroupInfo}"
	# ((++count))


	IFS=$'\n'
	for project in $(echo ${projects} | jq -c '.'); do
		projectGroups=$(echo "$project" | jq -r '.groups' )
		projectName=$(echo "$project" | jq -r '.name')

		for i in "${projectGroups[@]}"
		do
			if [[ $i =~ $oldGroupId ]]
			then
				updateProject=$(updateProjectGroup $cx1URL $token "$project" $newGroupId)
			fi
		done
	done

done < $csvPath
