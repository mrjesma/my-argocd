# my-argocd
This is my argocd repo for deployment tests using kind as local k8s server and terraform to deploy argocd.

## Setup K8s
```sh
sudo kind create cluster
sudo kind get clusters
sudo kind get kubeconfig > ${HOME}/.kube/config
kubectl cluster-info --context kind-kind
```

## Deploy argocd
```sh
cd terraform
terraform init
terraform apply
```

## Access argocd
Check if all pods are running
```sh
kubectl get pods -n argocd
```

Forward http port
```sh
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

Get argocd initial admin password
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Deploy apps via argocd
Argocd application manifests are located in `argocd-applications` folder.

* `'1-application.yaml` Simple application
* `'2-application.yaml` App of apps strategy, where 1 argocd manifest deploy other 2 argocd manifest which deploy its apps.
* `'3-application.yaml` Deploy app with Kustomise
* `'4-application.yaml` Deploy app with Helm
* `'5-application.yaml` Deploy app with Kustomise and image version tag updated automatically with argo-image-updater
* `'6-application.yaml` Deploy app with Kustomise and image version tag updated automatically with argo-image-updater using git write-back method

To deploy/delete app in argocd run
```sh
kubectl apply -f argocd-applications/X-application.yaml
kubectl delete -f argocd-applications/X-application.yaml
```

## Utils
### Push images to docker hub
```sh
docker logon -u airtonorlandini
docker pull nginx:latest
docker tag nginx:latest airtonorlandini/nginx:v1.0.0
docker push airtonorlandini/nginx:v1.0.0
```

### Create helm app
Enable 'GitHub Pages' at my repo settings in GitHub.
```sh
helm create my-app-helm
cd my-app-helm
helm pacakge .
helm repo index . 
mkdir packages
mv *.tgz packages
```
Edit Chart.yaml version tag to generate new versions. 

### Argocd cli
Download and install argocd cli
```sh
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

Login argocd
```sh
argocd login localhost:8080 \
  --insecure \
  --username admin \
  --password $(kubectl get secret \
  -n argocd \
  argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" |
  base64 -d)
```

Download and install argocd-image-updater cli
```sh
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj-labs/argocd-image-updater/releases/download/v$VERSION/argocd-image-updater-linux_amd64 
sudo install -m 555 argocd-image-updater-linux_amd64 /usr/local/bin/argocd-image-updater
rm argocd-image-updater-linux_amd64
```

Check argocd-image-updater log
```sh
kubectl logs -f -l app.kubernetes.io/instance=argocd-image-updater -n argocd
```
