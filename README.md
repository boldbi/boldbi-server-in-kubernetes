<!-- markdownlint-disable MD033 -->
<!-- markdownlint-disable MD041 -->
<a href="https://www.boldbi.com?utm_source=github&utm_medium=backlinks">
  <img
  src="https://cdn.boldbi.com/DevOps/boldbi-logo.svg"
  alt="boldbi"
  width="400"/>
</a>
</br></br>

[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/boldbi/boldbi-server-in-kubernetes?sort=semver)](https://github.com/boldbi/boldbi-server-in-kubernetes/releases/latest)
[![Documentation](https://img.shields.io/badge/docs-help.boldbi.com-blue.svg)](https://help.boldbi.com/embedded-bi?utm_source=github&utm_medium=backlinks)
[![File Issues](https://img.shields.io/badge/file_issues-boldbi_support-blue.svg)](https://www.boldbi.com/support?utm_source=github&utm_medium=backlinks)

# What is Bold BI

Bold BI is a powerful business intelligence dashboard software that helps you to get meaningful insights from your business data and make better decisions.

It is an end-to-end solution for creating, managing, and sharing interactive business dashboards that include a powerful dashboard designer for composing easily.

With deep embedding, you can interact more with your data and get insights directly from your application.

# Bold BI on Kubernetes

## Prerequisites

The following requirements are necessary to run the Bold BI solution.

* **Kubernetes Cluster: Kubernetes Version – 1.29+**
    * Amazon Elastic Kubernetes Service (EKS) | Google Kubernetes Engine (GKE) | Microsoft Azure Kubernetes Service (AKS) | Alibaba Cloud Kubernetes (ACK) | Oracle Kubernetes Engine (OKE) | On-Premises Cluster 

* **CLI:**
    * Kubectl (installation required)
    * AWS CLI | Azure CLI | Google Cloud CLI | Oracle CLI | Alibaba Cloud CLI

* **Load Balancer:** NLB(Nginx | Istio) | ALB
* **Package Manager:** Helm
* **Node Type & Configuration:**
    * OS – Ubuntu
    * Minimum Node Count – 2
    * Node Configuration – 2 Core and 8 GB 
    * Node Disk - 20 GB
* **File Storage:**
    * 10 GB or more for the Bold BI server storage in a read write many supported storages. 
    * AWS File Share | Azure File Share (NFS) | GCP File Store | Alibaba File System | Oracle File Storage

* **Web Browser:** Microsoft Edge | Mozilla Firefox | Chrome
* **Database:** PostgreSQL 13.0+ | Microsoft SQL Server 2016+ | MySQL 8.0+ | Oracle Database 19c+

## Quick Installation Guide for Bold BI

Use the following steps to quickly set up and deploy Bold BI.

### 1. Ingress Controller Setup

**Install NGINX Ingress Controller**

   Follow official docs: [NGINX Ingress Deploy](https://kubernetes.github.io/ingress-nginx/deploy/)

   Or install via Helm:

   ```bash
   helm repo add nginx-stable https://helm.nginx.com/stable

   helm repo update
   
   helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.13.1 --namespace ingress-nginx --create-namespace --set controller.service.externalTrafficPolicy=Local
   ```

  Refer to the Helm chart release details here: https://github.com/kubernetes/ingress-nginx

**Note**:

  * If you are using a domain name, make sure the Ingress Controller’s External IP is mapped to your DNS.

  * If you are accessing Bold BI via the IP address directly, no DNS mapping is required.

### 2. Add Bold BI Helm Repository

```bash
helm repo add boldbi https://boldbi.github.io/boldbi-kubernetes
helm repo update
helm search repo boldbi
```

Example output:

```
NAME            CHART VERSION   APP VERSION   DESCRIPTION
boldbi/boldbi   13.1.10         13.1.10       Embed powerful analytics inside your apps
```

### 3. Deploy Bold BI

#### Step 1: Create Namespace

```bash
kubectl create namespace [namespace-name]
```

#### Step 2: Install Bold BI

##### Standard Bold BI Installation Command

```bash
helm install [RELEASE_NAME] boldbi/boldbi -n [namespace-name] \
  --set appBaseUrl="https://<your-domain-or-ip>" \
  --set clusterProvider="<aks/eks/gke/oke/ack>" \
  [provider-specific-storage-settings]
````

> **Note:** Replace the placeholders based on your cloud provider. Refer to the provider-specific commands below.

##### Commands to Install Bold BI in Different Cloud Providers

**🔹 AKS**

```bash
helm install boldbi boldbi/boldbi -n bold-services \
  --set appBaseUrl="https://boldbi.example.com" \
  --set clusterProvider="aks" \
  --set persistentVolume.aks.nfs.fileShareName="premiumstorage1234/boldbi" \
  --set persistentVolume.aks.nfs.hostName="premiumstorage1234.file.core.windows.net"
```

*Replace `premiumstorage1234/boldbi` with your FileShareName share name and `premiumstorage1234.file.core.windows.net` with your storage account’s HostName.*

**🔹 EKS**

```bash
helm install boldbi boldbi/boldbi -n bold-services \
  --set appBaseUrl="https://boldbi.example.com" \
  --set clusterProvider="eks" \
  --set persistentVolume.eks.efsFileSystemId="fs-12345678"
```

*Replace `fs-12345678` with your actual EFS File System ID.*

**🔹 GKE**

```bash
helm install boldbi boldbi/boldbi -n bold-services \
  --set appBaseUrl="https://boldbi.example.com" \
  --set clusterProvider="gke" \
  --set persistentVolume.gke.fileShareName="boldbi-share" \
  --set persistentVolume.gke.fileShareIp="10.0.0.5"
```

*Replace `boldbi-share` with your Filestore share name and `10.0.0.5` with the Filestore IP address.*

**🔹 OKE**

```bash
helm install boldbi boldbi/boldbi -n bold-services \
  --set appBaseUrl="https://boldbi.example.com" \
  --set clusterProvider="oke" \
  --set persistentVolume.oke.volumeHandle="<FileSystemOCID>:<MountTargetIP>:<path>"
```

*Only one volume type is supported at a time. Use the format above for filesystem volumes.*

**🔹 ACK**

```bash
helm install boldbi boldbi/boldbi -n bold-services \
  --set appBaseUrl="https://boldbi.example.com" \
  --set clusterProvider="ack" \
  --set persistentVolume.ack.serverName="0123456a78-nas123.cn-hangzhou.nas.aliyuncs.com" \
  --set persistentVolume.ack.filePath="/bold-services"
```

*Replace `0123456a78-nas123.cn-hangzhou.nas.aliyuncs.com` with your ACK NAS mount target hostname. For filePath, you can specify your own path; the default value is /bold-services.*

The following table explains the key parameters used in the Helm install command for deploying Bold BI on different Kubernetes providers.

| Parameter                                | Description                                                                        |
| ---------------------------------------- | ---------------------------------------------------------------------------------- |
| `RELEASE_NAME`                           | The name you want to give to this Helm deployment.                                 |
| `appBaseUrl` | Base URL to access Bold BI. Can be a domain (HTTPS) or an external Ingress IP (HTTP). For example: `https://your-domain.com` or `http://<External-Ingress-IP>` |
| `clusterProvider`                        | The Kubernetes provider you are using.                                             |
| `persistentVolume.aks.nfs.fileShareName` | File Share name for AKS NFS storage.                                               |
| `persistentVolume.aks.nfs.hostName`      | Hostname of the AKS storage account.                                               |
| `persistentVolume.eks.efsFileSystemId`   | EFS File System ID for EKS storage.                                                |
| `persistentVolume.gke.fileShareName`     | Filestore share name for GKE storage.                                              |
| `persistentVolume.gke.fileShareIp`       | IP address of the GKE Filestore instance.                                          |
| `persistentVolume.oke.volumeHandle`      | Volume handle for OKE storage. Format: `<FileSystemOCID>:<MountTargetIP>:<path>`   |
| `persistentVolume.ack.serverName`    | Hostname of the NAS mount target for ACK storage. |
| `persistentVolume.ack.filePath`      | File path inside the NAS where Bold BI data will be stored. Default: `/bold-services`. |

### 4. SSL/TLS Configuration

If you have an SSL certificate for your domain, you can configure Bold BI with HTTPS:

* Set the `appBaseUrl` with `https://<your-domain>`

### Create TLS Secret

Run the following command with your certificate and key files:

```bash
kubectl create secret tls bold-tls -n [namespace-name] --key <key-path> --cert <certificate-path>
```

* The secret name **must** be `bold-tls`.
* Example:

```bash
kubectl create secret tls bold-tls -n bold-services --key tls.key --cert tls.crt
```

Now your Bold BI site is available at the IP address or domain name specified in your appBaseUrl.

## Advanced Deployment Options

For more advanced deployment scenarios using **Helm** and **kubectl**, refer to the following guides:

* [Deploy Bold BI using Kubectl](docs/index.md)
* Deploy using Helm
    1. [Deploy Bold BI using Helm](helm/README.md)
    2. [Common Deployment(BI and Reports) using Helm](helm/bold-common/README.md)
  
# License

[https://www.boldbi.com/terms-of-use#embedded](<https://www.boldbi.com/terms-of-use#embedded?utm_source=github&utm_medium=backlinks>)</br>

The images are provided for your convenience and may contain other software that is licensed differently (Linux system, Bash, etc. from the base distribution, along with any direct or indirect dependencies of the Bold BI platform).

These pre-built images are provided for convenience and include all optional and additional libraries by default. These libraries may be subject to different licenses than the Bold BI product.

If you want to install Bold BI from scratch and precisely control which optional libraries are installed, please download the stand-alone product from boldbi.com. If you have any questions, please contact the Bold BI team ([https://www.boldbi.com/support](<https://www.boldbi.com/support?utm_source=github&utm_medium=backlinks>)).

It is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

## FAQ

[How to auto deploy Bold BI in Kubernetes cluster?](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main/docs/bold-bi-auto-deployment.md)

[How to manually configure SSL using cert manager in Bold BI Kubernetes deployment?](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main//docs/FAQ/how-to-manually-configure-ssl-using-cert-manger-in-bold-bi-kubernetes-deployment.md)

[How to deploy Bold BI in EKS using Network Load Balancer (NLB) with SSL certificate from AWS Certificate Manager (ACM)?](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main//docs/FAQ/how-deploy-bold-bi-in-eks-using-network-load-balancer-with-ssl-certificate-from-acm.md)

[How to deploy Bold BI in Elastic Kubernetes Services (EKS) using Application Load Balancer (ALB)?](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main//docs/FAQ/how-to-deploy-bold-bi-in-eks-using-application-load-balancer.md)

[How to deploy Bold BI in Alibaba Cloud Kubernetes (ACK) Cluster?](docs/FAQ/how-to-deploy-bold-bi-in-an-ack-cluster.md)

[How to deploy Bold BI and Bold Reports in Alibaba Cloud Kubernetes (ACK) Cluster?](docs/FAQ/how-to-deploy-bold-bi-and-bold-reports-in-an-ack-cluster.md)

[How to upgrade Bold BI using kubectl?](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/Adding-upgrade-doc-in-faq/upgrade/upgrade.md)

[How to migrate the file share from Azure SMB Fileshare to NFS Fileshare?](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main/docs/FAQ/how-to-migrate-app_data-from-azure-smb-fileshare-to-nfs-fileshare.md)
