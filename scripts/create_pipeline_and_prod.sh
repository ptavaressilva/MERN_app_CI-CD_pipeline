#!/bin/bash

#####################################################
#                                                   #
# Only run this script ONCE, to create the DevOps   #
# infrastructure and production environment.        #
#                                                   #
# BEFORE running this script, run create_volumes.sh #
# and configure Gogs to run on port 9001.           #
#                                                   #
# (see README.md at                                 #
# github.com/ptavaressilva/MERN_app_CI-CD_pipeline  #
# for details)                                      #
#                                                   #
#####################################################

# Create network
docker network create -d overlay --attachable ops_overlay_network

# Build and run containers for Jenkins, Gogs, Registry, Prometheus and Grafana
docker-compose -f ../ops/docker-compose.ops.yml up -d

# Build images for production frontend, backend and database
docker-compose -f ../app/docker-compose.staging.yml build
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

# Load production environment variables on this host, for stack startup
export $(grep -v '^#' ./.env_prod | xargs)

# Start production
docker stack deploy --compose-file ../app/docker-compose.prod.yml prod

# Add prod_client service to the ops_network, for smoke tests
docker service update --network-add ops_overlay_network prod_client
docker service update --network-add ops_overlay_network prod_server
docker service update --network-add ops_overlay_network prod_db

# remove production environment variables from host
unset SRV_PORT
unset MONGO_URI
unset MONGO_PORT
unset MONGO_INITDB_ROOT_USERNAME
unset MONGO_INITDB_ROOT_PASSWORD
unset NODE_ENV
unset GIT_COMMIT

# Clean intermediate images - be carefull if you have other images that cannot be removed
echo "The next command may take some time (if you confirm)."
docker image prune