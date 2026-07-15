# Deploy Bold BI and Bold Reports using Helm

This chart installs both [Bold BI](https://www.boldbi.com/) and [Bold Reports](https://www.boldreports.com/) on Kubernetes. You can create Kubernetes cluster on cloud infrastructure. Please follow the below documentation for Bold BI and Bold Reports deployment in a specific cloud environments.
    
## Deployment prerequisites

* [Install Helm](https://helm.sh/docs/intro/install/) to deploy Bold BI using Helm.
* [File Storage](/helm/docs/pre-requisites.md#file-storage)
* [Create and connect a cluster](/helm/docs/pre-requisites.md#create-a-cluster)
* [Load Balancing](/helm/docs/pre-requisites.md#load-balancing)

> **Note:** Note the [Ingress IP address](/helm/docs/pre-requisites.md#get-ingress-ip) to use it while crafting values.yaml when installing Bold BI with helm chart.

## Get Repo Info

1. Add the Bold BI helm repository

```console
helm repo add boldbi https://boldbi.github.io/boldbi-server-in-kubernetes
helm repo update
```

2. View charts in repo

```console
helm search repo boldbi

NAME            CHART VERSION   APP VERSION     DESCRIPTION
boldbi/bold-common   16.1.90           16.1.90          Embed powerful analytics inside your apps and t...
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

For Helm chart, you'll need to craft a `values.yaml`.

* For `GKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/common-gke-values.yaml).
* For `EKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/common-eks-values.yaml).
* For `AKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/common-aks-values.yaml).
* For `ACK` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/common-ack-values.yaml).
* For `OKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/common-oke-values.yaml).

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
       namespace
      </td>
      <td>
       The namespace in which the Bold BI resources will be dpleoyed in the kubernetes cluster.<br/>
       The default namespace is <i>bold-services</i>
      </td>
    </tr>
    <tr>
      <td>
       appBaseUrl *
      </td>
      <td>
       Domain or <a href='/helm/docs/pre-requisites.md#get-ingress-ip'>Ingress IP address</a> with http/https protocol. Follow the <a href='/helm/docs/common-configuration.md#ssl-configuration'>SSL Configuration</a> to configure SSL certificate for https protocol after deploying Bold BI in your cluster.
      </td>
    </tr>
    <tr>
      <td>
       optionalLibs
      </td>
      <td>
       These are the client libraries used in Bold BI by default.<br/>
       '<i>mongodb,mysql,influxdb,snowflake,oracle,npgsql</i>'<br/>
       Please refer to <a href='/helm/docs/common-configuration.md#client-libraries'>Optional Client Libraries</a> section to know more.
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using.<br/>
       The recommended values are '<i>gke,eks,aks and onpremise</i>'
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume*
      </td>
      <td>
       Please refer to <a href='/helm/docs/common-configuration.md#persistent-volume'>this</a> section to know more on how to set Persistant Volumes for Bold BI.
      </td>
    </tr>
        <tr>
      <td>
       image *
      </td>
      <td>     
       By default latest image tag is used in the Helm chart. Please refer to <a href='/helm/docs/common-configuration.md#image'>this</a> section for configure a image tag for Bold BI, Bold Reports and ID. 
      </td>
    </tr>
    <tr>
      <td>
       versions *
      </td>
      <td>
       By default latest version is used in the Helm chart. Please refer to <a href='/helm/docs/common-configuration.md#version'>this</a> section for configure a version for Bold BI, Bold Reports and IDP version 
      </td>
    </tr>
    <tr>
      <td>
       loadBalancer
      </td>
      <td>
       Currently, we have provided support for Nginx and Istio as Load Balancers in Bold BI. Please refer to <a href='/helm/docs/common-configuration.md#load-balancing'>this</a> section for configuring Load balancer for Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling
      </td>
      <td>
       By default autoscaling is enabled in Bold BI. Please refer to <a href='/helm/docs/common-configuration.md#auto-scaling'>this</a> section to configure autoscaling in Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       bingMapWidget
      </td>
      <td>
       Please refer to <a href='/helm/docs/common-configuration.md#bing-map-widget'>this</a> section to configure Bing Map Widget in Bold BI.
      </td>
    </tr>
        </tr>
        <tr>
      <td>
       customSizePdfExport
      </td>
      <td>
       To utilize a customized page size for A4 PDF export, set this feature to true. By default, this feature is set to false.
      </td>
    </tr>
        <tr>
      <td>
       browserTimeZone
      </td>
      <td>
       If you need to use Browser time zone feature , enable this to true. By default this feature will be set to false. 
      </td>
    </tr>
</table>
<br/>

> **Note:** Items marked with `*` are mandatory fields in values.yaml

Run the following command to delpoy Bold BI in your cluster.

```console
helm install [RELEASE_NAME] boldbi/bold-common -f [Crafted values.yaml file] --create-namespace -n bold-services
```
Ex:  `helm install boldbi boldbi/bold-common -f my-values.yaml --create-namespace -n bold-services`

Refer [here](/helm/docs/common-configuration.md) for advanced configuration including SSL configuration, optional client libraries, etc.

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Upgrade

Run the following command to get the latest version of Bold BI helm chart.

```console
helm repo update
```

Run the below command to apply changes in your Bold BI release or upgrading Bold BI to latest version.

```console
helm upgrade [RELEASE_NAME] boldbi/bold-common -f [Crafted values.yaml file] -n bold-services
```

Ex:  `helm upgrade boldbi boldbi/bold-common -f my-values.yaml -n bold-services`

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```
Ex:  `helm uninstall boldbi -n bold-services`

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Application Startup

1. Configure the Bold BI application startup to use the application. Please refer to the following link for more details on configuring the application startup.
    
   https://help.boldbi.com/embedded-bi/application-startup

2. Navigate to administration configuration file.
   ```sh
   <DNS>/ums/administration/config-editor
   ```
   ![Configuration-editor](/helm/docs/images/config-edit.png)

3. In product.json file, append the Internal URL for Bold reportes services as shown below :

   ![product-url-editor](/helm/docs/images/product-update-url.png)


5. In product.json file, append the lines below for Bold Reports:
    ```console
    {
    "Name": "BoldReports",
    "SetupName": "BoldReports_EnterpriseReporting",
    "Version": "4.2.52",
    "IDPVersion": "3.1.21",
    "IsCommonLogin": true
    }
    ```
   >**Note:** The IDP version of Bold BI or Bold Reports should be same.

6. Set `IsCommonLogin` property to be `true` for Bold BI and Bold Reports.
     ![Product Json](/helm/docs/images/reports.png)
   
7. Restart the deployment using the following command to apply the changes:

   ```sh
   kubectl rollout restart deployment -n [namespace]
   ```
8. Refer to the document below to activate the License either by using your login credentials or by an offline unlock key for Bold Reports.
    https://help.boldreports.com/enterprise-reporting/administrator-guide/application-startup/#activate-bold-reports-license

## Documentation Links:

 * [Bold BI](https://help.boldbi.com/) <br>
 * [Bold Reports](https://help.boldreports.com/) 
