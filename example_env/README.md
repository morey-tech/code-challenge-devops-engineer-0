# Kanban Examples

## Helm Umbrella Chart
The whole application can be deployed with the Helm umbrella chart `kanban` which has the individual charts (`kanban-ui`, `kanban-ui`, `bitnami/postgresql`) as dependencies. For example, from the project root (and assuming your kubectl context is already set):
```
$ helm upgrade --install kanban kanban/

$ helm list
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
kanban  default         1               2021-07-21 11:41:01.566920955 -0400 EDT deployed        kanban-0.1.1    0.1.1
```
Or use the deploy script that will update the chart dependcies, do a dry-run, then install with automatic backout (using the `--atomic` flag).
```
$ ./example_env/deploy-kanban.sh
```

All of the required values are included in the defaults of the umbrella chart. Obviously this isn't ideal for secrets, so the chart supports include pre-existing secret maps by name (using the `secretMaps` list values) or including secret map data using `--set` flag which is useful for including values from Github Secrets in an Actions workflow. For example:
```
$ helm upgrade --install kanban kanban/ \
  --set postgresql.postgresqlPassword="${{ secrets.POSTGRES_PASSWORD }}" \
  --set app.secretMapData="${{ secrets.POSTGRES_PASSWORD }}"
```

## Individual Helm Charts
Each component of the complete appliction has it's own Helm chart to allow it to be deployed, scaled, maintained separately. To deploy the charts separately run the following from the project root:
```
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install kanban-postgres bitnami/postgresql -f example_env/values/postgresql.yml
$ helm install kanban-app kanban-app/ -f example_env/values/kanban-app.yml
$ helm install kanban-ui kanban-ui/ -f example_env/values/kanban-ui.yml

$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                  APP VERSION
kanban-app      default         1               2021-07-21 11:37:45.804129927 -0400 EDT deployed        kanban-app-0.1.3       app-0.1.1  
kanban-postgres default         1               2021-07-21 11:37:24.452345836 -0400 EDT deployed        postgresql-10.6.1      11.12.0    
kanban-ui       default         1               2021-07-21 11:37:50.228194086 -0400 EDT deployed        kanban-ui-0.1.4        ui-0.1.2 
```