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

## Deployment Methods

There are two ways to deploy Bold BI on the Kubernetes cluster. Please refer to the following documents for Bold BI deployment:

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
