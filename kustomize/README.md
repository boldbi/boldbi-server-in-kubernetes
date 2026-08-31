# Kustomize Layout for Bold BI on Kubernetes

This folder lets you deploy Bold BI by applying **one** kustomization per
specific deployment scenario. No shell scripts, no Helm — pure Kustomize.

## Folder layout

```
kustomize/
├── base/                                       # core-resources.yaml (shared files)
├── optional/
│   ├── hpa/                                    # hpa.yaml        (additive)
│   └── hpa-gke/                                # hpa_gke.yaml    (additive)
├── file-storage/                               # cluster + ingress combos
│   ├── aks/
│   │   ├── aks-smb-traefik/
│   │   ├── aks-smb-kong/
│   │   ├── aks-smb-nginx/
│   │   ├── aks-nfs-traefik/
│   │   ├── aks-nfs-kong/
│   │   ├── aks-nfs-nginx/
│   │   └── aks-azure-alb/                      # Azure Application Gateway
│   ├── eks/
│   │   ├── eks-traefik/
│   │   ├── eks-kong/
│   │   ├── eks-nginx/
│   │   └── eks-alb/                            # AWS Application Load Balancer
│   ├── gke/
│   │   ├── gke-traefik/
│   │   ├── gke-kong/
│   │   └── gke-nginx/
│   └── oke/
│       ├── oke-traefik/
│       ├── oke-kong/
│       ├── oke-nginx/
│       ├── oke-block-traefik/
│       ├── oke-block-kong/
│       └── oke-block-nginx/
└── object-storage/                             # cluster-agnostic object storage combos
    ├── s3-traefik-console-and-file/
    ├── s3-traefik-console/
    ├── s3-traefik-file/
    ├── s3-kong-console-and-file/
    ├── s3-kong-console/
    ├── s3-kong-file/
    ├── s3-nginx-console-and-file/
    ├── s3-nginx-console/
    ├── s3-nginx-file/
    ├── azure-blob-traefik-console-and-file/
    ├── azure-blob-traefik-console/
    ├── azure-blob-traefik-file/
    ├── azure-blob-kong-console-and-file/
    ├── azure-blob-kong-console/
    ├── azure-blob-kong-file/
    ├── azure-blob-nginx-console-and-file/
    ├── azure-blob-nginx-console/
    ├── azure-blob-nginx-file/
    ├── oci-traefik-console-and-file/
    ├── oci-traefik-console/
    ├── oci-traefik-file/
    ├── oci-kong-console-and-file/
    ├── oci-kong-console/
    ├── oci-kong-file/
    ├── oci-nginx-console-and-file/
    ├── oci-nginx-console/
    └── oci-nginx-file/
```

## How to apply

Use `kubectl apply -k <path>` (no script, no values file).

```bash
# AKS, SMB file share, traefik ingress
kubectl apply -k kustomize/file-storage/aks/aks-smb-traefik

# AKS, NFS file share, Azure Application Gateway Ingress
kubectl apply -k kustomize/file-storage/aks/aks-azure-alb

# EKS with AWS Application Load Balancer
kubectl apply -k kustomize/file-storage/eks/eks-alb

# S3 object storage + traefik + console-and-file logs
kubectl apply -k kustomize/object-storage/s3-traefik-console-and-file

# OCI object storage + nginx ingress + file logs
kubectl apply -k kustomize/object-storage/oci-nginx-file
```

## Optional: enable HPA

Append the optional HPA folder as an additional line in the scenario's
`resources:` block:

```yaml
# filepath: kustomize/file-storage/gke/gke-nginx/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: bold-services

resources:
  - ../../../base
  - ../../../../deploy/pvclaim_gke.yaml
  - ../../../../deploy/deployment.yaml
  - ../../../../deploy/log4net_config.yaml
  - ../../../../deploy/ingress.yaml
  - ../../../optional/hpa-gke     # ← uncomment / append to enable
```

## Notes

- Every scenario references `../base`, which contains `core-resources.yaml`
  (namespace, version-config, branding, root-user, license-key, db-secret,
  bold-services-urls, service).
- File-storage scenarios add a `pvclaim_*.yaml` + `deployment.yaml` (with PV).
- Object-storage scenarios use `deployment_without_pv.yaml` (no PV) plus
  the storage secret and the log config the user picked.
- Choose Azure Application Gateway Ingress only with the `aks-azure-alb`
  folder — its `azure-alb-pre-config.yaml` must precede `azure-alb-gateway.yaml`.