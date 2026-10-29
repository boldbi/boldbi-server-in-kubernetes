{{- define "boldbi.upgradeCenter.storage" -}}
{{- $selected := "FileSystem" -}}
{{- $settings := dict -}}
{{- /* Same order as the product deployment's BOLD_SERVICES_STORAGETYPE entries. */ -}}
{{- range $item := list (dict "name" "OCIObjectStorage" "settings" (default dict .Values.ociStorage)) (dict "name" "AmazonS3" "settings" (default dict .Values.s3Storage)) (dict "name" "AzureBlob" "settings" (default dict .Values.azureStorage)) -}}
{{- if $item.settings.enabled -}}
{{- $selected = $item.name -}}
{{- $settings = $item.settings -}}
{{- end -}}
{{- end -}}
{{- $environment := dict -}}
{{- $credentials := dict -}}
{{- if eq $selected "AmazonS3" -}}
  {{- $_ := set $environment "BOLD_SERVICES_AMAZON_BUCKET_NAME" (default "" $settings.bucketName) -}}
  {{- $_ := set $environment "BOLD_SERVICES_AWS_REGION" (default "" $settings.region) -}}
  {{- $_ := set $environment "BOLD_SERVICES_AMAZON_ROOTFOLDER_NAME" (default "" $settings.rootFolderName) -}}
  {{- $_ := set $credentials "BOLD_SERVICES_AWS_ACCESS_KEY_ID" (default "" $settings.accessKey) -}}
  {{- $_ := set $credentials "BOLD_SERVICES_AWS_SECRET_ACCESS_KEY" (default "" $settings.secretKey) -}}
{{- else if eq $selected "AzureBlob" -}}
  {{- $_ := set $environment "BOLD_SERVICES_AZUREBLOB_ACCOUNT_NAME" (default "" $settings.accountName) -}}
  {{- $_ := set $environment "BOLD_SERVICES_AZUREBLOB_CONTAINER_NAME" (default "" $settings.containerName) -}}
  {{- $_ := set $environment "BOLD_SERVICES_AZUREBLOB_CONNECTION_TYPE" (default "" $settings.connectionType) -}}
  {{- $_ := set $environment "BOLD_SERVICES_AZUREBLOB_STORAGE_URI" (default "" $settings.storageUri) -}}
  {{- $_ := set $credentials "BOLD_SERVICES_AZUREBLOB_ACCESSKEY" (default "" $settings.accessKey) -}}
{{- else if eq $selected "OCIObjectStorage" -}}
  {{- $_ := set $environment "BOLD_SERVICES_OCI_BUCKET_NAME" (default "" $settings.bucketName) -}}
  {{- $_ := set $environment "BOLD_SERVICES_OCI_REGION" (default "" $settings.region) -}}
  {{- $_ := set $environment "BOLD_SERVICES_OCI_ROOTFOLDER_NAME" (default "" $settings.rootFolderName) -}}
  {{- $_ := set $environment "BOLD_SERVICES_OCI_NAME_SPACE" (default "" $settings.namespace) -}}
  {{- $_ := set $credentials "BOLD_SERVICES_OCI_ACCESS_KEY" (default "" $settings.accessKey) -}}
  {{- $_ := set $credentials "BOLD_SERVICES_OCI_SECRET_KEY" (default "" $settings.secretKey) -}}
{{- end -}}
{{- if ne $selected "FileSystem" -}}
{{- $type := toString (default "" $settings.storageType) -}}
{{- $_ := set $environment "BOLD_SERVICES_STORAGETYPE" $type -}}
{{- $selected = default $selected (index (dict "" "FileSystem" "0" "FileSystem" "filestorage" "FileSystem" "1" "AzureBlob" "azureblob" "AzureBlob" "3" "AmazonS3" "amazons3" "AmazonS3" "4" "OCIObjectStorage" "ociobjectstorage" "OCIObjectStorage") (lower $type)) -}}
{{- end -}}
{{- dict "source" $selected "environment" $environment "credentials" $credentials | toYaml -}}
{{- end -}}
