#!/bin/bash

# (Build and) run containers for Jenkins, Gogs, Registry, Prometheus and Grafana
docker-compose -f ./ops/docker-compose.ops.yml up -d

# Build images for production frontend, backend and database

docker-compose -f ./app/docker-compose.staging.yml build
docker pull mongo

# Push images to registry

docker image tag client localhost:5000/client_install
docker image tag server localhost:5000/server_install
docker image tag mongo localhost:5000/db_install
docker push localhost:5000/client_install
docker push localhost:5000/server_install
docker push localhost:5000/db_install

# Clean up local images
docker rmi localhost:5000/client_install
docker rmi localhost:5000/server_install
docker rmi localhost:5000/db_install
docker rmi client
docker rmi server
docker rmi mongo
docker image prune

# load production environment variables on this host, for stack startup
export $(grep -v '^#' ./scripts/.env_prod | xargs)

# Start production
docker stack deploy --compose-file ./app/docker-compose.prod-install.yml prod

# remove production environment variables from host
unset SRV_PORT
unset MONGO_URI
unset MONGO_PORT
unset MONGO_INITDB_ROOT_USERNAME
unset MONGO_INITDB_ROOT_PASSWORD
unset NODE_ENV