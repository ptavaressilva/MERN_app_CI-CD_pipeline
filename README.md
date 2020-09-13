# MERN application with CI-CD pipeline

## Continuous Delivery pipeline and monitoring for a MERN application

CI/CD pipelines allow for a fast response to business needs, while other DevOps practices support stable, secure and predictable services, striking the perfect balance  between stability and the speed of change.

This is a final project by Pedro Tavares for a DevOps Bootcamp course at [GeeksHubs Academy](https://geekshubsacademy.com/) (in Spanish).

It creates a Continuous Delivery pipeline for a JavaScript/MERN application, with **development**, **staging** and **production** environments, tests and monitoring.

![CI/CD pipeline](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/pipeline.png?raw=true)

### Requirements and coverage

- [x] The application must be containerized
- [x] The application must communicate with a database
- [x] Containers must be managed by an orchestrator
- [x] It must be possible to test the pipeline locally (e.g. not require a cloud provider account)
- [x] Pushing to master must trigger a pipeline that terminates with a deployment to production (Continuous Delivery)
- [x] The pipeline must include Development, Staging and Production environments
- [x] The system must include application and infrastructure monitoring, and a dashboard

*The actual software application falls outside the scope of this project.*

### The Technological Stack

Currently the project uses the following technologies:

- Docker (incl. Docker Compose and Swarm)
- MongoDB, Express, React and NodeJS (MERN stack)
- Jest (for unit tests)
- Docker Registry
- Gogs
- Jenkins
- Prometheus, Grafana and Container Advisor

### Application placeholder

The application placeholder was bootstrapped with [Create React App](https://github.com/facebook/create-react-app), the officially supported way to create single-page React applications. The app was based on [mern-docker-starter](https://github.com/joshdcuneo/mern-docker-starter.git).

When the app is started, it creates a user in the database. When a page is requested to the React client, it calls the Express server, which queries the database and returns the username created at startup.

![The application](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/app_page.png?raw=true)

As **this application falls ouside the scope of the project**, its limitations were not addressed (e.g. there are some dependancy issues and it creates the same user every time it starts, so the database will have multiple copies of this user on persistent volumes).

### Application Architecture

Each environment includes a frontal server to serve static contents and pass API call to the backend, a backend server to query the database and serve API calls, and a database. Application telemetry is provided to Prometheus from the backend.

In each environment there are subtle changes, to account for the desired use of the environment (development, testing, etc.)

### Development

- The react frontend application is served with Node.

- The Express backend uses Nodemon, which reloads on code change (useful for standalone lolcal environments, in the developer's machine).

- The database container is stateful, as its data resides inside the container (it is destroyed whenever the container is removed).

- When run standalone, the frontend, backend and database ports are exposed (see image below for port details).

### Staging

- The frontend is served with Nginx

- The backend is served with Node.

- Additional containers are used to build the static React and Express content of the client and server, and then pass it to the Nginx and Node containers respectively.

- The database data resides in a docker named volume (db_staging)

### Production

- Frontend and backend containers use the imutable images built for staging.

- The database data resides in a docker named volume (db_prod)

- Multiple replicas of the front and backend containers are orchestrated with Docker Swarm, to scale capacity according to demand.

![Environment containers and volumes](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/environments.png?raw=true)

## Folder structure

This project has the following file structure:

```
|
+- app        <--- Infrastructure as code (IaaC)for the application stack
|  +- client  <--- Frontend files (React / JavaScript)
|  +- server  <--- Backend files (Express / JavaScript)
|
+- ops        <--- DevOps IaaC, including pipeline and integration tests
|
+- scripts    <--- Scripts to launch and tear-down the infrastructure
```

## Running the project

This DevOps ecosystem includes all containers shown in the image below.

![Ops containers](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/Orchestration_and_volumes.png?raw=true)

Production and the DevOps infrastructure are segregated (in separate bridge networks), so an overlay network is used to enable:

- Jenkins to make smoke test in production

- Prometheus to colect metrics from production

This infrastructure enables you to run a Continuous Delivery pipeline like the one presented in the image below, which is implemented in this project.

![Jenkins pipeline](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/Jenkins_pipeline.png?raw=true)

Typically a developer needs a standalone development environment on her/his local machine, to develop and test the application code. Once code is ready, the developer pushes that code to the SCM repository (Gogs, in our case), triggering the Continuous Delivery pipeline. If the code was pushed to the master branch, it will be deployed in production with a rolling deployment, assuming it passes unit, integration and smoke tests, naturally.

To create a local development environment (on the developer's machine) **the machine needs to have docker and docker-compose installed**. If you want to run this pipeline on your machine, **the Docker Engine must be in Swarm mode**, as we'll use a swarm stack for production.

### Creating a local development environment

Create a local development environment using `docker-compose -f ./app/docker-compose.dev.yml up -d`

These folders on your computer will be mapped to frontend and backend server foldders:

| Folder on your computer | Server (container) | Folder on server   |
| ----------------------- | ------------------ | ------------------ |
| ./client/src            | Frontend           | /app/client/src    |
| ./client/public         | Frontend           | /app/client/public |
| ./server/src            | Backend            | /app/server/src    |

**Note:** when Jenkins builds and deploys the dev environment, within the pipeline, the code is copied to the container (not mapped).

You can  access the application on your local dev environment at [http://localhost:3000](http://localhost:3000)

### Step 1 - Data persistance

We'll use Docker volumes  to persist the staging and prod databases, as well as data in Jenkins, Gogs (a and Registry (Docker image registry).

Let's create the necessary Docker volumes by running the script `./ops/create_volumes.sh`

### Step 2 - Configure Gogs

On startup, Gogs is served at port 3000, which will be used for our dev frontend, so we will configure it to use port 9001.

Start the default Gogs with:

`docker-compose -f ./ops/docker-compose.gogs3000.yml up -d`

Use `watch docker ps` to determine when the container with the image *gogs/gogs* is running (Ctrl+C to exit), then connect to the Gogs webpage on [http://localhost:3000](http://localhost:3000) and configure the following parameters in the *Install Steps For First-time Run* page:

| Parameter                                                | Value                    |
| -------------------------------------------------------- | ------------------------ |
| Database Type                                            | `SQLite3`                |
| HTTP Port                                                | `9001`                   |
| Application URL                                          | `http://localhost:9001`/ |
| Admin Account Settings / Username                        | `gogsadmin`              |
| Admin Account Settings / Password (and confirm password) | `gogssecret`             |
| Admin Account Settings / email                           | `a@a.a`                  |

Hit the *"Install Gogs"* button to finish the configuration. **It will will not find the page, but that's ok**. The container needs to restart to pick up the port change. For now we are done with Gogs on port 3000, so we shut it down with:

`docker-compose -f ./ops/docker-compose.gogs3000.yml down`

Don't worry! Your configuration in saved in the `gogs` docker volume created earlier.

### Step 3 - Create a production bootstrap variables file

The development, staging and production secrets will live in Jenkins Credentials, but to start the production stack for the first time we'll create a file called `.env_prod` in the ./script folder, with the following contents:

```bash
SRV_PORT=4000
MONGO_URI=prod_db:27017/db?authSource=admin
MONGO_PORT=27017
MONGO_INITDB_ROOT_USERNAME=pedro
MONGO_INITDB_ROOT_PASSWORD=kewlSecret
NODE_ENV=production
GIT_COMMIT=install
```

*.env* files are excluded in gitignore, so they will not be pushed to the Gogs repository.

### Step 4 - Start the DevOps infrastructure (including production)

To start the DevOps pipeline infrastructure run the sript:

`./scripts/create_pipeline_and_prod.sh`

This will create containers for Jenkins, Gogs, Registry, Prometheus and Grafana, a overlay network and clusters for the application front and backends, as well as a service for the production Mongo database.

Configure Jenkins
Use the `docker logs $(docker ps --filter , click onme=ops_jenkins_1  andq)` command to view the Jenkins service logs and find the installation password, in a segment looking like this:

```bach
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | *************************************************************
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | *************************************************************
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | *************************************************************
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    |
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | Jenkins initial setup is required. An admin user has been created and a password generated.
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | Please use the following password to proceed to installation:
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    |
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | 18b9792120c6466f82f37c95363bc7bf
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    |
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    |
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | *************************************************************
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | *************************************************************
cicd_stack_jenkins.1.jft378dfo4tm@docker-desktop    | *************************************************************
```

Open Jenkins (at [localhost:8000](http://localhost:8000/)), provide the password (in the capture above it is `18b9792120c6466f82f37c95363bc7bf`) and then click on the *Install suggested plugins* option.

After the pluggins finish installing, in the *Create First Admin User* page, create the following user:

| Field          | Value          |
| -------------- | -------------- |
| Username:      | pipelineadmin  |
| password:      | pipelinesecret |
| email address: | a@a.a          |

In the *Instance Configuration* page leave the URL as `http://localhost:8000/` and press the *Save and finish* button.

#### Optional: install Blue Ocean plugin

To install additional plugins, go to *Manage Jenkins* (left-hand menu), click on *Manage Plugins* and then click on the *Available* tab.

Type `Blue Ocean`on the text box and check the box for the pluggin with that name, then press *Download and install after restart*.

Finally, check the *Restart Jenkins when installation is complete and no jobs are running* checkbox at the bottom of the page.

### Step 5 - Create and clone the remote mern_app repository

Go to <http://localhost:9001/gogsadmin> and create a Gogs repository using the + dropdown on the top right corner. Call it `mern_app` and hit the *Create Repository* button.

To use the pipeline you need to clone the Gogs `mern_app` repository created above into a folder in your computer that must reside outside the folder where you cloned this [MERN_app_CI-CD_pipeline](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline) project.

```bash
cd ..
# you should be otside the MERN_app_CI-CD_pipeline folder
git clone http://localhost:9001/gogsadmin/mern_app
cd mern_app
```

As the Gogs repository is empty, you will get a warning, but it's ok.

```bash
warning: You appear to have cloned an empty repository.
```

Copy the contents of the [MERN_app_CI-CD_pipeline](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline) to the *mern_app* folder you created above, but **be carefull not to copy the  hidden .git folder** (if you copy from a local clone of this repo).

### Step 6 - Configure the pipeline

Go to Jenkins [http://localhost:8000](https://localhost:8000) and click *New Item* on the lefthand side menu. In the *Enter an item name* box, type `MERN app Continuous Delivery`, choose type *Multibranch Pipeline* and click *ok* at the bottom of the page.

In the next page, in the *General* tab, provide the values below:


| Field              | Value                                     |
| ------------------ | ----------------------------------------- |
| Branch source      | Git                                       |
| Project Repository | `http://gogs:9001/gogsadmin/mern_app.git` |
| Credentials > Add  | MERN app Continuous Delivery              |

In the *Folder Credentials Provider: MERN app Continuous Delivery* pop-up, provide the following values:

| Field    | Valiue       |
| -------- | ------------ |
| Username | `gogsadmin`  |
| Password | `gogssecret` |

Press the *Add* button to return to the pipeline *General* tab.

In the *Credetials* field, select gogsadmin/****

In the *Build Configuration* tab, leave *by Jenkisfile* selected and insert `ops/Jenkinsfile` in the *Script Path* box.

Below, in the *Scan Multibranch Pipeline Triggers* section, check *"Periodically if not otherwise run"*, set the interval to `1 minute` and press the *Save* button at the bottom of the page.

### Step 7 - Store development, staging and production environment variables

Development, staging and production secrets will be stored in Jenkins Credentials.

For simplicity, we'll only keep secret the MongoDB admin password. To do this, go to [localhost:8000](http://localhost:8000/) and click *Manage Jenkins* on the lefthand side menu, then click on *Manage credentials*. Next, click on *Jenkins* in the *Stores scoped to Jenkins* section and then on *Global credentials (unrestricted)*.

Click *Add Crededntials* and repeat the proccess for each entry in the table below, using **Kind = Secret text**.

| Username                           | Password   |
| ---------------------------------- | ---------- |
| MONGO_INITDB_ROOT_PASSWORD_DEV     | kewlSecret |
| MONGO_INITDB_ROOT_PASSWORD_STAGING | kewlSecret |
| MONGO_INITDB_ROOT_PASSWORD_PROD    | kewlSecret |

### You are now ready to push code and run the pipeline

Go to the *mern_app* folder,  make your first commit and push to Gogs:

```bash
git add .
git commit -m"Initial commit"
git push origin master
```

When prompted, provide `gogsadmin` as username and `gogssecret` as password.

Now go to the Jenkins page on [http://localhost:8000](https://localhost:8000) and watch the pipeline execute. If you installed the Blue Ocean plugin, click on *Blue Ocean* on the lefthand side menu to use this enhanced UI.

Once your code passes unit, integration and smoke tests, your commit will be deployed into production with a rolling update.

[![Click to see pipeline at work (video)](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/pipeline_working.gif?raw=true)](https://youtu.be/E8cVWvzC9cI)

## Observability

Both infrastructure monitoring and application telemetry use Prometheus to scrape metrics from the application, cAdvisor, etc. You can then observe these metrics using Grafana dashboards.

To see the Prometheus targets go to [http://localhost:9090/targets](http://localhost:9090/targets).

### Setting up Grafana dashboards

To view Grafana dashboards go to [http://localhost:7070/containers/](http://localhost:7070/containers/) and log-in with:

```bash
User: admin
Password: grafanasecret
```

Click on the *configuration* icon on the left vertical bar and choose *data sources*, then click on the *add data source* button, select Prometheus and on the URL text box type `http://prometheus:9090`. Click on the *Save & Test* button at the bottom of the page to finish.

Now that we are getting metrics from Prometheus, let's create the first Grafana dashboard, with metrics colected from inside the application (with the library *prom-client*).

#### Application telemetry

The application is really simple and there's not much we can measure, but let's measure the number of times the web page page was shown and count the number of database connections successfully established, a well as any failures.

We'll create a dashboard like this:

![Monitoring the app](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/MERN_APP_dashboard.png?raw=true) 

To create the application telemetry dashboard, click on '+' sign on the left side vertical icon bar and choose *dashboard*. On the new dashboard, click the *+ Add new pannel* button and then select Prometheus as the data source. In the metrics text box paste the first PromQL query in the table below, give the pannel a descriptive title and press the "Apply" button.

Repeat for the remaining metrics.

| Función                                        | PromQL query                                                                 |
| ---------------------------------------------- | ---------------------------------------------------------------------------- |
| Number of times the app page was seen          | MERN_APP_web_app_calls{instance="prod_server:4000",job="MERN_APP"}           |
| Number of server/DB conections errors          | MERN_APP_db_connection_failures{instance="prod_server:4000",job="MERN_APP"}  |
| Number of successfull server/DB conections     | MERN_APP_db_connection_successes{instance="prod_server:4000",job="MERN_APP"} |
| Number of times Prometheus scraped app metrics | MERN_APP_metrics_read_total{instance="prod_server:4000",job="MERN_APP"}      |

#### Container monitoring

To create a dashboard to monitor the containers, click on '+' sign on the left side vertical icon bar and choose *import*.

Type `179`in the *Import via grafana.com* box, the press *load*, choose Prometheus as the data source and click *Import* to finish.

![Container dashboard](https://github.com/ptavaressilva/MERN_app_CI-CD_pipeline/blob/master/img/cAdvisory_dashboard.png?raw=true) 

### A word about OS'

This project was designed and tested in macOS Catalina, with Docker Desktop in swarm mode. Some changes may be required if you want to run it in Windows. If you want to try it out using Windows, I suggest you run it inside an Ubuntu virtual machine. Making this project compatible with Windows is a great opportunity for you to contribute! :)

## Improvements

Oh, where to start?...

There are many, many improvements that need to be made in order to make this a production ready solution. Here are a few, just to get you started:

Security
  
- Backups ***must*** be implemented. Please! Now! A quick way to start is to mount the docker volumes is a separate container and use it to make copies.

- The registry configuration used is only appropriate for testing, as a production-ready registry must be protected by TLS and should use an access-control mechanism.
  
Availability  

- Hosting Jenkins and the other DevOps containers in a local machine only makes sense for demonstration purposes, so the solution should be migrated from a local host to a cloud provider, like AWS, GCP, Digital Ocean on one of many others.

- Jenkins and the other servers that support the pipeline should be clustered (e.g. adding Jenkins workers).

- In this example Docker Swarm only has one host. It's quite simple to add workers to swarm.

- Gogs was installed with a SSQLite3 database within the Gogs container (mounted on a docker volume). In a production setting the DB should be more robust and installed in a sepparate container.

- Here and there you will find images that are not locked to a specific version (e.g. occurences of latest, LTS, etc.) This can generate make builds mutable and generate inestability. It can be solved easily by specifying a specific versio (e.g. mongo:4.4.0-bionic).

- Docker named volumes should be replaced with something more persistent, like a cloud driver, for example.

- In order for swarm to have more  than one node, shared file storage must be used.

Operation

- Due to time restrictions the configuration of the different containers was done mostly manually. Much could be automated (Using [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin), for example).

- Image tagging should be improved (including the project name, for example)

- Jenkins looks for commits every minute, but a webhook would be a faster alternative.

Testing

- Tests were implemented as proof of concept. There is only one unit test, one integration test and one smoke test. In a normal operation, code coverage can be an indicator of the minimum number of unit tests that should. There would also be many more unit tests than integration and end-to-end tests.

- Other types of tests should be incorporated, including stress tests, Fuzz tests and Soak tests.

Bottlenecks

- Concurrent pipeline exec of how many unit test ution is not safe at this stage. Further testing is required.

- The pipeline takes far too long to run. Work should be done to take it down to five minutes at most.

We'll... I hope you find this project usefull.

Feel free to contribute.
