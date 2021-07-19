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
  - Output from build:
    ```
    npm WARN deprecated core-js@2.6.12: core-js@<3.3 is no longer maintained and not recommended for usage due to the number of issues. Because of the V8 engine whims, feature detection in old core-js versions could cause a slowdown up to 100x even if nothing is polyfilled. Please, upgrade your dependencies to the actual version of core-js.
    ```
  - Latest `alpine` based `node` image is `node:16.5.0-alpine3.14`.
- [ ] Optimize the size of the backend `kanban-app` Docker image.


# Work Notes

Install the latest `docker-compose` and `docker`.
[docs docker-compose](https://docs.docker.com/compose/install/)
[docs docker](https://docs.docker.com/engine/install/ubuntu/)
```
$ sudo apt update
$ sudo apt install docker-ce docker-ce-cli containerd.io
$ sudo apt install docker-compose
$ docker version
Client: Docker Engine - Community
 Cloud integration: 1.0.17
 Version:           20.10.7
 API version:       1.41
 Go version:        go1.13.15
 Git commit:        f0df350
 Built:             Wed Jun  2 11:56:41 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true
```

Install latest `minikube` binary
[docs](https://minikube.sigs.k8s.io/docs/start/)
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
✨  Automatically selected the docker driver. Other choices: virtualbox, none, ssh
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.21.2 preload ...
    > preloaded-images-k8s-v11-v1...: 502.14 MiB / 502.14 MiB  100.00% 54.66 Mi
    > gcr.io/k8s-minikube/kicbase...: 361.08 MiB / 361.09 MiB  100.00% 28.61 Mi
🔥  Creating docker container (CPUs=2, Memory=8000MB) ...
🐳  Preparing Kubernetes v1.21.2 on Docker 20.10.7 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Test repo as is with docker-compose
```
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ docker-compose up
Creating kanban-postgres ... 
Creating kanban-postgres ... error

ERROR: for kanban-postgres  Cannot start service kanban-postgres: driver failed programming external connectivity on endpoint kanban-postgres (d8f847d83d631ae7a33cabb8a9c3b8b1c606da0aa6cc47097555f942e24b0e85): Error starting userland proxy: listen tcp4 0.0.0.0:5432: bind: address already in use

ERROR: for kanban-postgres  Cannot start service kanban-postgres: driver failed programming external connectivity on endpoint kanban-postgres (d8f847d83d631ae7a33cabb8a9c3b8b1c606da0aa6cc47097555f942e24b0e85): Error starting userland proxy: listen tcp4 0.0.0.0:5432: bind: address already in use
ERROR: Encountered errors while bringing up the project.
```

Apperently I already had postrgres running on my desktop.
```
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ sudo netstat -tupln | grep 5432
tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      1378/postgres       
tcp6       0      0 ::1:5432                :::*                    LISTEN      1378/postgres       
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ sudo systemctl status postgres
Unit postgres.service could not be found.
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ sudo ps aux | grep postgres
postgres    1378  0.0  0.0 229544 28624 ?        Ss   08:50   0:00 /usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/12/main -c config_file=/etc/postgresql/12/main/postgresql.conf
postgres    1398  0.0  0.0 229672  7844 ?        Ss   08:50   0:00 postgres: 12/main: checkpointer   
postgres    1399  0.0  0.0 229544  5932 ?        Ss   08:50   0:00 postgres: 12/main: background writer   
postgres    1400  0.0  0.0 229544 10116 ?        Ss   08:50   0:00 postgres: 12/main: walwriter   
postgres    1401  0.0  0.0 230080  8604 ?        Ss   08:50   0:00 postgres: 12/main: autovacuum launcher   
postgres    1402  0.0  0.0  83924  4984 ?        Ss   08:50   0:00 postgres: 12/main: stats collector   
postgres    1403  0.0  0.0 229976  6812 ?        Ss   08:50   0:00 postgres: 12/main: logical replication launcher   
tecno     164721  0.0  0.0  18800  2612 pts/2    S+   16:48   0:00 grep postgres
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ sudo kill 1378
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ sudo ps aux | grep postgres
tecno     164959  0.0  0.0  18800  2492 pts/2    S+   16:49   0:00 grep postgres
tecno@desktop-nick:~/VSCodeProjects/github/kanban-board-k8s-demo$ sudo netstat -tupln | grep 5432
```

After re-running `docker-compose up` the `kanban-app` failed with:
```
kanban-app         | org.postgresql.util.PSQLException: The connection attempt failed.
```

My guess is that it can't resolve the `kanban-postgres` alias. Per [this post](https://stackoverflow.com/a/40850537), I needed to restart `docker`.
```
$ sudo systemctl restart docker
$ docker-compose up
kanban-app         | 2021-07-19 21:05:11.358  INFO 1 --- [           main] c.w.medium.kanban.KanbanApplication      : Started KanbanApplication in 6.081 seconds (JVM running for 6.447)
```

Confirmed that I can access the web UI (`kanban-ui`) and create a new board (tests `kanban-app` and postgres). I did run into an issue with it on Firefox with the POST request failing with an `NS_BINDING_ABORTED` status under Transferred in the network tab. Works fine in Chrome though.

Install postgres using the Bitnami chart into minikube (later this will be a dependcy in the Umbrella chart).
```
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install kanban-postgres bitnami/postgresql -f example_env/postgres/values.yml 
$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
kanban-postgres default         1               2021-07-19 17:28:19.846363336 -0400 EDT deployed        postgresql-10.6.0       11.12.0   
$ k get pods
NAME                READY   STATUS    RESTARTS   AGE
kanban-postgres-0   1/1     Running   0          24s
$ k get svc
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kanban-postgres            ClusterIP   10.111.104.98   <none>        5432/TCP   28s
kanban-postgres-headless   ClusterIP   None            <none>        5432/TCP   28s
$ kubectl run kanban-postgres-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:12.7.0 --env="PGPASSWORD=kanban" --command -- psql --host kanban-postgres -U kanban -d kanban -p 5432
kanban=>
```

