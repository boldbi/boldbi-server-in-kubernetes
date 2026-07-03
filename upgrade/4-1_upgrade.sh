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
	--app_base_url=*)
      app_base_url="${1#*=}"
      ;;
	--optional_libs=*)
      optional_libs="${1#*=}"
      ;;
	--bing_map_enable=*)
      bing_map_enable="${1#*=}"
      ;;
	--bing_map_api_key=*)
      bing_map_api_key="${1#*=}"
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
	
	if [[ "$version" == *"4.2"* ]]
	then
		[ -n "$app_base_url" ] || read -p 'Enter the app_base_url: ' app_base_url
		
		if [ ! -d "boldbi_4-2" ]; then mkdir boldbi_4-2; fi
		
		# Downloading deployment files.."
		if [ ! -f "boldbi_4-2/secrets.yaml" ]; then curl -o boldbi_4-2/secrets.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v4.2.69/upgrade/secrets.yaml; fi
		if [ ! -f "boldbi_4-2/log4net_config.yaml" ]; then curl -o boldbi_4-2/log4net_config.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v4.2.69/upgrade/log4net_config.yaml; fi
		if [ ! -f "boldbi_4-2/deployment.yaml" ]; then curl -o boldbi_4-2/deployment.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v4.2.69/upgrade/deployment.yaml; fi
		
		# deployment file changes changes
		sed -i "s/<namespace>/$namespace/g" boldbi_4-2/secrets.yaml
		sed -i "s/<widget_bing_map_enable>/$bing_map_enable/g" boldbi_4-2/secrets.yaml
		sed -i "s/<widget_bing_map_api_key>/$bing_map_api_key/g" boldbi_4-2/secrets.yaml
		sed -i "s/<namespace>/$namespace/g" boldbi_4-2/log4net_config.yaml
		sed -i "s/<namespace>/$namespace/g" boldbi_4-2/deployment.yaml
		sed -i "s/<image_tag>/$version/g" boldbi_4-2/deployment.yaml
		sed -i "s,<application_base_url>,$app_base_url,g" boldbi_4-2/deployment.yaml
		sed -i "s/<comma_separated_library_names>/$optional_libs/g" boldbi_4-2/deployment.yaml

		# applying new changes to cluster
		kubectl apply -f boldbi_4-2/secrets.yaml
		kubectl apply -f boldbi_4-2/log4net_config.yaml
		kubectl apply -f boldbi_4-2/deployment.yaml
	fi
fi
