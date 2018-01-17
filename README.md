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


## Pull the docker images

The docker images are stored on a private Google Cloud Repository

* Install [Gcloud SDK](https://cloud.google.com/sdk/downloads)
* Ask for permissions to the midburn google account
* Login with `gcloud auth login` 

Pull the images

* DB - `gcloud docker -- pull gcr.io/midbarrn/midburn-profiles-drupal-db-latest`
* Drupal - `gcloud docker -- pull gcr.io/midbarrn/midburn-profiles-drupal-latest` 


## Run the environment

```
docker-compose up --build
```

Drupal is available at https://localhost
DB management web ui is available at http://localhost:8080/login
* Server: db
* User: root
* Password: 123456
* Database: midburndb

To rebuild and restart (if you made changes) just run the up command again

To remove remove the environment and release all resources

```
docker-compose down -v
```


## Building updated images

The images are based on dumps of data from the old drupal server which are downloaded in the `Dockerfile`.

If you made changes to the `Dockerfile` or `db/Dockerfile` or other related files, you should rebuild the image/s.

The build takes a long time and downloads GBs of data, so we use Google Container Builder.

* Drupal - `./cloudbuild.sh gcr.io/midbarrn/midburn-profiles-drupal:_ midbarrn midburn-profiles-drupal .`
* DB - `./cloudbuild.sh gcr.io/midbarrn/midburn-profiles-drupal-db:_ midbarrn midburn-profiles-drupal-db db`


## Updating the DB image

* Comment out the lines in `db/Dockerfile` which copy the mysql data directory
* Build and run this image - should provide a clean mysql DB
* Download a database dump, e.g. = `gsutil cp gs:/midburn-k8s-backups/profiles-db-production-dump-2018-01-16-11-30.sql dump.sql`
* Create Spark DB and import the data
```
echo "create database midburndb;" | mysql --host=127.0.0.1 --user=root --password=123456
cat ./dump.sql | mysql --host=127.0.0.1 --user=root --password=123456 --database midburndb --one-database
```
* Find the docker mountpath for `/var/lib/mysql` and copy the files
