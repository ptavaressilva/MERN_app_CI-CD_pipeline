#!/bin/bash

docker-compose -f ./app/docker-compose.dev.standalone.yml up

# The following directories on your computer will be mapped
#
# --------
# Frontend
# --------
# ./client/src (in tyour computer) --> /app/client/src (in frontend server)
# ./client/public                  --> /app/client/public
#
# --------
# Backend
# --------
# ./server/src                     --> /app/server/src