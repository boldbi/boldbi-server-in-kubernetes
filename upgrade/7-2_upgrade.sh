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
	
	if [[ "$version" == *"7.2"* ]]
	then
		[ -n "$app_base_url" ] || read -p 'Enter the app_base_url: ' app_base_url
		
		if [ ! -d "boldbi_7-2" ]; then mkdir boldbi_7-2; fi
		
		# Downloading deployment files.."
		if [ ! -f "boldbi_7-2/service.yaml" ]; then curl -o boldbi_7-2/service.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v7.2.8/deploy/service.yaml; fi
		if [ ! -f "boldbi_7-2/hpa.yaml" ]; then curl -o boldbi_7-2/hpa.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v7.2.8/deploy/hpa.yaml; fi
		if [ ! -f "boldbi_7-2/deployment.yaml" ]; then curl -o boldbi_7-2/deployment.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v7.2.8/deploy/deployment.yaml; fi
		if [ ! -f "boldbi_7-2/ingress.yaml" ]; then curl -o boldbi_7-2/ingress.yaml https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v7.2.8/deploy/ingress.yaml; fi

		# deployment file changes changes
		sed -i "s/<namespace>/$namespace/g" boldbi_7-2/service.yaml
		sed -i "s/<namespace>/$namespace/g" boldbi_7-2/hpa.yaml
		sed -i "s/<namespace>/$namespace/g" boldbi_7-2/deployment.yaml
		sed -i "s/<namespace>/$namespace/g" boldbi_7-2/ingress.yaml
		sed -i "s/<image_tag>/$version/g" boldbi_7-2/deployment.yaml
		sed -i "s,<application_base_url>,$app_base_url,g" boldbi_7-2/deployment.yaml

		# applying new changes to cluster
		kubectl apply -f boldbi_7-2/deployment.yaml
        	kubectl apply -f boldbi_7-2/service.yaml
        	kubectl apply -f boldbi_7-2/hpa.yaml
	 
		# Update ingress file with app_base url before applying.  		
		# Function to check if a string is an IP address
		is_ip() {
		  [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
		}
		
		# Extract the protocol and domain from the URL
		protocol=$(echo "$app_base_url" | awk -F: '{print $1}')
		domain=$(echo "$app_base_url" | awk -F[/:] '{print $4}')
  
  		# Check if app_base_url is an IP address
		if is_ip "$domain"; then
		  kubectl apply -f boldbi_7-2/ingress.yaml
		else
		  # Update the Ingress file based on the protocol
		  if [ "$protocol" == "http" ]; then
		    sed -i -e "s|^ *- #host: example.com|  - host: $domain|" "boldbi_7-2/ingress.yaml"
		    kubectl apply -f boldbi_7-2/ingress.yaml
		  elif [ "$protocol" == "https" ]; then
		    sed -i -e "s|^ *#tls|  tls|" "boldbi_7-2/ingress.yaml"
		    sed -i -e "s|^ *#- hosts:|  - hosts:|" "boldbi_7-2/ingress.yaml"
		    sed -i -e "s|^ *#- example.com|    - $domain|" "boldbi_7-2/ingress.yaml"
		    sed -i -e "s|^ *#secretName: bold-tls|    secretName: bold-tls|" "boldbi_7-2/ingress.yaml"
		    sed -i -e "s|^ *- #host: example.com|  - host: $domain|" "boldbi_7-2/ingress.yaml"
		    kubectl apply -f boldbi_7-2/ingress.yaml
		  fi
		fi
	fi
fi
