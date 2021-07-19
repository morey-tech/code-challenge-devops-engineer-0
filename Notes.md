# Tasks:
- [ ] Build Docker Images in Github Actions
- [ ] Push Docker Images to Dockerhub in Github Actions
- [ ] Create Helm chart for `kanban-app`
- [ ] Create Helm chart for `kanban-ui`
- [ ] Create example values in the `/example_env` folder.
- [ ] Review options to improve security of the Kubernetes Deployments.
  - [ ] Dedicated service accounts for each workload?
## Bonus Tasks
- [ ] Create Umbrella chart for full application/repo.
- [ ] Include an example/option in the Helm charts to create Ingress resource to expose the deployment.
- [ ] Add option to include existing secrets or secrets from Github Secrets with the Helm charts.
- [ ] Upgrade the base container used for the `kanban-ui` Docker image.
- [ ] Optimize the size of the backend `kanban-app` Docker image.


# Work Notes
Install latest `minikube` binary [docs](https://minikube.sigs.k8s.io/docs/start/)
```
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
## Use `which` to locate existing minikube binary to replace.
$ sudo install minikube-linux-amd64 $(which minikube)
$ minikube version
minikube version: v1.22.0
commit: a03fbcf166e6f74ef224d4a63be4277d017bb62e
$ rm minikube-linux-amd64
```

Start minikube
```
$ minikube start
😄  minikube v1.22.0 on Debian bullseye/sid
🆕  Kubernetes 1.21.2 is now available. If you would like to upgrade, specify: --kubernetes-version=v1.21.2
✨  Using the docker driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.20.2 preload ...
    > gcr.io/k8s-minikube/kicbase...: 321.25 MiB / 321.26 MiB  100.00% 20.14 Mi
    > preloaded-images-k8s-v11-v1...: 491.55 MiB / 491.55 MiB  100.00% 24.85 Mi
🤷  docker "minikube" container is missing, will recreate.
🔥  Creating docker container (CPUs=2, Memory=3900MB) ...
🐳  Preparing Kubernetes v1.20.2 on Docker 20.10.2 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image kubernetesui/metrics-scraper:v1.0.4
    ▪ Using image kubernetesui/dashboard:v2.1.0
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass, dashboard
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
