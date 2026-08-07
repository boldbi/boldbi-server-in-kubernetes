# Advanced Configuration

## Client Libraries

The following are the client libraries used in Bold BI by default:

```console
optionalLibs: 'mongodb,mysql,influxdb,snowflake,oracle,npgsql,google,clickhouse'
```

Read the optional client library license agreement from the following link:

[Consent to deploy client libraries](../docs/consent-to-deploy-client-libraries.md)

If you wish to include only specific client libraries note the optional client libraries from the above link as comma-separated names in your values.yaml file.

## Persistent Volume

### Name

Persistent volumes were global resources. So if you already have Bold BI installed in your cluster, then the previous persistent volume name will conflict with the current installation. Change this name to avoid conflicts with previous Bold BI persistent volumes.

By default, the persistent volume name used in Bold BI is `bold-fileserver`. 

```console
persistentVolume:
  # persistent volumes were global resources. 
  # so if you already have Bold BI installed in your cluster, 
  # then the previous persistent volume name will conflict with current installation.
  # Change this name to avoid conflicts with previous Bold BI persistent volumes.
  name: bold-fileserver
```

### Capacity

Generally, a PV will have a specific storage capacity. This is set using the PV's capacity attribute. See the [Kubernetes Resource Model](https://git.k8s.io/community/contributors/design-proposals/scheduling/resources.md) to understand the units expected by capacity.

By default, the persistent volume capacity used in Bold BI is `3Gi`. 

```console
persistentVolume:
  capacity: 3Gi
```

### Persistent volume configuration for each cluster

1. ACK

```console
clusterProvider: ack
    
persistentVolume:
  ack:
    serverName: ''
    filePath: '/bold-services'
```
<br/>
<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using. In this case the clusterProvider value is <i>ack</i>
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.ack.serverName
      </td>
      <td>
       The <i><host_name_of_mount_target></i> for your NAS file system.
      </td>
    </tr>
      <tr>
      <td>
       persistentVolume.ack.filePath
      </td>
      <td>
       This field represents the file path of the app_data files. The default location is mentioned as "bold-services.
      </td>
    </tr>
</table>
<br/>

2. GKE

```console
clusterProvider: gke
    
persistentVolume:
  gke:
    fileShareName: <file_share_name>
    fileShareIp: <file_share_ip_address>
```
<br/>
<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using. In this case the clusterProvider value is <i>gke</i>
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.gke.fileShareName
      </td>
      <td>
       The <i>File share name</i> of your filestore instance.
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.gke.fileShareIp
      </td>
      <td>
       The <i>IP address</i> of your filestore instance.
      </td>
    </tr>
</table>
<br/>


3. EKS

```console
clusterProvider: eks
    
persistentVolume:
  eks:
    efsFileSystemId: <efs_file_system_id>
```

<br/>
<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using. In this case the clusterProvider value is <i>eks</i>
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.eks.efsFileSystemId
      </td>
      <td>
       The <i>File system ID</i> of your EFS file system.
      </td>
    </tr>
</table>
<br/>

4. AKS

```console
clusterProvider: aks
    
persistentVolume:
  aks:
    fileShareName: <file_share_name>
    # base64 string
    azureStorageAccountName: <base64_azurestorageaccountname>
    # base64 string
    azureStorageAccountKey: <base64_azurestorageaccountkey>
```
<br/>
<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using. In this case the clusterProvider value is <i>aks</i>
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.aks.fileShareName
      </td>
      <td>
       The <i>File share name</i> of your File share instance.
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.aks.azureStorageAccountName
      </td>
      <td>
       The <i>base64 encoded storage account name</i> of the File share instance in your storage account.
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.aks.azureStorageAccountKey
      </td>
      <td>
       The <i>base64 encoded storage account key</i> of the File share instance in your storage account.
      </td>
    </tr>
</table>
<br/>

> **NOTE:** The Azure storage account credentials will be maintained in a secret named `bold-azure-secret`

5. AKS WITH NFS FILESHARE

```console
clusterProvider: aks
    
persistentVolume:
  aks:
    nfs:
      # fileshare name as 'storageaccountname/filesharename'.
      fileShareName: '<storageaccountname/filesharename>'

      # hostname of the fileshare Ex:premiumstorage1234.file.core.windows.net.
      hostName: '<hostname>'
```

