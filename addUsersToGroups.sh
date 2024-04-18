#!/bin/bash
source ./CX1APIs.sh # -- this is how to reference another file 


#set variables
cx1Tenant=$1
PAT=$3
csvPath=$2
cx1URL="https://ast.checkmarx.net/api"
cx1TokenURL="https://iam.checkmarx.net/auth/realms/"$cx1Tenant
cx1IamURL="https://iam.checkmarx.net/auth/admin/realms/"$cx1Tenant
log="AddUsersToGroups.log"

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
usersResponse=$(getUsers $cx1IamURL $token)
users=$(echo "$usersResponse" | jq -r '.[]')


count=0
while IFS==",", read -r username groupNames ;  do
    #check headers
    if [[ $count == 0 ]]
    then
        if [[ $username == "Username" && $groupNames == "Groups" ]]
        then
            echo "Headers validated successfully" >> $log
            ((++count))
        else
            echo "Correct column headers" >> $log
            exit 1
        fi
    else
        #Add group to project
        unset userInfo
        unset groupInfo
        userInfo=$(echo "$users" | jq -r '. | select (.username=="'"$username"'")')
        userId=$(echo $userInfo | jq -r '.id')

        #remove double quotes from string
        groupNames=$(echo $groupNames | sed 's/"//g')
        IFS=',' read -ra groupList <<< "$groupNames"
       
        #check to see of project name is valid
        if [[ -z "$userInfo" ]] 
        then
            echo "this project doesn't exist: "$username"" >> $log
        else
            for group in "${groupList[@]}"
            do
                echo "this is the group id"
                groupInfo=$($groups | jq -r '.[] | select (.name=="'"$group"'")')
                groupId=$(echo $groupInfo | jq -r '.id')
                #check to make sure the group exists
                if [[ -z "$groupInfo" ]]
                then
                    echo "This group does not exist: "$groupName"" >> $log 
                else
                    response=$(getUsers $cx1IamURL $token $userId $groupId)
                fi
            done
            #check to see if group name is valid
        fi
        ((++count))
    fi
done < $csvPath