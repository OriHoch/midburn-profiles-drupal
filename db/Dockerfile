FROM mysql:5.6

RUN apt-get update && apt-get install -y curl &&\
    export CLOUD_SDK_REPO="cloud-sdk-jessie" &&\
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - &&\
    apt-get update && apt-get install -y google-cloud-sdk

COPY secret-k8s-ops.json .

RUN gcloud auth activate-service-account --key-file=secret-k8s-ops.json;\
    gcloud config set project midbarrn;\
    mkdir -p /profiles-db-datadir/mysql;\
    gsutil -qm cp -cUR 'gs://midburn-k8s-backups/profiles-db-production-mysqldump-2018-01-16/*' /profiles-db-datadir/mysql/;\
    chown -R mysql:mysql /profiles-db-datadir;\
    rm -f secret-k8s-ops.json

CMD ["mysqld", "--datadir=/profiles-db-datadir/mysql"]
