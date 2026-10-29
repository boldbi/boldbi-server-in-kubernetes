# Renders every custom-values file x Upgrade Center mode x storage and validates references. Usage: python3 helm/tests/upgrade-center-matrix.py (needs helm, PyYAML)
import subprocess, yaml, itertools, sys, os, json
H=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..')
PV={ 'aks':{'persistentVolume.aks.fileShareName':'share','persistentVolume.aks.azureStorageAccountName':'YQ==','persistentVolume.aks.azureStorageAccountKey':'YQ=='},
 'eks':{'persistentVolume.eks.efsFileSystemId':'fs-1','persistentVolume.eks.efsAccessPointId':'fsap-1'},
 'gke':{'persistentVolume.gke.fileShareIp':'10.0.0.2','persistentVolume.gke.fileShareName':'share'},
 'ack':{'persistentVolume.ack.serverName':'nas.example','persistentVolume.ack.filePath':'/bold'},
 'oke':{'persistentVolume.oke.volumeHandle':'ocid:1.1.1.1:/p'}}
NOPV={ 'oke':{'persistentVolume.oke.volumeHandle':''}}
OBJA={'azureStorage.enabled':'true','azureStorage.accessKey':'k','azureStorage.accountName':'acc','azureStorage.containerName':'c','azureStorage.connectionType':'default','azureStorage.storageUri':'https://x'}
OBJO={'ociStorage.enabled':'true','ociStorage.accessKey':'k','ociStorage.secretKey':'s','ociStorage.bucketName':'b','ociStorage.namespace':'n','ociStorage.region':'r','ociStorage.rootFolderName':'r'}
OBJ={'s3Storage.enabled':'true','s3Storage.accessKey':'AK','s3Storage.secretKey':'SK','s3Storage.bucketName':'b','s3Storage.region':'us-east-1','s3Storage.rootFolderName':'r'}
FILES=[('boldbi','aks-values.yaml','aks'),('boldbi','eks-values.yaml','eks'),('boldbi','eks-alb-values.yaml','eks'),('boldbi','gke-values.yaml','gke'),('boldbi','ack-values.yaml','ack'),('boldbi','oke-values.yaml','oke'),
 ('bold-common','common-aks-values.yaml','aks'),('bold-common','common-eks-values.yaml','eks'),('bold-common','common-gke-values.yaml','gke'),('bold-common','common-ack-values.yaml','ack'),('bold-common','common-oke-values.yaml','oke')]
res=[]
for chart,vf,prov in FILES:
  for mode,pv in itertools.product(['IdpIntegrated','Standalone'],['pv','nopv','nopv-azure','nopv-oci'] if chart=='boldbi' else ['pv','nopv']):
    sets={'upgradeCenter.enabled':'true','upgradeCenter.integrationMode':mode,'appBaseUrl':'https://bold.example.com','upgradeCenter.secret.adminUsername':'a@b.com','upgradeCenter.secret.adminPassword':'Pass@123'}
    if pv=='pv': sets.update(PV[prov])
    else: sets.update(NOPV.get(prov,{})); sets.update({'nopv':OBJ,'nopv-azure':OBJA,'nopv-oci':OBJO}[pv])
    cmd=['helm','template','t',f'{H}/{chart}','-f',f'{H}/custom-values/{vf}']+[x for k,v in sets.items() for x in ('--set',f'{k}={v}')]
    r=subprocess.run(cmd,capture_output=True,text=True)
    tag=f'{chart:11} {vf:22} {mode:13} {pv:10}'
    if r.returncode: res.append((tag,'RENDER FAIL',r.stderr.strip()[:200])); continue
    try: docs=[d for d in yaml.safe_load_all(r.stdout) if d]
    except Exception as e: res.append((tag,'YAML FAIL',str(e)[:200])); continue
    errs=[]
    by={(d['kind'],d['metadata']['name']):d for d in docs}
    uc=by.get(('Deployment','bold-upgrade-center'))
    if not uc: res.append((tag,'NO UC DEPLOY','')); continue
    spec=uc['spec']['template']['spec']
    cms=by.get(('ConfigMap','bold-upgrade-center-config'))
    if not cms: errs.append('no configmap')
    pvcs={n for k,n in by if k=='PersistentVolumeClaim'}
    secrets={n for k,n in by if k=='Secret'}
    for v in spec.get('volumes',[]):
      c=v.get('persistentVolumeClaim')
      if c and c['claimName'] not in pvcs: errs.append('missing PVC '+c['claimName'])
      s=v.get('secret')
      if s and s['secretName'] not in secrets and not s.get('optional'): errs.append('missing secret '+s['secretName'])
    vols={v['name'] for v in spec.get('volumes',[])}
    for c in spec.get('containers',[])+spec.get('initContainers',[]):
      for m in c.get('volumeMounts',[]):
        if m['name'] not in vols: errs.append('mount without volume '+m['name'])
      for e in c.get('env',[]):
        ref=(e.get('valueFrom') or {}).get('configMapKeyRef')
        if ref and cms and ref['key'] not in cms.get('data',{}) : errs.append('cm key '+ref['key'])
        ref=(e.get('valueFrom') or {}).get('secretKeyRef')
        if ref and ref['name'] not in secrets and not ref.get('optional'): errs.append('secret '+ref['name']+'/'+ref['key'])
      for ef in c.get('envFrom',[]):
        r_=ef.get('secretRef')
        if r_ and r_['name'] not in secrets and not r_.get('optional'): errs.append('envFrom secret '+r_['name'])
    cmn={n for k,n in by if k=='ConfigMap'}
    for d in docs:
      if d['kind']!='Deployment': continue
      ps=d['spec']['template']['spec']
      for v in ps.get('volumes',[]):
        if v.get('persistentVolumeClaim') and v['persistentVolumeClaim']['claimName'] not in pvcs: errs.append(d['metadata']['name']+' missing PVC '+v['persistentVolumeClaim']['claimName'])
        if v.get('configMap') and v['configMap']['name'] not in cmn and not v['configMap'].get('optional'): errs.append(d['metadata']['name']+' missing cm '+v['configMap']['name'])
      for c in ps['containers']:
        for ef in c.get('envFrom',[]):
          r_=ef.get('secretRef') or {}
          if r_ and r_['name'] not in secrets and not r_.get('optional'): errs.append(d['metadata']['name']+' missing secret '+r_['name'])
        for e in c.get('env',[]):
          r_=(e.get('valueFrom') or {}).get('secretKeyRef')
          if r_ and r_['name'] not in secrets and not r_.get('optional'): errs.append(d['metadata']['name']+' missing secret '+r_['name'])
    sa=spec.get('serviceAccountName')
    if ('ServiceAccount',sa) not in by: errs.append('no SA')
    inits=[c['name'] for c in spec.get('initContainers',[])]
    ucv=[v['name'] for v in spec.get('volumes',[])]
    env={e['name']:e.get('value') for c in spec['containers'] for e in c.get('env',[])}
    res.append((tag,'OK' if not errs else 'ISSUE',(';'.join(sorted(set(errs)))+' | ' if errs else '')+f"init={inits} vols={ucv} stype={env.get('BOLD_SERVICES_STORAGETYPE')} pvused={env.get('BOLD_SERVICES_PV_USED')} mode={env.get('UpgradeCenter__IntegrationMode')}"))
for r in res: print(*r,sep=' | ')
print(sum(r[1]=='OK' for r in res),'/',len(res))
