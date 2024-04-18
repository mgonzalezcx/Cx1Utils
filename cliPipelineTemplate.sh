#!/bin/bash
wget -O ./cxcli.tar.gz "https://github.com/Checkmarx/ast-cli/releases/download/${CX_VERSION}/ast-cli_${CX_VERSION}_linux_x64.tar.gz"
tar xzvf ./cxcli.tar.gz
./cx scan create --project-name "TestProjectName" --file-source "." --branch "main" --report-format 'PDF' --agent 'Jenkins' --base-uri ${CX1_URL} --tenant ${CX1_TENANT} --apiKey ${CX1_APIKEY} 