# Tasks:
- [x] Build Docker Images in Github Actions
- [x] Push Docker Images to Dockerhub in Github Actions
- [x] Create Helm chart for `kanban-app`
- [x] Create Helm chart for `kanban-ui`
- [x] Create example values in the `/example_env` folder.
- [ ] Review options to improve security of the Kubernetes Deployments.
  - [x] Dedicated service accounts for each workload?
- [x] Depoy postgres with Helm to minikube
- [x] Manually push docker images to dockerhub to allow chart testing.
## Bonus Tasks
- [x] Create Umbrella chart for full application/repo.
  - [x] Add postgres as a depdency.
- [x] Include an example/option in the Helm charts to create Ingress resource to expose the deployment.
- [x] Add option to include existing secrets or secrets from Github Secrets with the Helm charts.
- [x] Upgrade the base container used for the `kanban-ui` Docker image.
  - Output from build:
    ```
    npm WARN deprecated core-js@2.6.12: core-js@<3.3 is no longer maintained and not recommended for usage due to the number of issues. Because of the V8 engine whims, feature detection in old core-js versions could cause a slowdown up to 100x even if nothing is polyfilled. Please, upgrade your dependencies to the actual version of core-js.
    ```
  - Latest `alpine` based `node` image is `node:16.5.0-alpine3.14`.
- [ ] Optimize the size of the backend `kanban-app` Docker image.
  - Attempted but couldn't find a solution. Already using a build image. Already using alpine openjdk image. No caches to clean up from what I could find. No slimmer images available for openjdk 8. I am guessing there are Java dependencies I could remove in the pom.xml, not sure which though.
  - After testing with `mvn dependency:analyze` it suggested some dependencies that were no longer needed but based on the src it seems like liquid base is still needed and the swagger functionality is still "needed".
