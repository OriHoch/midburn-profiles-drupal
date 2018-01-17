FROM ubuntu:trusty

RUN apt-get update && apt-get install -y curl &&\
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" &&\
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - &&\
    apt-get update && apt-get install -y google-cloud-sdk

COPY secret-k8s-ops.json .

RUN gcloud auth activate-service-account --key-file=secret-k8s-ops.json;\
    gcloud config set project midbarrn;\
    mkdir -p /home/bitnami; mkdir -p /opt/bitnami;\
    gsutil -qm cp -cr 'gs://midburn-k8s-backups/profiles-production-2018-01-16/etc' /etc/;\
    gsutil -qm cp -cr 'gs://midburn-k8s-backups/profiles-production-2018-01-16/home/bitnami' /home/bitnami/;\
    gsutil -qm cp -cr 'gs://midburn-k8s-backups/profiles-production-2018-01-16/opt/bitnami' /opt/bitnami/;\
    rm -f secret-k8s-ops.json
