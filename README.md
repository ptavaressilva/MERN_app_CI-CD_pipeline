# DevOps Bootcamp Final Project

## Continuous Delivery pipeline and monitoring for a MERN application

CI/CD pipelines allow for a fast response to business needs, while other DevOps practices support stable, secure and predictable services, striking the perfect balance  between stability and the speed of change.

This is a final project by Pedro Tavares for a DevOps Bootcamp course at [GeeksHubs Academy](https://geekshubsacademy.com/) (in spanish).

It creates a Continuous Delivery pipeline for a JavaScript/MERN application, with **development**, **staging** and **production** environments, tests and monitoring.

![CI/CD pipeline](https://raw.githubusercontent.com/ptavaressilva/final_devops_project/master/img/pipeline.png) 

### Requirements and coverage

- [x] The application must be containerized
- [x] The application must communicate with a database
- [x] Containers must be managed with an orchestrator
- [ ] It must be possible to test the pipeline locally (e.g. not require a cloud provider account)
- [ ] Pushing to master must trigger a pipeline that terminates with a deployment to production (Continuous Delivery)
- [ ] The pipeline must include Development, Staging and Production environments
- [ ] The system must include application and infrastructure monitoring and a dashboard

*The actual software application falls outside the scope of this project.*

### The Technological Stack

Currently the project uses the following technologies:

- MERN stack (MongoDB, Express, React and NodeJS)
- Docker
- Docker-Compose

This section will be updated as the project progresses.

### Application placeholder

The application placeholder was bootstrapped with [Create React App](https://github.com/facebook/create-react-app), the officially supported way to create single-page React applications.

App and containerization code baseed on [mern-docker-starter](https://github.com/joshdcuneo/mern-docker-starter.git).

### Architecture

Each environment includes a frontal server to serve static contents and pass API call to the backend, a backend server to query the database and serve API calls, and a database.

In each environment there are subtle changes, to account for the desired use of the environment (development, testing, etc.)

The development environment has three containers:

- Node (frontend)
- Nodemon (backend)
- MongoDB (database)

The development environment has three containers:

- Nginx (frontend)
- Nodemon (backend)
- MongoDB (database)

Additional containers are used to build the static Reacty content and pass it to the Nginx container at build, and .

![Environment containers and volumes](https://raw.githubusercontent.com/ptavaressilva/final_devops_project/master/img/architecture.png)

## Running the project

To run this project you need to install on the host:

- Docker
- Docker-compose

### Manual start of the development environment

To start manually the development environment, use`docker-compose -f docker-compose.dev.yml up`

You can access the application on [http://localhost:3000](http://localhost:3000)

### Manual start of the staging environment

The staging environment uses a persistent Docker volume, which needs to be created with `docker volume create staging_vol_db` before starting the environment.

To start manually the staging environment use  `docker-compose -f docker-compose.staging.yml up`

You can access the application on [http://localhost](http://localhost)
