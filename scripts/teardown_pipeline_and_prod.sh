#!/bin/bash

# Remove DevOps infrastructure
docker-compose -f ./ops/docker-compose.ops.yml down

# Remove production
docker stack rm prod

# Clean orphan images - be carefull if you have other images that cannot be removed
echo "The next command may take some time (if you confirm)."
docker image prune

# Clean orphan networks - be carefull if you have other networks that cannot be removed
docker network prune

# Remove persistent data (BE CAREFULL! You will need to reconfigure everything again.)
# docker volume rm ops_gogs ops_registry ops_jenkins ops_prometheus ops_grafana app_db_staging cicd_stack_db_prod
echo "If you want to remove docker volumes, uncomment line 17 of this script"