<br/>
<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using. In this case the clusterProvider value is <i>aks</i>
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.aks.nfs.fileShareName
      </td>
      <td>
       The <i>Storage account</i> and <i>File share name</i> of your nfs File share instance.
       Ex: Ex:premiumstorage1234/boldbi
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.aks.nfs.hostName
      </td>
      <td>
       The host name of your nfs fileshare instance.
       Ex: premiumstore12345.file.core.windows.net
      </td>
    </tr>
</table>
<br/>

> **NOTE:** The premium storage account of the NFS fileshare must be within the same subscription as the AKS cluster.

6. OKE

```console
clusterProvider: oke

persistentVolume:
  # persistent volumes were global resources. 
  # so if you already have Bold BI installed in your cluster, then the previous persistent volume name will conflict with current installation.
  # Change this name to avoid conflicts with previous Bold BI persistent volumes.
  name: bold-fileserver
  capacity: 5Gi
  oke:
    # Mention your filesystem volume handle in the format of <FileSystemOCID>:<MountTargetIP>:<path>
    volumeHandle: '<FileSystemOCID>:<MountTargetIP>:<path>'
<br/>
```

<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using. In this case the clusterProvider value is <i>oke</i>
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume.oke.volumeHandle
      </td>
      <td>
       The <i>Volume Handle</i> of your Oracle file system. </br> where: </br></br>
        FileSystemOCID - is the OCID of the file system defined in the File Storage service.</br></br>
        MountTargetIP - is the IP address assigned to the mount target.</br></br>
        path - is the mount path to the file system relative to the mount target IP address, starting with a slash. 
        </br>
        For example: ocid1.filesystem.oc1.iad.aaaa______j2xw:10.0.0.6:/FileSystem1
      </td>
    </tr>
</table>
<br/>

## Image

We need to give an image tag for Bold BI, Bold Reports, and ID. By default set the latest version of image tags. You can change a tag based on requirements and the tag overrides the image tag whose default is in the chart appVersion.<br>
```console
image:
  idRepo: us-docker.pkg.dev/boldbi-294612/boldbi
  biRepo: us-docker.pkg.dev/boldbi-294612/boldbi
  reportsRepo: us-docker.pkg.dev/boldreports/multi-container
  # Overrides the image tag whose default is the chart appVersion.
  idTag: 16.2.5
  biTag: 16.2.5
  reportsTag: 14.1.12
````
Repository details are available in the image section to refer to the image tags. No need to change the repository details for idRepo, biRepo, and reportsRepo.

## Version

By default, the latest version of Bold BI, Bold Reports, and IDP is in the version section. You can change a version based on requirements.
```console
versions:
  idp: "4.2.1"
  bi: "16.2.5"
  reports: "14.1.12"
````
> **NOTE:**  We need give a latest version of `idp` when you have latest version of Bold BI or Bold Reports version

## Load Balancing

### Ingress-Nginx

By default, Nginx is used as a reverse proxy for Bold BI. To configure load balancing in Bold BI take a look at the below snippet. 

```console
loadBalancer:
  type: nginx
```

