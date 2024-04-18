#!/bin/bash

#set variables
csvPath=""
cliPath=""
log="scanProjectsCLI.log"

#read through the csv
count=0
while IFS="," read -r projectName url branch ;  do
    #check headers
    if [[ $count == 0 ]]
    then
        
        if [[ $projectName == "ProjectName" &&  $url == "URL" && $branch == "Branch" ]]
        then
            echo "Headers validated successfully" >> $log
            ((++count))
        else
            echo "Correct column headers" >> $log
            exit 1
        fi
    else
        #check to see if the group exists
        if [[ $(( $count % 10 )) == 0 ]]
        then
            sleep 300
        fi
        echo "git clone $url ./$projectName" >>$log
        git clone $url ./$projectName
        sourcePath=$(readlink -f ./$projectName)
        echo "$cliPath scan create --project-name $projectName -s $sourcePath --branch $branch" >> $log
        $cliPath scan create --async --project-name "$projectName" -s $sourcePath --branch $branch >> $log
        rm -rf ./$projectName
    fi
done < $csvPath