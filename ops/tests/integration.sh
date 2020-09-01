#!/bin/bash

# curl http://localhost:80/welcome
# - should output -
# Hello Client! There is one record in the database for Pedro Tavares

export STR=$(curl http://prod_client:8080/welcome)
export SUB='Hello Client! There is one record in the database for Pedro Tavares'
if [[ "$STR" != *"$SUB"* ]]; then
  echo 'Integration test failed!'
  echo 'App output = ' $STR
  exit 1 # integration test failed
fi

echo 'Integration test passed. The app returned: ' $STR
