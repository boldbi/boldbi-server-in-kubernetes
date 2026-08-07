# Bold BI on Microsoft Oracle Kubernetes Engine.

1. Download the following files for Bold BI deployment in OKE:

    * [namespace.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/namespace.yaml)
    * [secrets.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/secrets.yaml)
    * [db-server-secret.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/db-server-secret.yaml)
    * [license-key-secret.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/license-key-secret.yaml)
    * [root-user-details.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/root-user-details.yaml)
    * [log4net_config.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/log4net_config.yaml)
    * [branding_config.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/branding_config.yaml)
    * [pvclaim_oke.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/pvclaim_oke.yaml)
    * [deployment.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/deployment.yaml)
    * [hpa.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/hpa.yaml)
    * [service.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/service.yaml)
    * [ingress.yaml](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/v16.2.5/deploy/ingress.yaml)

2. Create a Kubernetes cluster in Oracle Cloud Infrastructure Container Engine for Kubernetes (OKE) to deploy Bold BI by following the blow link.

   https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/oke-full/index.html#DefineClusterDetails

4. Create a File System volume by following the link below to store the Bold BI application data and note the File System OCID, Mount Target IP, and Export Path to store the shared folders for application usage.

    https://docs.oracle.com/en-us/iaas/compute-cloud-at-customer/topics/file/creating-a-file-system-mount-target-and-export.htm

    ![PV Claim](images/oke_filesystem.png)


6. Open **pvclaim_oke.yaml** file, downloaded in **Step 1**. Update the volumeHandle value to `<FileSystemOCID>:<MountTargetIP>:<path>`

    ![PV Claim](images/oke_pvclaim.png)

    Where:
    - `<FileSystemOCID>` is the OCID of the file system defined in the File Storage service.
    - `<MountTargetIP>` is the IP address assigned to the mount target.
    - `<path>` is the mount path to the file system relative to the mount target IP address, starting with a slash. For example: `ocid1.filesystem.oc1.iad.aaaa______j2xw:10.0.0.6:/FileSystem1`

6. Connect with your Oracle OKE  cluster.

7. After connecting with your cluster, deploy the latest Nginx ingress controller to your cluster using the following command.

```sh
kubectl apply -f https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/nignx-deploy.yaml
```

8. Navigate to the folder where the deployment files were downloaded from **Step 1**.

9. Run the following command to create the namespace for deploying Bold BI.

```sh
kubectl apply -f namespace.yaml
```

10. Run the following command to create the secrets.

```sh
kubectl apply -f secrets.yaml

kubectl apply -f license-key-secret.yaml

kubectl apply -f db-server-secret.yaml

kubectl apply -f root-user-details.yaml
```

11. Run the following command to create the configmap.

```sh
kubectl apply -f log4net_config.yaml

kubectl apply -f branding_config.yaml

kubectl apply -f bold-services-urls-config.yaml
```

12. If you have a DNS to map with the application, then you can continue with the following steps, else skip to **Step 17**. 

13. Open the **ingress.yaml** file. Uncomment the host value and replace your DNS hostname with `example.com` and save the file.

14. If you have the SSL certificate for your DNS and need to configure the site with your SSL certificate, follow the below step or you can skip to **Step 17**.

15. Run the following command to create a TLS secret with your SSL certificate.

```sh
kubectl create secret tls bold-tls -n bold-services --key <key-path> --cert <certificate-path>
```

16. Now, uncomment the `tls` section and replace your DNS hostname with `example.com` in ingress spec and save the file.

![ingress DNS](images/ingress_yaml.png)

17. Run the following command for applying the Bold BI ingress to get the IP address of Nginx ingress.

```sh
kubectl apply -f ingress.yaml
```

18. Now, run the following command to get the ingress IP address.

```sh
kubectl get ingress -n bold-services
```
Repeat the above command till you get the IP address in ADDRESS tab as shown in the following image.
![Ingress Address](images/ingress_address.png) 

19. Note the ingress IP address and map it with your DNS, if you have added the DNS in **ingress.yaml** file. If you do not have the DNS and want to use the application, then you can use the ingress IP address.

20. Open the **deployment.yaml** file from the downloaded files in **Step 1**. Replace your DNS or ingress IP address in `<application_base_url>` place.
    
    Ex:  `http://example.com`, `https://example.com`, `http://<ingress_ip_address>`

21. Read the optional client library license agreement from the following link.

    [Consent to deploy client libraries](../docs/consent-to-deploy-client-libraries.md)

22. By default all the client libraries will be installed for Bold BI in Kubernetes. Still you can still overwrite them by mentioning the required libraries as comma seperated like below in the environment variable noted from the above link.

<img src="images/deployment_yaml.png" alt="Image" style="display: block; margin: 0 auto" />

23. If you need to use **Bing Map** widget feature, enter value for `widget_bing_map_enable` environment variable as `true` and API key value for `widget_bing_map_api_key` in the **secrets.yaml** file downloaded in step 1.


24. Now, run the following commands one by one:

```sh
kubectl apply -f pvclaim_oke.yaml
```

```sh
kubectl apply -f deployment.yaml
```

```sh
kubectl apply -f hpa.yaml
```

```sh
kubectl apply -f service.yaml
```

25. Wait for some time till the Bold BI On-Premise application deployed to your Oracle OKE  cluster.

26. Use the following command to get the pods status.

```sh
kubectl get pods -n bold-services
```
![Pod status](images/pod_status.png) 

27. Wait till you see the applications in running state. Then use your DNS or ingress IP address you got from **Step 18** to access the application in the browser.

28.	Configure the Bold BI On-Premise application startup to use the application. Please refer the following link for more details on configuring the application startup.
    
    https://help.boldbi.com/embedded-bi/application-startup
