# Kanban Docker Pipeline

The `ci` workflow will run on any top level branch (e.g. `develop` or `master` but not `feature/task` or `release/0.1.0`, this could be expanded using the `on.push.branches` value). The steps are as follows:
1. Checkout the current commit.
2. Generate variables with the versions of the apps based on the `appVersion`s in their `Chart.yaml`. These will be used as one of the tags for the Docker images.
3. Set up the runner with Docker build components.
4. Build the Docker images for each app and push to Dockerhub using credentials from Github secrets. 
   1. Tag with latest, the app's current version from it's Helm chart, and the beginning of the commit SHA.
 