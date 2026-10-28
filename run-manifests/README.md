# Sandbox deployment run manifests (normal mode, traefik, public repo, tag 17.1.30)

Copies of upstream manifests adapted for the single-node k0s sandbox:
- deployment.yaml: <application_base_url> replaced with https://8080-<sandbox-id>.e2b.app
- pvclaim_onpremise.yaml: hostPath pointed at /data/bold
- traefik.yaml: force-https-proto middleware (X-Forwarded-Proto: https) added to every route
- postgres.yaml: in-cluster postgres:16 Deployment + Service (PGDATA=/var/lib/postgresql/data/pgdata, hostPath /data/pg)

Secrets (bold-db-secret, bold-user-secret, bold-license-key, postgres-secret) were created
via kubectl from generated values and are NOT stored in git. Admin credentials stored only
in /home/user/bbk-run/.admin-creds (chmod 600) inside the sandbox.
