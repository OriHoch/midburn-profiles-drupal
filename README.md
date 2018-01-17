# midburn-profiles-drupal

Containerized Midburn Profiles Drupal App

The code and related database data are private and require permissions to download the docker images from private google docker repository.


## Prerequisites

* Install [Docker](https://docs.docker.com/engine/installation/)
* Install [Docker Compose](https://docs.docker.com/compose/install/)
* To run locally - enough RAM and ~10GB of available storage (preferably SSD)


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

When done, remove the environment and delete all data

```
docker-compose down -v
```


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
