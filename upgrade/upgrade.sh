#!/usr/bin/env bash
# Copyright (c) Syncfusion Inc. All rights reserved.
#

while [ $# -gt 0 ]; do
  case "$1" in
    --version=*)
      version="${1#*=}"
      ;;
    --namespace=*)
      namespace="${1#*=}"
      ;;
    *)
  esac
  shift
done

[ -n "$version" ] || read -p 'Enter the version to upgrade: ' version

if [ -z "$version" ]
then
	echo "Version is empty."
else	
	if [ -z "$namespace" ]
	then
		namespace="default"
	fi
	
	kubectl set image deployment/id-web-deployment id-web-container=syncfusion/bold-identity:$version --namespace=$namespace --record 
	kubectl set image deployment/id-api-deployment id-api-container=syncfusion/bold-identity-api:$version --namespace=$namespace --record 
	kubectl set image deployment/id-ums-deployment id-ums-container=syncfusion/bold-ums:$version --namespace=$namespace --record 
	kubectl set image deployment/bi-web-deployment bi-web-container=syncfusion/boldbi-server:$version --namespace=$namespace --record 
	kubectl set image deployment/bi-api-deployment bi-api-container=syncfusion/boldbi-server-api:$version --namespace=$namespace --record 
	kubectl set image deployment/bi-jobs-deployment bi-jobs-container=syncfusion/boldbi-server-jobs:$version --namespace=$namespace --record 
	kubectl set image deployment/bi-dataservice-deployment bi-dataservice-container=syncfusion/boldbi-designer:$version --namespace=$namespace --record
	kubectl set image deployment/bold-etl-deployment bold-etl-container=syncfusion/bold-etl:$version --namespace=$namespace --record
	kubectl set image deployment/bold-ai-deployment bold-ai-container=syncfusion/bold-ai:$version --namespace=$namespace --record 
	kubectl set image deployment/bold-mcp-deployment bold-mcp-container=syncfusion/boldbi-mcp-server:$version --namespace=$namespace --record  
fi