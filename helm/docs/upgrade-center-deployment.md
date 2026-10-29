# Enable Upgrade Center for Bold BI
This section explains how to enable the Upgrade Center for Bold BI deployed on Kubernetes.

## Overview

Upgrade Center enables administrators to check for available releases, initiate upgrades, and monitor upgrade progress directly from the Bold BI administration panel without manually updating Kubernetes resources.

> **Note:** Bold BI uses the shared Bold Upgrade Center application configured in `BoldBI` deployment mode. The Playwright validation image is resolved from the release information API and is not configured in the Helm values file.

> **Bold Common (Bold BI and Bold Reports together):** see the [Upgrade Center section of the Bold Common configuration guide](common-configuration.md#upgrade-center). Bold Common requires a PV for Standalone mode.

## Integration Mode Compatibility

`IdpIntegrated` mode is supported from Bold BI **16.3.5** onward. For a Bold BI 16.3.5 deployment, use the `16.3.5_upgrade_center` application image tag to enable this integration.

Customers running versions earlier than 16.3.5 must use `Standalone` mode to upgrade. Follow the Standalone Mode instructions below and open `/upgrade-center` directly; older versions may not provide the **Check for Upgrades** option.

## Standalone Mode

`IdpIntegrated` remains the default. Standalone mode reads the existing product configuration/private key directly from product storage and provides a local administrator login. Use an Upgrade Center image built with the latest Standalone support.

### Helm

Keep the existing product storage settings and enable Standalone mode:

```yaml
upgradeCenter:
  enabled: true
  integrationMode: Standalone
```

No additional Upgrade Center storage selector or duplicate connection settings are required. Helm passes the product's existing storage type, location, and credentials. The running application does not probe storage providers or read Helm values files.

| Existing product configuration | Upgrade Center access |
| --- | --- |
| Filesystem storage with a configured PV/PVC | Read-only mount of the existing product PVC. Internal file paths are managed by templates. |
| `s3Storage.enabled: true` | Existing S3 bucket, region, root folder, and credentials. |
| `azureStorage.enabled: true` | Existing Azure account/container, connection type, endpoint, and credentials. |
| `ociStorage.enabled: true` | Existing OCI bucket, namespace, region, root folder, and S3-compatible credentials. |

The existing `$hasRealPV` check identifies configured product storage, not whether a live PVC is bound or contains configuration files. When object storage and a PVC are both configured, Upgrade Center follows the product's selected object-storage backend; configuration files may not be stored on that PVC. A PVC can still be used for Upgrade Center's own reports/session keys.

Storage credentials are placed in a Kubernetes Secret, not a ConfigMap. Product configuration/key access remains read-only. Without a product PV, Upgrade Center also uses these credentials to persist its own reports and authentication keys under a separate prefix. Reused product credentials retain their existing permissions. Use HTTPS where available and restrict access to the required locations.

Supply administrator credentials through the existing `rootUserDetails` or `upgradeCenter.secret` settings. Standalone skips the IDP configuration init container. The application URL comes from `InternalAppUrls.Idp`; no separate URL is needed.

### kubectl

For filesystem storage, set `integrationMode: "Standalone"` in `bold-upgrade-center-config.data` in the standard manifest. Ensure its PVC references match the product claim (`bold-fileserver-claim` by default).

For existing non-PVC object-storage deployments, use the overlay from a repository checkout:

1. Configure the Upgrade Center image and administrator credentials in `deploy/bold-upgrade-center`.
2. Ensure the overlay's `envFrom` references match the storage Secrets already used by the product. It references `azure-blob-storage-secret`, `oci-storage-secret`, and `aws-s3-storage-secret` as optional references, following the non-PVC product manifest pattern. The configured Secret supplies `BOLD_SERVICES_STORAGETYPE` and its matching connection settings. The overlay does not create or replace these product Secrets.
3. Apply the overlay:

```sh
kubectl apply -k deploy/bold-upgrade-center-object-storage
```

The overlay removes the product-PVC configuration mount and IDP wait. Apply the required route manifest for your load balancer as described below. Do not apply the unmodified filesystem base separately over the object-storage overlay.

### State And Access

Without a product PVC, Upgrade Center stores its reports and authentication keys in the existing object storage. No dedicated Upgrade Center PV/PVC is created. This applies to both integration modes; IDP-integrated mode still uses IDP/UMS for configuration and login. Helm passes the existing product storage settings in either mode.

The isolated location is `app_data/upgrade-center/` beneath the existing product storage root. Allow read/list/write access there and delete access for `playwright-reports/` retention. The `data-protection-keys/` location is append-only; protect it from lifecycle expiry and use private storage with encryption at rest. Product configuration/private-key objects are never modified. A read-only credential cannot persist Upgrade Center's own data.

With a product PVC, existing filesystem report/key persistence is unchanged. Playwright still uses its separate temporary shared-state PVC; a working StorageClass is required for those jobs. Storage failures never fall back to temporary local persistence. Existing reports/keys from an older dedicated Upgrade Center data PVC are not migrated automatically: preserve them and plan migration before replacing that deployment. Do not delete existing claims as part of this update.

Object-storage Standalone also reads master database runtime settings for newer configuration. Access/decryption errors or conflicting master database settings stop loading rather than using stale settings. Filesystem Standalone retains its file-only behavior. Do not rotate configuration or keys during an operation.

Restart Upgrade Center after changing mounted configuration, credentials, or kubectl ConfigMaps. Open `https://<your-domain>/upgrade-center` and sign in with the configured administrator credentials. HTTPS is required for the login session. Product version/health APIs and Playwright still require application access. Set `integrationMode: IdpIntegrated` to restore IDP/UMS login.

## Sections

- [Integration Mode Compatibility](#integration-mode-compatibility)
- [Standalone Mode](#standalone-mode)
- [Deploy Upgrade Center using kubectl](#deploy-upgrade-center-using-kubectl)
- [Deploy Upgrade Center using Helm](#deploy-upgrade-center-using-helm)
- [Access the Upgrade Center from Bold BI](#access-the-upgrade-center-from-bold-bi)

## Deploy Upgrade Center using kubectl

> **Mode requirement:** Choose the mode based on the currently installed version, not the target upgrade version. IDP-integrated mode requires Bold BI 16.3.5 or later; version 16.3.5 requires the `16.3.5_upgrade_center` application image tag. Earlier versions must use Standalone mode.

### Step 1 - Download the Upgrade Center manifests

Download the following YAML files for Upgrade Center deployment:

| File | Description |
|------|-------------|
| [`bold-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/bold-upgrade-center.yaml) | ServiceAccount, RBAC Role/RoleBinding, Deployment, and Service for the Upgrade Center |
| [`bold-upgrade-center-playwright-secret.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/bold-upgrade-center-playwright-secret.yaml) | Secret containing the Bold BI admin credentials used by the Playwright automation runner |

Download the route manifest that matches the load balancer used by your Bold BI deployment:

| Load balancer | Route manifest |
|---------------|----------------|
| NGINX Ingress | [`nginx-ingress-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/nginx-ingress-upgrade-center.yaml) |
| AWS Application Load Balancer | [`alb-ingress-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/alb-ingress-upgrade-center.yaml) |
| Kong Ingress | [`kong-ingress-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/kong-ingress-upgrade-center.yaml) |
| Traefik | [`ingressroute-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/ingressroute-upgrade-center.yaml) |
| Azure Application Gateway for Containers | [`azure-alb-gateway-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/azure-alb-gateway-upgrade-center.yaml) |
| Istio | [`istio-upgrade-center.yaml`](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/deploy/bold-upgrade-center/istio-upgrade-center.yaml) |

### Step 2 - Configure admin credentials

> **RBAC scope:** The Upgrade Center RBAC is namespace-scoped. The manifest creates a `Role` and `RoleBinding` in the same namespace where Bold BI is deployed, and it does not require cluster-wide `ClusterRole` access. Apply the manifest in the Bold BI namespace so the Upgrade Center can manage only the Bold BI resources in that namespace.

Open `bold-upgrade-center-playwright-secret.yaml` and replace the placeholder values with your Bold BI administrator credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: bold-upgrade-center-playwright
type: Opaque
stringData:
  BOLD_ADMIN_USERNAME: "<your-admin-email>"
  BOLD_ADMIN_PASSWORD: "<your-admin-password>"
```

> **Note:** These credentials must match the administrator account configured during Bold BI's initial setup. The Playwright runner uses them to automate the upgrade workflow on your behalf.


### Step 3 - Configure the route manifest

Open the selected route manifest and update the hostname, gateway, TLS secret, or ALB group settings to match your Bold BI deployment.

For Traefik, update the host value:

```yaml
- kind: Rule
  match: Host(`<your-domain.com>`) && PathPrefix(`/upgrade-center`)
```

Replace `<your-domain.com>` with your actual application domain (e.g., `bi.example.com`).

If your deployment uses **HTTPS**, ensure the route manifest uses the same TLS secret as the existing Bold BI ingress configuration:

```yaml
tls:
  secretName: bold-tls   # Replace with your TLS secret name if different
```

> **Note:** Upgrade Center is optional for standalone Kubernetes deployments. If you deploy Upgrade Center, you must also apply the route manifest that matches the load balancer used in your environment.

### Step 4 - Apply the manifests

Run the following commands in the namespace where Bold BI is deployed (default: `bold-services`):

```sh
kubectl apply -f bold-upgrade-center-playwright-secret.yaml
```

```sh
kubectl apply -f bold-upgrade-center.yaml
```

```sh
kubectl apply -f <selected-upgrade-center-route-manifest>.yaml
```

### Step 5 - Verify the deployment

Confirm that the Upgrade Center pod is running:

```sh
kubectl get pods -n bold-services -l app.kubernetes.io/name=bold-upgrade-center
```

### Step 6 - Access the Upgrade Center

See [Access the Upgrade Center from Bold BI](#access-the-upgrade-center-from-bold-bi) below.


## Deploy Upgrade Center using Helm

> **Mode requirement:** Choose the mode based on the currently installed version, not the target upgrade version. IDP-integrated mode requires Bold BI 16.3.5 or later; version 16.3.5 requires the `16.3.5_upgrade_center` application image tag. Earlier versions must set `upgradeCenter.integrationMode: Standalone`.

#### Get Repo Info

1. Add the Bold BI helm repository

    ```console
    helm repo add boldbi https://boldbi.github.io/boldbi-server-in-kubernetes
    helm repo update
    ```

2. View charts in repo

    ```console
    helm search repo boldbi

    NAME            CHART VERSION   APP VERSION     DESCRIPTION
    boldbi/boldbi   16.2.5           16.2.5         Embed powerful analytics inside your apps and t...
    ```

#### Install Chart

You can either:

* Use a latest `values.yaml` file downloaded from the Bold BI repository for a fresh deployment.
* Use the existing `values.yaml` file from your current deployment and update it with the Upgrade Center configuration.

Download the appropriate `values.yaml` file based on your Kubernetes platform:

* For `GKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/gke-values.yaml).
* For `EKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/eks-values.yaml).
* For `AKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/aks-values.yaml).
* For `OKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldbi/boldbi-server-in-kubernetes/main/helm/custom-values/oke-values.yaml).
* For `ACK` please download the values.yaml file [here](https://github.com/boldbi/boldbi-server-in-kubernetes/blob/main/helm/custom-values/ack-values.yaml).


> **Note:** Upgrade Center can be enabled during the initial Bold BI deployment or added to an existing one. Simply set `upgradeCenter.enabled: true` in your values file before running `helm install` or `helm upgrade`.

> **StorageClass requirement:** Upgrade Center creates a temporary shared volume for validation state used by the Playwright validation jobs. The Kubernetes cluster must have a working default StorageClass and the matching CSI driver installed. If no default StorageClass is available, the validation pod can remain in `Pending` state while waiting for the shared volume.

### Step 1 - Enable Upgrade Center in values.yaml

> **RBAC scope:** The Helm chart deploys namespace-scoped RBAC for the Upgrade Center by using a `Role` and `RoleBinding` in the release namespace. It does not require cluster-wide `ClusterRole` access.

Open your cluster overlay file (for example, `helm/custom-values/aks-values.yaml`) and set `upgradeCenter.enabled` to `true`:

```yaml
upgradeCenter:
  enabled: true
```

### Step 2 - Configure admin credentials

The Upgrade Center uses administrator credentials to authenticate the Playwright runner during pre-upgrade validation.

> **Note:** If you have already configured `rootUserDetails.email` and `rootUserDetails.password` in your values file, those credentials are used automatically. Skip this step if that is the case.

If `rootUserDetails` is not set, provide the credentials explicitly under `upgradeCenter.secret`:

```yaml
upgradeCenter:
  enabled: true
  secret:
    adminUsername: "<your-admin-email>"
    adminPassword: "<your-admin-password>"
```

#### Environment variables reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `upgradeCenter.enabled` | Set to `true` to deploy and enable the Upgrade Center service. | `false` |
| `upgradeCenter.integrationMode` | `IdpIntegrated` or `Standalone`; independent of the selected product. | `IdpIntegrated` |
| `upgradeCenter.secret.adminUsername` | Bold BI administrator username. Used only when `rootUserDetails.email` is not provided. | `""` |
| `upgradeCenter.secret.adminPassword` | Bold BI administrator password. Used only when `rootUserDetails.password` is not provided. | `""` |
| `upgradeCenter.resources.requests.cpu` | CPU request for Upgrade Center pods. | `250m` |
| `upgradeCenter.resources.requests.memory` | Memory request for Upgrade Center pods. | `512Mi` |
| `upgradeCenter.resources.limits.cpu` | CPU limit for Upgrade Center pods. | `1` |
| `upgradeCenter.resources.limits.memory` | Memory limit for Upgrade Center pods. | `1536Mi` |



### Step 3 - Apply the Helm upgrade

Run the `helm upgrade` command with your updated values file. Replace the placeholder values with those matching your deployment:

```sh
helm upgrade --install boldbi boldbi/boldbi \
  --namespace bold-services \
  -f values.yaml
```

### Step 4 - Verify the deployment

Check that all Upgrade Center pods are running:

```sh
kubectl get pods -n bold-services -l app.kubernetes.io/name=bold-upgrade-center
```

You should see the pod in `Running` state:

```
NAME                                    READY   STATUS    RESTARTS   AGE
bold-upgrade-center-xxxxxxxxx-xxxxx   1/1     Running   0          1m
```

Verify the service is created:

```sh
kubectl get svc bold-upgrade-center -n bold-services
```

## Access the Upgrade Center from Bold BI

In Standalone Mode, open `/upgrade-center` directly and sign in on the Upgrade Center login page. On supported versions, you can also use **Check for Upgrades**. The steps below describe the IDP-integrated entry point.

Once all services are running and the ingress is active:

1. Open your browser and navigate to your Bold BI administration page:

   ```
   https://<your-domain>/ums/administration
   ```

2. In the top-right corner of the page, click the **question mark (?)** icon.

3. You will see an option — **Check for Upgrades**. Click it to open the Upgrade Center.

    ![Check-Updates](/docs/images/check-updates.png)

4. The Upgrade Center will display the currently installed version and any available upgrades. You can initiate an upgrade directly from this interface.

    ![Upgrade](/docs/images/upgrade.png)

    ![confirm-upgrade](/docs/images/start-upgrade.png)

## See also

- **[Upgrade Center User Guide](https://help.boldbi.com/deploying-bold-bi/upgrade-center/)** — Learn more about the Upgrade Center feature.
