# Deploying Bold BI in Alibaba Cloud Kubernetes (ACK) Cluster
This section provides instructions on how to deploy Bold BI in an Alibaba Cloud Kubernetes (ACK) cluster. Please follow the documentation below to successfully deploy these applications.

# Deployment Methods

There are two ways to deploy Bold BI on the Kubernetes cluster. Please refer to the following documents for Bold BI deployment:

* [Deploy Bold BI using Kubectl](#deploy-bold-bi-using-kubectl)
* [Deploy Bold BI using Helm](#deploy-bold-bi-using-helm)

Please click on the respective links to access the detailed documentation for each deployment method.

# Deploy Bold BI using Kubectl

The following steps will guide you through the process of deploying Bold BI using Kubectl in an Alibaba Cloud Kubernetes (ACK) cluster.

## Deployment prerequisites

The following requirements are necessary to deploy the Bold BI solution using Kubectl:

* [Install Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl): Make sure you install kubectl on your local machine to facilitate the deployment process.
* [NAS File System](../pre-requisites.md#ack-file-sotrage): Set up a NAS file system to store the required data for Bold BI.
* [Create and connect a ACK cluster](../pre-requisites.md#ack-cluster): Create and connect an ACK cluster in Alibaba Cloud that will host the Bold BI deployment.
* Load Balancing- [Nginx](https://kubernetes.github.io/ingress-nginx/deploy/) : By default, an Alibaba Cloud Kubernetes (ACK) cluster has Nginx already installed in the kube-system namespace, so there is no need to install it manually. The Nginx Ingress Controller is available and can be utilized to enable load balancing for your Bold BI deployment.

Please ensure that you have fulfilled these prerequisites before proceeding with the deployment.

## Steps for Bold BI auto deployment using kubectl.

1. Download the deployment file from [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/deploy/ack_deploy.yaml) to deploy Bold BI on AKS.

2. Navigate to the folder where the deployment files were downloaded in **Step 1**.

3. Follow the documentation provided at [this link](https://www.alibabacloud.com/help/en/nas/latest/create-a-nas-file-system) to create a `file system` in Alibaba Cloud.

4. Once the file system is created, locate and click on the cube icon. This will allow you to view the mount target hostname. Take note of the mount target hostname, as you will need it for mounting the file system with our application.

   ![NAS-Mount-Target](images/Nas-mount-target.png)

5. Open the **ack_deploy.yaml** file and replace the `<host_name_of_mount_target>` placeholder with the actual mount target hostname noted in the previous step.

    ![PV Claim](images/ack_pv_claim.png)

6. If you have a DNS to map with the application, proceed to the next steps, otherwise, skip to **Step 10**. 

7. In the ack_deploy.yaml file and locate line 2335. Uncomment the host value and replace example.com with your DNS hostname.

      ![DNS](images/ack_ingress_http_yaml.png)
  
8. If you have an SSL certificate for your DNS and need to configure the site, follow next step; otherwise, skip to **Step 10**.

9. In the ingress spec of the ack_deploy.yaml file, uncomment the tls section. Replace example.com with your DNS hostname and save the file.

      ![ingress DNS](images/ack_ingress_tls_yaml.png)

10. After connecting with your cluster, run the following command to retrieve the External IP address:

      ```sh
      kubectl get svc -n kube-system
      ```
      Repeat the above command until you find the IP address listed in the EXTERNAL-IP column, as shown in the following image:

      ![Ingress Address](images/ack_ingress_address.png)

11. Note the EXTERNAL-IP address and map it to your DNS if you have added it in the ack_deploy.yaml file. If you do not have a DNS, use the EXTERNAL-IP address to access the application.

12. Replace `<application_base_url>` with your DNS or EXTERNAL-IP address.

    Examples: `http://example.com`, `https://example.com`, `http://<external_ip_address>`
    
    ![App_Base_Url](images/ack_app_base_url.png) 
    
13. Read the optional client library license agreement from the following link.

    [Consent to deploy client libraries](../docs/consent-to-deploy-client-libraries.md)
    
14. By default, all client libraries for Bold BI will be installed in Kubernetes. However, you can overwrite them by specifying the required libraries as a comma-separated list in the environment variable noted from the above link.

    ![Optinal_Lib](images/ack_optional_lib.png) 

15. Deploy Bold BI in your Kubernetes cluster by running the following command:

    ```sh
    kubectl apply -f ack_deploy.yaml
    ```

16. Create a TLS secret with your SSL certificate using the following command:

    ```sh
    kubectl create secret tls bold-tls -n bold-services --key <key-path> --cert <certificate-path>
    ```

17. Check the status of the pods by running the following command:

     ```sh
    kubectl get pods -n bold-services
     ```
    ![Pod status](images/ack_bi_pod_status.png) 

18. Wait until you see the applications in the running state. Then, use your DNS or EXTERNAL-IP address obtained from the following command to access the application in the browser.

    ```sh
    kubectl get ingress -n bold-services
     ``` 

19. For more details on configuring the application startup, please refer to the [this](#application-startup).


# Deploy Bold BI using Helm

The following steps will guide you through the process of deploying Bold BI using Helm in an Alibaba Cloud Kubernetes (ACK) cluster.

## Deployment prerequisites

* [Install Helm](https://helm.sh/docs/intro/install/): Make sure you have Helm installed on your local machine to facilitate the deployment process.
* [NAS File System](../pre-requisites.md#ack-file-sotrage): Set up a NAS file system to store the required data for Bold BI.
* [Create and connect a ACK cluster](../pre-requisites.md#ack-cluster): Create and connect an ACK cluster in Alibaba Cloud that will host the Bold BI deployment.
* Load Balancing- [Nginx](https://kubernetes.github.io/ingress-nginx/deploy/) : By default, an Alibaba Cloud Kubernetes (ACK) cluster has Nginx already installed in the kube-system namespace, so there is no need to manually install it. The Nginx Ingress Controller is available and can be utilized to enable load balancing for your Bold BI deployment.

**Note:** Obtain the **Nginx External IP** address by running `kubectl get svc -n kube-system` and map it with a DNS in order to craft the values.yaml file when installing Bold BI using the Helm chart.

## Get Repo Info

1. Add the Bold BI helm repository.

```console
helm repo add boldbi https://boldbi.github.io/boldbi-server-in-kubernetes
helm repo update
```

2. View charts in repo.

```console
helm search repo boldbi

NAME            CHART VERSION   APP VERSION     DESCRIPTION
boldbi/boldbi   16.2.5           16.2.5         Embed powerful analytics inside your apps and t...
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Create Namespace

Run the following command to create the namespace where the Bold BI resources will be deployed in the Kubernetes cluster. The default namespace is <i>bold-services</i>.

```console
kubectl create ns bold-services
```

## Install Chart

For the Helm chart, you need to craft a `values.yaml` file. So download the values.yaml file from [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/common-ack-values.yaml) and make required changes based on your cluster provider.

The following table allows you to craft the `values.yaml` file with required values for Bold BI deployment. So please read the description carefully and enter the values in values.yaml file.

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
       The namespace in which the Bold BI resources will be deployed in the Kubernetes cluster.<br/>
       The default namespace is <i>bold-services</i>
      </td>
    </tr>
    <tr>
      <td>
       appBaseUrl *
      </td>
      <td>
       Domain with http/https protocol.
       <br/>
       Ex: `http://example.com`, `https://example.com`
       <br/>
       Follow the <a href='../configuration.md#ssl-configuration'>SSL Configuration</a> to configure SSL certificate for https protocol.
      </td>
    </tr>
    <tr>
      <td>
       optionalLibs
      </td>
      <td>
       These are the client libraries used in Bold BI by default.<br/>
       '<i>mongodb,mysql,influxdb,snowflake,oracle,google,clickhouse</i>'<br/>
       Please refer to <a href='../configuration.md#client-libraries'>Optional Client Libraries</a> section to know more.
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using.<br/>
       The supported values are '<i>gke,eks,ack and aks,</i>'
       Please refer to <a href='../configuration.md#cluster-provider'>Cluster Provider</a> section to know more.
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume*
      </td>
      <td>
       This is a file storage information to store the shared folders for application usage.
       Please refer to <a href='../configuration.md#persistent-volume'>this</a> section to know more on how to set Persistant Volumes for Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       loadBalancer
      </td>
      <td>
       Currently we have provided support for Nginx and Istio as Load Balancers in Bold BI. Please refer to <a href='../configuration.md#load-balancing'>this</a> section for configuring Load balancer for Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling
      </td>
      <td>
       By default autoscaling is enabled in Bold BI. Please refer to <a href='../configuration.md#auto-scaling'>this</a> section to know more.
      </td>
    </tr>
    <tr>
      <td>
       bingMapWidget
      </td>
      <td>
       Please refer to <a href='../configuration.md#bing-map-widget'>this</a> section to configure Bing Map Widget in Bold BI.
      </td>
    </tr>
    <tr>
      <td>
       customLocalePath
      </td>
      <td>
       Custom locale file path for Localization.
       Please refer to <a href='../configuration.md#custom-locale-path'>this</a> section to configure Custom Locale Path in Bold BI.
      </td>
    </tr>
    </table>
<br/>

> **Note:** Items marked with `*` are mandatory fields in values.yaml.

Run the following command to delpoy Bold BI in your cluster.

```console
helm install [RELEASE_NAME] boldbi/boldbi -f [Crafted values.yaml file]
```
Ex:  `helm install boldbi boldbi/boldbi -f my-values.yaml`

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Access application
1. Check the status of the pods by running the following command:

     ```sh
    kubectl get pods -n bold-services
     ```
    ![Pod status](images/ack_bi_pod_status.png) 

2. Wait until you see the applications in the running state. Then, use your DNS or EXTERNAL-IP address obtained from the following command to access the application in the browser.

    ```sh
    kubectl get ingress -n bold-services
     ``` 

3. For more details on configuring the application startup, please refer to the [this](#application-startup)


## Upgrade

Run the following command to get the latest version of the Bold BI helm chart.

```console
helm repo update
```

Run the following command to apply changes in your Bold BI release or upgrade Bold BI to the latest version.

```console
helm upgrade [RELEASE_NAME] boldbi/boldbi -f [Crafted values.yaml file]
```

Ex:  `helm upgrade boldbi boldbi/boldbi -f my-values.yaml`

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```
Ex:  `helm uninstall boldbi`

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._


## Application Startup

Configure the Bold BI On-Premise application startup to use the application. Please refer the following link for more details on configuring the application startup.
    
https://help.boldbi.com/embedded-bi/application-startup


