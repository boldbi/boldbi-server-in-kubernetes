# Enable Upgrade Center for Bold BI
This section explains how to enable the Upgrade Center for Bold BI deployed on Kubernetes.

## Overview

Upgrade Center enables administrators to check for available releases, initiate upgrades, and monitor upgrade progress directly from the Bold BI administration panel without manually updating Kubernetes resources.

> **Note:** Bold BI uses the shared Bold Upgrade Center application configured in `BoldBI` deployment mode. The Playwright validation image is resolved from the release information API and is not configured in the Helm values file.

## Sections

- [Deploy Upgrade Center using kubectl](#deploy-upgrade-center-using-kubectl)
- [Deploy Upgrade Center using Helm](#deploy-upgrade-center-using-helm)
- [Access the Upgrade Center from Bold BI](#access-the-upgrade-center-from-bold-bi)

## Deploy Upgrade Center using kubectl

> **Version requirement:** Upgrade Center is available starting with Bold BI version 16.3.5. For a Bold BI 16.3.5 deployment, use the `16.3.5_upgrade_center` tag for all Bold BI application images before deploying Upgrade Center with kubectl.

### Step 1 — Download the Upgrade Center manifests

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

### Step 2 — Configure admin credentials

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


### Step 3 — Configure the route manifest

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

### Step 4 — Apply the manifests

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

### Step 5 — Verify the deployment

Confirm that the Upgrade Center pod is running:

```sh
kubectl get pods -n bold-services -l app.kubernetes.io/name=bold-upgrade-center
```

### Step 6 — Access the Upgrade Center

See [Access the Upgrade Center from Bold BI](#access-the-upgrade-center-from-bold-bi) below.


## Deploy Upgrade Center using Helm

> **Version requirement:** Upgrade Center is available starting with Bold BI version 16.3.5. For a Bold BI 16.3.5 deployment, configure all Bold BI application images in your Helm values file to use the `16.3.5_upgrade_center` tag before enabling Upgrade Center.

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

### Step 1 — Enable Upgrade Center in values.yaml

> **RBAC scope:** The Helm chart deploys namespace-scoped RBAC for the Upgrade Center by using a `Role` and `RoleBinding` in the release namespace. It does not require cluster-wide `ClusterRole` access.

Open your cluster overlay file (for example, `helm/custom-values/aks-values.yaml`) and set `upgradeCenter.enabled` to `true`:

```yaml
upgradeCenter:
  enabled: true
```

### Step 2 — Configure admin credentials

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
