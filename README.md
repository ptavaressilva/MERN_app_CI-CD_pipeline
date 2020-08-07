# DevOps Bootcamp Final Project

## Continuous Delivery pipeline for a MERN application

CI/CD pipelines allow for a fast response to business needs, while other DevOps practices support stable, secure and predictable services, striking the perfect balance  between stability and the speed of change.

This is a final project by Pedro Tavares for a DevOps Bootcamp course at GeeksHubs Academy.

It creates a Continuous Delivery pipeline for a JavaScript/MERN application, with **development**, **staging** and **production** environments, tests and monitoring.

![CI/CD pipeline](https://github.com/ptavaressilva/final_devops_project/blob/master/img/pipeline.png?raw=true) 

### Requirements

- The application must be containerized
- The application must communicate with a database
- It must be possible to test the pipeline locally (e.g. not require a cloud provider account)
- Pushing to master must trigger a pipeline that terminates with a deployment to production (Continuous Delivery)
- The pipeline must include Development, Staging and Production environments
- The system must include application and infrastructure monitoring and a dashboard
- Containers must be managed with an orchestrator

*The actual software application falls outside the scope of this project.*

### The Technological Stack

Currently the project uses the following technologies:

- MERN stack (MongoDB, Express, React and NodeJS)
- Docker
- Docker-Compose

This section will be updated as the project progresses.

### Application placeholder

The application placeholder was bootstrapped with [Create React App](https://github.com/facebook/create-react-app) and uses code from [mern-docker-starter](https://github.com/joshdcuneo/mern-docker-starter.git).

### Architecture

### Development environment

The development environment has three containers:

- Node (frontend)
- Nodemon (backend)
- MongoDB (database)

![Development environment containers](https://github.com/ptavaressilva/final_devops_project/blob/master/img/dev.png?raw=true)

## Running the project

### Manual start of the development environment

To manually start the application in a development environment you need Docker Desktop and Docker-Compose installed and the you need to run the following command in the repo root:

```bash
docker-compose -f docker-compose.dev.yml down
```
