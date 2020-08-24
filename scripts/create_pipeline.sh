#!/bin/bash

# This script needs to be executed on a swarm manager node

# Create Jenkins image
docker build -t ops_jenkins -f ../ops/Dockerfiles/Dockerfile.jenkins .

# Deploy stack to swarm
docker stack deploy --compose-file ../ops/stackfile.ops.yml cicd_stack