The default `ingressClassName` is `nginx`. Please refer [here](https://kubernetes.io/docs/concepts/services-networking/ingress/#deprecated-annotation) for more details.

```console
loadBalancer:
  # For Kubernetes >= 1.18 you should specify the ingress-controller via the field ingressClassName
  # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
  # ingressClassName: nginx
```

### Istio Ingress Gateway

If you need to configure Bold BI with Istio then you can change the value as `istio` in your configuration like below:

```console
loadBalancer:
  type: istio
```

### Kong-API Ingress

If you need to configure Bold BI with Kong Api Gateway then you can change the value as `kong` in your configuration like below:

```console
loadBalancer:
  type: kong
```

### sticky session

You can change the affinityCookieExpiration time. The default value is 600s.

```console
loadBalancer:
  affinityCookie:
    enable: true
    affinityCookieExpiration: 600
```

### SSL Configuration

If you have the SSL certificate for your DNS and need to configure the site with your SSL certificate, just pass your DNS with the `https` protocol to `appBaseUrl`, by doing this it will automatically enable SSL in both Ingress and Istio.

> **NOTE:**  You need to create a TLS secret named bold-tls. If you choose a different name for the secret, make sure to update the values.yaml file accordingly so it matches the name of the secret you created.

#### Creating TLS Secrets for Ingress Controllers in Kubernetes

To enable HTTPS (SSL) in your Kubernetes cluster, you need to create a TLS secret that contains your certificate and private key. The process differs slightly depending on the ingress controller you're using.

##### **For NGINX Ingress or Kong API Gateway**

Use the following command to create a TLS secret in your desired namespace:

```bash
kubectl create secret tls <tls secret name> -n <namespace>  --key <key-path> --cert <certificate-path>
```

##### **For Istio Ingress Gateway**

Istio requires the TLS secret to be created in the `istio-system` namespace. Use the command below:

```bash
kubectl create secret tls <tls secret name> -n istio-system --key <key-path> --cert <certificate-path>
```

**Example:**

```bash
kubectl create secret tls bold-tls -n bold-services --key <key-path> --cert <certificate-path>
```

#### Notes

* Replace `<path-to-certificate-file>` and `<path-to-key-file>` with the actual paths to your certificate and private key files.
* The secret name (`bold-tls` in the examples) must match the one referenced in your Ingress configuration.
* Ensure the namespace (`-n`) matches the one where your ingress controller is running.


### Map multiple domains

You can map multiple domains for **both Ingress NGINX** and **Istio Ingress Gateway** using the same configuration format.
While mapping multiple domains, you must include the `appBaseUrl` in **any one** of the matching host arrays.

For a multiple-domain scenario, the `singleHost` secret will **not** be used — you must specify the certificate secret inside the `multipleHost` section.


**Example:**

```yaml
loadBalancer:
  singleHost:
    secretName: bold-tls  # Used only for single domain setups

  multipleHost:
    hostArray:
      - hosts: 
          - cd1.abc.com
          - cd2.abc.com
        secretName: tls-secret1
      - hosts: 
          - cd1.xyz.com
          - cd2.xyz.com
        secretName: tls-secret2
```
## Auto Scaling

By default, autoscaling is enabled in Bold BI, to disable autoscaling please set `autoscaling.enabled=false`.

```console
autoscaling:
  enabled: true
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
  behavior:
    stabilizationWindowSeconds: 60
    podsValue: 1
    podsPeriodSeconds: 60
    percentValue: 10
    percentPeriodSeconds: 60
```

<br/>
<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       autoscaling.enabled
      </td>
      <td>
       By default, autoscaling will be enabled. turn this to <i>false</i> to disable the autoscaling functionality.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling.targetCPUUtilizationPercentage
      </td>
      <td>
       The CPU utilization is the average CPU usage of all pods in a deployment across the last minute divided by the requested CPU of this deployment.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling.targetMemoryUtilizationPercentage
      </td>
      <td>
       With this metric, the HPA controller will keep the average utilization of the pods in the scaling target at the value mentioned (80%). Utilization is the ratio between the current usage of resources to the requested resources of the pod.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling.behavior.stabilizationWindowSeconds
      </td>
      <td>
       The stabilization window is used by the autoscaling algorithm to consider the computed desired state from the past to prevent scaling. By default, the value is 60 to provide a custom downscale stabilization window of 1 minute.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling.behavior.podsValue<br/>
       autoscaling.behavior.podsPeriodSeconds
      </td>
      <td>
       This policy (Pods) allows 1 replica to be scaled down in one minute.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling.behavior.percentValue<br/>
       autoscaling.behavior.percentPeriodSeconds
      </td>
      <td>
       This policy (Percent) allows at most 10% of the current replicas to be scaled down in one minute.
      </td>
    </tr>
</table>
<br/>

## Bing Map Widget

If you need to use **Bing Map** widget feature, enable this to `true` and API key value for `<widget_bing_map_api_key>`. By default this feature will be set to false.

```console
bingMapWidget:
  enabled: <true / false>
  apiKey: <widget_bing_map_api_key>
```

> **Note:** The Bing Map keys will be maintained in a secret named `bold-secret`
