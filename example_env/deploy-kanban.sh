#!/bin/bash

helm dependency update charts/kanban/ && helm upgrade --install --dry-run kanban charts/kanban/ && helm upgrade --install --atomic --timeout 60s kanban charts/kanban/