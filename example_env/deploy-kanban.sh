#!/bin/bash

helm dependency update kanban/ && helm upgrade --install --dry-run kanban kanban/ && helm upgrade --install --atomic --timeout 60s kanban kanban/