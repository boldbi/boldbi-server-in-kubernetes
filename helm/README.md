# Deploy Bold BI using Helm

This chart installs [Bold BI](https://www.boldbi.com/) on Kubernetes. You can create Kubernetes cluster in cloud cluster providers(GKE, AKS, EKS and OKE). Please follow the below documentation for Bold BI deployment in a specific cloud environments.

## Deployment prerequisites

* [Install Helm](https://helm.sh/docs/intro/install/) to deploy Bold BI using Helm.
* [Install Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [File Storage](docs/pre-requisites.md#file-storage)
* [Create and connect a cluster](docs/pre-requisites.md#create-and-connect-a-cluster)
* [Load Balancing](docs/pre-requisites.md#load-balancing)

> **Note:** Note the [Ingress IP address](docs/pre-requisites.md#get-ingress-ip) and map it with a DNS to crafting values.yaml when installing Bold BI with helm chart.

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
boldbi/boldbi   16.1.90           16.1.90         Embed powerful analytics inside your apps and t...
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

For Helm chart, you'll need to craft a `values.yaml`.

* For `GKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/gke-values.yaml).
* For `EKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/eks-values.yaml).
* For `AKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/aks-values.yaml).
* For `OKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/oke-values.yaml).
* For `ACK` please download the values.yaml file [here](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main/helm/custom-values/ack-values.yaml).

> **Note:** Items marked with `*` are mandatory fields in values.yaml

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
       The namespace in which the Bold BI resources will be deployed in the kubernetes cluster.<br/>
       The default namespace is <i>bold-services</i>.
      </td>
    </tr>
    <tr>
      <td>
       appBaseUrl *
      </td>
      <td>
       Domain with http/https protocol. Follow the <a href='docs/configuration.md#ssl-configuration'>SSL Configuration</a> to configure SSL certificate for https protocol after deploying Bold BI in your cluster.
      </td>
    </tr>
    <tr>
      <td>
       optionalLibs
      </td>
      <td>
       These are the client libraries used in Bold BI by default.<br/>
       '<i>mongodb,mysql,influxdb,snowflake,oracle,google,clickhouse</i>'<br/>
       Please refer to <a href='docs/configuration.md#client-libraries'>Optional Client Libraries</a> section to know more.
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using.<br/>
       The recommended values are '<i>gke,eks, aks and oke</i>'.
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume *
      </td>
      <td>
       Please refer to <a href='docs/configuration.md#persistent-volume'>this</a> section to know more on how to set Persistant Volumes for Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       loadBalancer
      </td>
      <td>
       Currently we have provided support for Nginx, Istio and Kong as Load Balancers in Bold BI. Please refer to <a href='docs/configuration.md#load-balancing'>this</a> section for configuring Load balancer for Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       subApplication
      </td>
      <td>
       Set **enabled: true** if you want to host your application under a subpath. Use subPath to specify the desired subpath (default is boldservices).
      </td>
    </tr>
    <tr>
      <td>
       autoscaling
      </td>
      <td>
       By default autoscaling is enabled in Bold BI. Please refer to <a href='docs/configuration.md#auto-scaling'>this</a> section to configure autoscaling in Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       bingMapWidget
      </td>
      <td>
       Please refer to <a href='docs/configuration.md#bing-map-widget'>this</a> section to configure Bing Map Widget in Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       customLocalePath
      </td>
      <td>
       `customLocalePath` specifies the file path to a customer-provided localization resource. This file contains translations of strings, labels, messages, and other UI text elements customized for the customer's language and regional preferences.
      </td>
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
        <tr>
      <td>
       useSiteIdendifier
      </td>
      <td>
       The variable is optional, and the default value is TRUE. 
       By default, all sites in Bold BI require a site identifier, which differentiates sites on the same domain. That is https://example.com/bi/site/<site_identifier>
       You can ignore the site identifier by setting the value as FALSE. If the site identifier is disabled, each site requires a unique domain.
      </td>
    </tr>
        <tr>
      <td>
       queryMetricsInDebugFiles
      </td>
      <td>
       If the query metrics needs to be logged in debug files, enable this to true. By default, this option is set to false.
      </td>
    </tr>
        <tr>
      <td>
       queryMetricsWithQueryInDebugFiles
      </td>
      <td>
       If the query and query metrics needs to be logged in debug files, enable this to true. By default, this option is set to false.
      </td>
    </tr>
    </tr>
        <tr>
      <td>
       azureApplicationInsights:<br />
       connectionString: ""
      </td>
      <td>
       Integrating Azure Application Insights with Bold BI Enterprise Edition enables you to track and visualize your application's performance, detect issues, and enhance your application's overall reliability.
      </td>
    </tr>
        <tr>
      <td>
        tolerationEnable: false<br />
        tolerations:
      </td>
      <td>
        Tolerations allow pods to be scheduled onto nodes with matching <b>taints</b>. 
        By default, this is set to <code>false</code>. 
        <br /> 
        Set this to <code>true</code> if your cluster uses tolerations. 
        <br />
        You can define multiple tolerations with the following fields:
        <ul>
          <li><b>key</b>: The taint key to tolerate.</li>
          <li><b>operator</b>: Defines how the key is compared (e.g., <code>Equal</code>, <code>Exists</code>).</li>
          <li><b>value</b>: The taint value to match.</li>
          <li><b>effect</b>: The effect of the taint to tolerate (e.g., <code>NoSchedule</code>, <code>NoExecute</code>).</li>
        </ul>
        For more details, see the Kubernetes documentation on 
        <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/" target="_blank">Taints and Tolerations</a>.
      </td>
    </tr>
    <tr>
      <td>
        nodeAffinityEnable: false<br />
        nodeAffinity:
      </td>
      <td>
        Node affinity ensures that pods are scheduled onto nodes with matching <b>labels</b>. 
        By default, this is set to <code>false</code>. 
        <br />
        Set this to <code>true</code> if you want to enforce node affinity in your cluster. 
        <br />
        Define affinity rules using:
        <ul>
          <li><b>key</b>: Node label key.</li>
          <li><b>operator</b>: How the key is compared (e.g., <code>In</code>, <code>NotIn</code>).</li>
          <li><b>value</b>: Label values to match.</li>
        </ul>
        Reference: <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity" target="_blank">Kubernetes Node Affinity</a>.
      </td>
    </tr>
    <tr>
      <td>
        podAffinityEnable: false
      </td>
      <td>
        Pod affinity allows you to schedule pods onto nodes where other specific pods are already running. 
        By default, this is set to <code>false</code>. 
        <br />
        Use pod affinity when you want pods to run <b>together</b> for performance, locality, or dependency reasons. 
        <br />
        Reference: <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity" target="_blank">Kubernetes Pod Affinity</a>.
      </td>
    </tr>
    <tr>
      <td>
        podAntiAffinityEnable: false
      </td>
      <td>
        Pod anti-affinity ensures that pods are <b>not</b> scheduled onto nodes where other specific pods are running. 
        By default, this is set to <code>false</code>. 
        <br />
        Use pod anti-affinity to improve reliability by spreading pods across different nodes. 
        <br />
        Reference: <a href="https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity" target="_blank">Kubernetes Pod Anti-Affinity</a>.
      </td>
    </tr>
    </table>
<br/>

## Environment variables for configuring Application Startup in backend

The following environment variables are optional. If not provided, a manual Application Startup configuration is needed.

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
       licenseKey
      </td>
      <td>
       License key of Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       email *
      </td>
      <td>
       It should be a valid email.
      </td>
    </tr>
    <tr>
      <td>
       password *
      </td>
      <td>
       It should meet our password requirements. <br /> <br />Note: <br />The password must meet the following requirements: it must contain at least 6 characters, including 1 uppercase letter, 1 lowercase letter, 1 numeric character, and 1 special character. 
      </td>
    </tr>
    <tr>
      <td>
       dbType *
      </td>
      <td>
       Type of database server can be used for configuring the Bold BI.<br/><br />The following DB types are accepted:<br />1. mssql – Microsoft SQL Server/Azure SQL Database<br />2. postgresql – PostgreSQL Server<br />3. mysql – MySQL/MariaDB Server<br />4. oracle – Oracle Server
      </td>
    </tr>
    <tr>
      <td>
       dbHost *
      </td>
      <td>
       Name of the Database Server
      </td>
    </tr>
    <tr>
      <td>
       dbPort
      </td>
      <td>
       The system will use the following default port numbers based on the database server type.<br />PostgrSQL – 5432<br />MySQL -3306<br />Oracle - 1521<br />Please specify the port number for your database server if it is configured on a different port.<br /><br />For MS SQL Server, this parameter is not necessary.
      </td>
    </tr>
    <tr>
      <td>
       dbUser *
      </td>
      <td>
       Username for the database server<br /><br />Please refer to [this documentation](https://help.boldbi.com/embedded-bi/faq/what-are-the-database-permissions-required-to-set-up-bold-bi-embedded/) for information on the user's permissions.
      </td>
    </tr>
    <tr>
      <td>
       dbPassword *
      </td>
      <td>
       The database user's password
      </td>
    </tr>
    <tr>
      <td>
       dbName
      </td>
      <td>
       If the database name is not specified, the system will create a new database called bold-services.<br /><br />If you specify a database name, it should already exist on the server.
      </td>
    </tr>
    <tr>
      <td>
       maintenanceDB
      </td>
      <td>
       For PostgreSQL DB Servers, this is an optional parameter.<br />The system will use the database name `postgres` by default.<br />If your database server uses a different default database, please provide it here.
      </td>
    </tr>
    <tr>
      <td>
       dbAdditionalParameters
      </td>
      <td>
       If your database server requires additional connection string parameters, include them here.<br /><br />Connection string parameters can be found in the official document.<br />My SQL: https://dev.mysql.com/doc/connector-net/en/connector-net-8-0-connection-options.html<br />PostgreSQL: https://www.npgsql.org/doc/connection-string-parameters.html<br />MS SQL: https://docs.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring<br />Oracle: https://docs.oracle.com/en/database/oracle/oracle-database/19/odpnt/ConnectionConnectionString.html<br /><br /><b>Note:</b> A semicolon(;) should be used to separate multiple parameters.
      </td>
    </tr>
    <tr>
      <td>
       dbSchema
      </td>
      <td>
       A database schema defines the structure, organization, and constraints of data within a database, including tables, fields, relationships, and indexes<br /><br />In MSSQL, the default schema is dbo.<br />
       In PostgreSQL, the default schema is public.<br /><br />
       Both schemas contain tables and other database objects by default.
      </td>
    </tr>
</table>
<br/>

## Environment variables for configuring Branding in backend

The following environment variables are optional. If they are not provided, Bold BI will use the default configured values.

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
       mainLogo
      </td>
      <td>   
       This is header logo for the application and the preferred image size is 40 x 40 pixels.
      </td>
    </tr>
    <tr>
      <td>
       loginLogo
      </td>
      <td>     
       This is login logo for the application and the preferred image size is 200 x 40 pixels.
      </td>
    </tr>
    <tr>
      <td>
       emailLogo
      </td>
      <td>     
       This is email logo, and the preferred image size is 200 x 40 pixels.
      </td>
    </tr>
    <tr>
      <td>
       favicon
      </td>
      <td>     
       This is favicon and the preferred image size is 40 x 40 pixels. 
      </td>
    </tr>
    <tr>
      <td>
       footerLogo
      </td>
      <td>     
       This is powered by logo and the preferred size is 100 x 25 pixels.
       <br />
       <br />
       <b>Note:</b><br/>• All the branding variables are accepted as URL.<br/>• <b>Ex:</b> https://example.com/loginlogo.jpg <br/>• <b>Image type:</b> png, svg, jpg, jpeg.<br/>• If you want to use the custom branding, provide the value for all branding variables If all variable values are given, application will use the branding images, otherwise it will take the default logos. 
      </td>
    </tr>
    <tr>
      <td>
       siteName
      </td>
      <td>
      This is organization name.      
      <br />
       If no value is provided, the site will be deployed with the default name: <b>Bold BI Enterprise Dashboards</b>.
      </td>
    </tr>
    <tr>
      <td>
       siteIdentifier
      </td>
      <td>     
       This is site identifier, and it will be the part of the application URL.
      <br />
      If no value is provided, the site will be deployed with the default identifier: <b>site1</b>.
      </td>
    </tr>
</table>
<br/>

## Environment variables for configuring Storage in backend

The following environment variables are optional. If not provided, Bold BI will use the default configured values.

<br/>

### OCI Storage Configuration

To use OCI storage, set `ociStorage.enabled: true`.

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
       ociStorage.enabled
      </td>
      <td>
       Enable OCI storage backend. Set to <code>true</code> to use OCI storage.
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.accessKey
      </td>
      <td>
       OCI access key for authentication (e.g., your OCI user access key).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.bucketName
      </td>
      <td>
       Name of the OCI bucket to use for storage.
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.namespace
      </td>
      <td>
       OCI namespace (tenant OCID or namespace name).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.region
      </td>
      <td>
       OCI region where the bucket is located (e.g., us-ashburn-1).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.rootFolderName
      </td>
      <td>
       Root folder path within the bucket for storing data.
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.secretKey
      </td>
      <td>
       OCI secret key for authentication (e.g., your OCI user secret key).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.storageType
      </td>
      <td>
       Type of OCI storage. Default value is <code>4</code>.
      </td>
    </tr>
</table>
<br/>

### S3 Storage Configuration

To use Amazon S3 storage, set `s3Storage.enabled: true`.

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
       s3Storage.enabled
      </td>
      <td>
       Enable S3 storage backend. Set to <code>true</code> to use S3 storage.
      </td>
    </tr>
    <tr>
      <td>
       s3Storage.accessKey
      </td>
      <td>
       AWS access key ID for authentication (e.g., your IAM user access key ID).
      </td>
    </tr>
    <tr>
      <td>
       s3Storage.bucketName
      </td>
      <td>
       Name of the S3 bucket to use for storage.
      </td>
    </tr>
    <tr>
      <td>
       s3Storage.region
      </td>
      <td>
       AWS region where the bucket is located (e.g., us-east-1).
      </td>
    </tr>
    <tr>
      <td>
       s3Storage.rootFolderName
      </td>
      <td>
       Root folder path within the bucket for storing data.
      </td>
    </tr>
    <tr>
      <td>
       s3Storage.secretKey
      </td>
      <td>
       AWS secret access key for authentication (e.g., your IAM user secret access key).
      </td>
    </tr>
    <tr>
      <td>
       s3Storage.storageType
      </td>
      <td>
       Type of S3 storage. Default value is <code>3</code>.
      </td>
    </tr>
</table>
<br/>

### Azure Blob Storage Configuration

To use Azure Blob storage, set `azureStorage.enabled: true`.

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
       azureStorage.enabled
      </td>
      <td>
       Enable Azure Blob storage backend. Set to <code>true</code> to use Azure Blob storage.
      </td>
    </tr>
    <tr>
      <td>
       azureStorage.accessKey
      </td>
      <td>
       Azure Blob storage access key for authentication.
      </td>
    </tr>
    <tr>
      <td>
       azureStorage.accountName
      </td>
      <td>
       Azure Blob storage account name.
      </td>
    </tr>
    <tr>
      <td>
       azureStorage.containerName
      </td>
      <td>
       Name of the Azure Blob container to use for storage.
      </td>
    </tr>
    <tr>
      <td>
       azureStorage.connectionType
      </td>
      <td>
       Azure Blob connection type (e.g., DefaultEndpointsProtocol).
      </td>
    </tr>
    <tr>
      <td>
       azureStorage.storageUri
      </td>
      <td>
       Azure Blob storage URI endpoint.
      </td>
    </tr>
    <tr>
      <td>
       azureStorage.storageType
      </td>
      <td>
       Type of Azure Blob storage. Default value is <code>1</code>.
      </td>
    </tr>
</table>
<br/>


Run the following command to delpoy Bold BI in your cluster.

```console
kubectl create namespace [namespace-name]

helm install [RELEASE_NAME] boldbi/boldbi -f [Crafted values.yaml file]  -n [namespace-name]

```
Ex:  `helm install boldbi boldbi/boldbi -f my-values.yaml -n bold-services`

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Upgrade

- Run the following command to get the latest version of Bold BI helm chart.

  ```console
  helm repo update
  ```

- Create a new YAML file or update the existing one with changes such as a new image tag, environment variables, and other configuration details. Uncomment the lines by removing the # symbols and update the image tag as shown below. While upgrading, use the same YAML file that was used during installation.
  
  [boldbi/values.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/boldbi/values.yaml)

  ```console
     image:
       repo: us-docker.pkg.dev/boldbi-294612/boldbi
       # Overrides the image tag whose default is the chart appVersion.
       tag: 16.1.90
       pullPolicy: IfNotPresent
     imagePullSecrets: []
  ```

- Run the below command to apply changes in your Bold BI release or upgrading Bold BI to latest version.

  ```console
  helm upgrade [RELEASE_NAME] boldbi/boldbi -f [Crafted values.yaml file] -n [namespace-name]
  ```

  Ex:  `helm upgrade boldbi boldbi/boldbi -f my-values.yaml -n bold-services`

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

After this, retry the upgrade command shown above.

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME] -n [namespace-name]
```
Ex:  `helm uninstall boldbi -n bold-services`

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Application Startup

Configure the Bold BI On-Premise application startup to use the application. Please refer the following link for more details on configuring the application startup.
    
https://help.boldbi.com/embedded-bi/application-startup
