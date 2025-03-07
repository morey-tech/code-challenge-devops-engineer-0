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

Create an account on dockerhub. Log into dockerhub:
```
$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: moreytech
Password: 
WARNING! Your password will be stored unencrypted in /home/tecno/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

Add `image` field to containers in docker-compose and push to registy.
```
$ docker-compose push
```

Deployed both the app and ui via their helm charts. 
```
$ helm upgrade --install kanban-app kanban-app/
$ helm upgrade --install kanban-ui kanban-ui/
```

Getting a 403 when hitting the API through the App over a nodeport:
```
$ k logs -f pod/kanban-ui-694646fc69-nhn47
172.17.0.1 - - [20/Jul/2021:01:21:14 +0000] "POST /api/kanbans/ HTTP/1.1" 403 20 "http://192.168.49.2:30072/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36" "-"
```

Attempted to update three files that referenced `http://localhost:4200`
- kanban-app/src/main/java/com/wkrzywiec/medium/kanban/controller/KanbanController.java
- kanban-app/src/main/java/com/wkrzywiec/medium/kanban/controller/TaskController.java
- kanban-ui/e2e/protractor.conf.js
This didn't fix it for the minikube deployment. Tested redpeloying with `docker-compose` but now that is also showing 403 errors.
```
kanban-ui          | 172.19.0.1 - - [20/Jul/2021:12:16:26 +0000] "POST /api/kanbans/1/tasks/ HTTP/1.1" 403 20 "http://localhost:4200/kanbans/1" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36" "-"
```

Redeployed without the changes to the `http://localhost:4200` references and the post requests are creating the resource each time but sometimes failing with status code `499` (a.k.a canceled from client side, this is also indidcated in the chrome network log).
```
kanban-ui          | 172.19.0.1 - - [20/Jul/2021:12:24:36 +0000] "POST /api/kanbans/ HTTP/1.1" 201 51 "http://localhost:4200/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36" "-"

kanban-ui          | 172.19.0.1 - - [20/Jul/2021:12:22:56 +0000] "POST /api/kanbans/ HTTP/1.1" 499 0 "http://localhost:4200/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36" "-"
```

Submitting the request directly with `curl` works without issues. So it seems like this is a browser-side issue.
```
## Though the APP (so Nginx)
$ curl 'http://localhost:4200/api/kanbans/7/tasks/' \
  -H 'Content-Type: application/json' \
  --data-raw '{"title":"seasta","description":null,"color":"#7afcff","status":"TODO"}'
## Direct to API
$ curl 'http://localhost:8080/api/kanbans/7/tasks/' \
  -H 'Content-Type: application/json' \
  --data-raw '{"title":"seasta","description":null,"color":"#7afcff","status":"TODO"}'
```

Repployed into minikube with the helm charts and port forwarded the `kanban-ui` deployment. Still getting 403 from the browser but works over curl
```
$ export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=kanban-ui,app.kubernetes.io/instance=kanban-ui" -o jsonpath="{.items[0].metadata.name}")
$ export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
$ kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
$ curl -X POST http://127.0.0.1:8080/api/kanbans/ --data-raw '{"title":"test"}' -H 'Content-Type: application/json'
{"id":2,"title":"test","tasks":null}
```

Tested direct call to `http://kanban-app:8080/api/kanbans` from `kanban-ui` pod and it works fine. So it must be the UI blocking the request.
```
/ # nslookup kanban-app
nslookup: can't resolve '(null)': Name does not resolve

Name:      kanban-app
Address 1: 10.100.179.210 kanban-app.default.svc.cluster.local
/ # curl -X POST http://kanban-app:8080/api/kanbans/ --data-raw '{"title":"test-from-curl"}' -H 'Content-Type: application/json'
{"id":4,"title":"test-from-curl","tasks":null}
```

All of the GET requests to the /api endpoints are working fine.

Set up the CI workflow to use the `appVersion` from the app's chart for the image tag. Also including a tag with the short commit SHA for convince. In a more complete scenario I would implement automatic semantic versioning based on which step in the Gitflow branching method it is in.

Created an umbrella chart for the full application deployment `kanban/`.
```
$ helm dependency update kanban/
$ helm install kanban kanban/
```

Download `dive` to inspect image for ways to reduce size.
```
$ wget https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
$ sudo apt install ./dive_0.9.2_linux_amd64.deb
```

Started at `151MB`. Attempted but couldn't find a solution. Already using a build image. Already using alpine openjdk image. No caches to clean up from what I could find. No slimmer images available for openjdk 8. I am guessing there are Java dependencies I could remove in the pom.xml, not sure which though. After testing with `mvn dependency:analyze` it suggested some dependencies that were no longer needed but based on the src it seems like liquid base is still needed and the swagger functionality is still "needed".

Room for improvement:
- Use chart global values to reduce redundant value definitions.
- Use shared secret map for postgres and kanban-app.
- Automate image tags using branch names/git tags.
- Persistent storage for postgres.
- Improve notes printed on helm install.
- Use health check probes on deployments
- Make the `kanban-ui` reference to `kanban-app` in the Nginx config (`kanban-ui/default.conf`) dynamic based on the chart values.
- Add [network policies](https://kubernetes.io/blog/2016/04/kubernetes-network-policy-apis/) for deployments.