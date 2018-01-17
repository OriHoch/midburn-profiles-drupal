# midburn-profiles-drupal

Containerized Midburn Profiles Drupal App

## Warnings

All warnings will hopefully be removed soon, but for now - 
* **Work In Progress**
* **Code is still not open source, requires permissions to download code and data dumps from google storage**
* **Running the environment locally requires a strong PC, enough RAM and ~10GB of available storage (preferably SSD)**

## Prerequisites

* Install [Docker](https://docs.docker.com/engine/installation/)
* Install [Docker Compose](https://docs.docker.com/compose/install/)
* Install [Gcloud SDK](https://cloud.google.com/sdk/downloads)
* Ask for permissions to the midburn google account
* Login with `gcloud auth login`


## Run the database

Start the database services

```
docker-compose up -d db adminer
```

Download a database dump

```
gsutil cp gs:/midburn-k8s-backups/profiles-db-production-dump-2018-01-16-11-30.sql dump.sql
```

Create Spark DB + import the data (takes a while)

```
echo "create database midburndb;" | mysql --host=127.0.0.1 --user=root --password=123456
cat ./dump.sql | mysql --host=127.0.0.1 --user=root --password=123456 --database midburndb --one-database
```

Browse the data

* http://localhost:8080/login
* Server: db
* User: root
* Password: 123456
* Database: midburndb

To remove the DB and free up the resources

```
docker-compose down -v
```


## Run the drupal container

Pull the image from private google repository, the image is ~1GB

```
gcloud docker -- pull gcr.io/midbarrn/midburn-profiles-drupal-latest
```

Run the container

```
docker-compose run drupal
```


## Building an updated drupal container image

The drupal image is based on dumps of data from the old drupal server which are downloaded to create the image.

If you made changes to the `Dockerfile` or other related files, you should rebuild the image.

The build takes a long time and downloads GBs of data, so we use Google Container Builder to build the images.

Modify the IMAGE_TAG in the following snippet to identify your image (this can be git commit or tag when run from automation tools)

```
IMAGE_TAG="testing123"
CLOUDSDK_CORE_PROJECT=midbarrn
PROJECT_NAME=midburn-profiles-drupal
./cloudbuild.sh "gcr.io/${CLOUDSDK_CORE_PROJECT}/${PROJECT_NAME}:${IMAGE_TAG}" "${CLOUDSDK_CORE_PROJECT}" "${PROJECT_NAME}"
```
