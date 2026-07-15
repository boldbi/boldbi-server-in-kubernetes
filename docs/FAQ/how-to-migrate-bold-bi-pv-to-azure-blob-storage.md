# Bold BI PV to Azure Blob Storage Migration on Kubernetes

This document describes the steps to migrate Bold BI application data from a Persistent Volume (PV) to **Azure Blob Storage** on a Kubernetes cluster.

---

## 1. Update the Bold BI Helm Repository
Use the following commands to update the Bold BI Helm repository:

```sh
helm repo update
```
**Troubleshooting: repo 404 when running `helm repo update`**

If you see an error like:

```
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "boldbi" chart repository (https://boldbi.github.io/boldbi-kubernetes):
        failed to fetch https://boldbi.github.io/boldbi-kubernetes/index.yaml : 404 Not Found
```

remove and re-add the repository (this fixes a stale/incorrect repo entry), then update:

```console
helm repo remove boldbi
helm repo add boldbi https://boldbi.github.io/boldbi-server-in-kubernetes
helm repo update
```

## 2. Update Image Repository and Tag
If using an existing `values.yaml` file, update the image repository and tag with the latest values provided.

- **Image Repo:** us-docker.pkg.dev/boldbi-294612/boldbi
- **Image Tag:** 16.1.90

## 3. Update Logging Configuration
Inside your `values.yaml`, update logging settings:

```yaml
logging:
  level: "both"   # info | error | both
  output: "console"  # console | file | both
```

## 4. Configure Azure Blob Storage Details
Update your Azure Blob Storage configuration values in the `values.yaml` file.

```yaml
azureStorage:
  # Enable Azure Blob storage backend (required: set to true to use Azure)
  enabled: false
  # Azure Blob access key for authentication
  accessKey: 
  # Azure Blob account name
  accountName: 
  # Name of the Azure Blob container to use for storage
  containerName: 
  # Azure Blob connection type (e.g., default, managedidentity)
  connectionType: 
  # Azure Blob storage URI (e.g., for managed identity authentication)
  storageUri: 
  # Type of Azure storage (set to 1 for Azure Blob)
  storageType: 1
```

![oci_value](images/azure_blob_storage_value.png)

## 5. Upgrade the Bold BI Deployment
Run the following command to upgrade Bold BI using the updated `values.yaml` file:

```sh
helm upgrade boldbi boldbi/boldbi -f <my-values.yaml> -n bold-services
```
`Note:` After upgrading Bold BI with Azure Blob storage values using the Helm chart, the bi-web and bi-api services may temporarily become unavailable. This is expected behavior; you can proceed with the next step.

## 6. Access the idp-web Pod
Verify pods are running and open a shell into the **idp-web** pod:

```sh
kubectl get pods -n bold-services
kubectl exec -it <idp-web-pod-name> -n bold-services -- bash
```
![pod_status_oci](images/pod_status_oci.png)
![pod_exec](images/pod_exec.png)

## 7. Run the Migration Utility
Inside the pod, navigate and execute migration command:

```sh
cd /application/utilities/adminutils
dotnet Syncfusion.Server.Commands.Utility.dll migrate storage pv-to-azureblob
```

![pod_exec](images/azure_blob_utility.png)

Wait until the migration completes successfully.

## 8. Remove PV Configuration and Upgrade Again

- After migration from Persistent Volumes to Azure Blob Storage, remove all Persistent Volume (PV) configurations value from `values.yaml`
  
  ![oci_remove_pv](images/remove_pv.png)

- Upgrade again:

```sh
helm upgrade boldbi boldbi/kc281670 -f <my-values.yaml> -n bold-services
```

## 9. Verify the Application
Once all pods are running, open the Bold BI application using the configured base URL.

![pod_status_without_pv](images/pod_status_without_pv.png)

Migration is now complete, and Bold BI is fully running on **Azure Blob Object Storage**.

