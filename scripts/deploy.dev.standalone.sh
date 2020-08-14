# builds the development environment
docker-compose -f docker-compose.dev.yml build

docker stack deploy -c docker-compose.dev.yml dev

# docker stack rm dev
